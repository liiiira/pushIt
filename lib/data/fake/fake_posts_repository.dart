import 'dart:async';

import 'package:pushit/core/failures.dart';
import 'package:pushit/data/fake/fake_database.dart';
import 'package:pushit/data/fake/fixtures/fixture_posts.dart';
import 'package:pushit/domain/domain.dart';

/// Posts and drafts in memory, newest first.
///
/// Simulations:
/// - "delete everywhere" removes automatic platforms (or fails them when
///   offline) and waits on assisted ones until [confirmAssisted]
/// - "edit everywhere" reports `notSupported` where a published platform
///   cannot be edited
/// - [triggerAssistedReminder] stands in for the G1 notification
final class FakePostsRepository implements PostsRepository {
  new(this._database);

  final FakeDatabase _database;
  final Map<String, _Deletion> _deletions = {};

  List<Post> get _posts => _database.posts.value;

  set _posts(List<Post> posts) =>
      _database.posts.value = List<Post>.unmodifiable(
        <Post>[...posts]..sort((a, b) => b.createdAt.compareTo(a.createdAt)),
      );

  @override
  Stream<List<Post>> watchPosts() => _database.watchLoad(_database.posts);

  @override
  Stream<Post> watchPost(String id) => _database
      .watchLoad(_database.posts)
      .transform(
        StreamTransformer<List<Post>, Post>.fromHandlers(
          handleData: (posts, sink) {
            final post = posts.where((p) => p.id == id).firstOrNull;
            if (post == null) {
              sink.addError(const NotFoundFailure());
            } else {
              sink.add(post);
            }
          },
        ),
      )
      .distinct();

  @override
  Future<Post> saveDraft(PostDraft draft, {String? draftId}) =>
      _database.act(() {
        final video = draft.video ?? (throw const ValidationFailure());
        final existing = draftId == null ? null : _find(draftId);
        final now = _database.now();
        final post = Post(
          id: existing?.id ?? _database.newId('draft'),
          video: video,
          caption: draft.caption,
          copies: draft.copies,
          coverAt: draft.coverAt,
          tiktok: _tiktokOf(draft),
          targets: _targetsOf(draft),
          isDraft: true,
          createdAt: existing?.createdAt ?? now,
          updatedAt: now,
        );
        _put(post);
        return post;
      });

  @override
  Future<void> discardDraft(String id) => _database.act(() {
    if (!_find(id).isDraft) throw const ValidationFailure();
    _remove(id);
  });

  @override
  Future<Post> schedule(PostDraft draft, {String? draftId}) =>
      _database.act(() {
        final video = draft.video;
        final choice = draft.schedule;
        if (video == null || choice == null) throw const ValidationFailure();
        if (isPostLimitReached(
          _database.subscription.value.plan,
          postsThisMonth: _database.postsThisMonth.value,
        )) {
          throw const LimitReachedFailure();
        }
        final now = _database.now();
        final problem = validateSchedule(
          choice,
          platforms: draft.platforms,
          now: now,
        );
        if (problem != null) throw const ValidationFailure();

        final post = Post(
          id: _database.newId('post'),
          video: video,
          caption: draft.caption,
          copies: draft.copies,
          coverAt: draft.coverAt,
          tiktok: _tiktokOf(draft),
          targets: _targetsOf(draft),
          isDraft: false,
          createdAt: now,
          updatedAt: now,
        );
        if (draftId != null && _posts.any((p) => p.id == draftId)) {
          _remove(draftId);
        }
        _put(post);
        _database.postsThisMonth.value++;
        return post;
      });

  @override
  Future<Post> reschedule(String postId, ScheduleChoice choice) =>
      _database.act(() {
        final post = _find(postId);
        if (!canReschedule(post)) throw const ValidationFailure();
        final problem = validateSchedule(
          choice,
          platforms: post.targets.map((t) => t.platform).toSet(),
          now: _database.now(),
        );
        if (problem != null) throw const ValidationFailure();
        final moved = post.copyWith(
          targets: [
            for (final target in post.targets)
              target.copyWith(
                scheduledAt: () => choice.timeFor(target.platform),
              ),
          ],
          updatedAt: _database.now(),
        );
        _put(moved);
        return moved;
      });

  @override
  Future<void> cancel(String postId) => _database.act(() {
    if (!canReschedule(_find(postId))) throw const ValidationFailure();
    _remove(postId);
    final count = _database.postsThisMonth.value;
    if (count > 0) _database.postsThisMonth.value = count - 1;
  });

  @override
  Future<Post> retry(String postId, PlatformId platform) => _database.act(() {
    final post = _find(postId);
    final target = post.targetFor(platform) ?? (throw const NotFoundFailure());
    if (target.status != TargetStatus.failed) throw const ValidationFailure();
    final retried = _withTarget(
      post,
      target.copyWith(
        status: TargetStatus.published,
        failureReason: () => null,
        url: () => fixturePostUrl(platform, postId),
      ),
    );
    _put(retried);
    return retried;
  });

  @override
  Future<List<EditResult>> editEverywhere(
    String postId, {
    String? title,
    String? caption,
  }) => _database.act(() {
    final post = _find(postId);
    final requested = {
      if (title != null) EditableField.title,
      if (caption != null) EditableField.caption,
    };
    final results = [
      for (final target in post.targets)
        if (target.status != TargetStatus.removed)
          EditResult(
            platform: target.platform,
            outcome:
                target.status != TargetStatus.published ||
                    capabilityOf(target.platform).editableFields
                        .intersection(requested)
                        .isNotEmpty
                ? EditOutcome.applied
                : EditOutcome.notSupported,
          ),
    ];
    _put(
      post.copyWith(
        caption: caption,
        copies: _editedCopies(post, title: title, caption: caption),
        updatedAt: _database.now(),
      ),
    );
    return List<EditResult>.unmodifiable(results);
  });

  @override
  Stream<List<DeletionStep>> deleteEverywhere(String postId) {
    final post = _posts.where((p) => p.id == postId).firstOrNull;
    if (post == null) return Stream.error(const NotFoundFailure());
    _deletions[postId]?.close();
    final deletion = _Deletion([
      for (final target in post.targets)
        if (target.status != TargetStatus.removed)
          DeletionStep(
            platform: target.platform,
            method: capabilityOf(target.platform).deleteMethod,
            outcome: DeletionOutcome.pending,
          ),
    ]);
    _deletions[postId] = deletion;
    unawaited(
      _database.delay().then((_) {
        for (final step in deletion.steps) {
          deletion.resolve(step.platform, switch (step.method) {
            DeleteMethod.automatic =>
              _database.isOffline
                  ? DeletionOutcome.failed
                  : DeletionOutcome.removed,
            DeleteMethod.assisted => DeletionOutcome.awaitingUser,
          });
          if (deletion.outcomeOf(step.platform) == DeletionOutcome.removed) {
            _markRemoved(postId, step.platform);
          }
        }
        deletion.emit();
        _finishIfSettled(postId);
      }),
    );
    return deletion.stream;
  }

  @override
  Future<void> confirmAssisted(String postId, PlatformId platform) =>
      _database.act(() {
        final deletion = _deletions[postId];
        if (deletion != null) {
          if (deletion.outcomeOf(platform) != DeletionOutcome.awaitingUser) {
            throw const ValidationFailure();
          }
          deletion
            ..resolve(platform, DeletionOutcome.removed)
            ..emit();
          _markRemoved(postId, platform);
          _finishIfSettled(postId);
          return;
        }
        final post = _find(postId);
        final target =
            post.targetFor(platform) ?? (throw const NotFoundFailure());
        if (target.status != TargetStatus.awaitingUser &&
            target.status != TargetStatus.scheduled) {
          throw const ValidationFailure();
        }
        _put(
          _withTarget(
            post,
            target.copyWith(
              status: TargetStatus.published,
              url: () => fixturePostUrl(platform, postId),
            ),
          ),
        );
        _database.log(
          ActivityItem(
            id: _database.newId('activity'),
            kind: ActivityKind.assistedConfirmed,
            occurredAt: _database.now(),
            postId: postId,
            postTitle: post.title,
            platform: platform,
          ),
        );
      });

  @override
  Future<void> snoozeAssisted(
    String postId,
    PlatformId platform,
    Duration delay,
  ) => _database.act(() {
    final post = _find(postId);
    final target = post.targetFor(platform) ?? (throw const NotFoundFailure());
    _put(
      _withTarget(
        post,
        target.copyWith(
          status: TargetStatus.scheduled,
          scheduledAt: () => _database.now().add(delay),
        ),
      ),
    );
  });

  /// For the Developer menu: the assisted reminder for [platform] fires now
  /// (G1), and the target waits for the creator.
  Future<void> triggerAssistedReminder(
    String postId,
    PlatformId platform,
  ) => _database.act(() {
    final post = _find(postId);
    final target = post.targetFor(platform) ?? (throw const NotFoundFailure());
    _put(_withTarget(post, target.copyWith(status: TargetStatus.awaitingUser)));
    _database.log(
      ActivityItem(
        id: _database.newId('activity'),
        kind: ActivityKind.assistedReminder,
        occurredAt: _database.now(),
        postId: postId,
        postTitle: post.title,
        platform: platform,
      ),
    );
  });

  Post _find(String id) =>
      _posts.where((p) => p.id == id).firstOrNull ??
      (throw const NotFoundFailure());

  void _put(Post post) =>
      _posts = [..._posts.where((p) => p.id != post.id), post];

  void _remove(String id) => _posts = _posts.where((p) => p.id != id).toList();

  Post _withTarget(Post post, PostTarget changed) => post.copyWith(
    targets: [
      for (final target in post.targets)
        if (target.platform == changed.platform) changed else target,
    ],
    updatedAt: _database.now(),
  );

  void _markRemoved(String postId, PlatformId platform) {
    final post = _posts.where((p) => p.id == postId).firstOrNull;
    final target = post?.targetFor(platform);
    if (post == null || target == null) return;
    _put(_withTarget(post, target.copyWith(status: TargetStatus.removed)));
  }

  void _finishIfSettled(String postId) {
    final deletion = _deletions[postId];
    if (deletion == null || !deletion.isSettled) return;
    if (deletion.isComplete) _remove(postId);
    _deletions.remove(postId);
    deletion.close();
  }

  TikTokSettings? _tiktokOf(PostDraft draft) =>
      draft.platforms.contains(PlatformId.tiktok) ? draft.tiktok : null;

  List<PostTarget> _targetsOf(PostDraft draft) => [
    for (final platform in PlatformId.values)
      if (draft.platforms.contains(platform))
        PostTarget(
          platform: platform,
          accountId: _database.accounts.value
              .where((a) => a.platform == platform)
              .firstOrNull
              ?.id,
          scheduledAt: draft.schedule?.timeFor(platform),
          status: TargetStatus.scheduled,
        ),
  ];

  List<PlatformCopy> _editedCopies(
    Post post, {
    required String? title,
    required String? caption,
  }) {
    final youtube = post.copyFor(PlatformId.youtube);
    if (youtube == null && title == null) return post.copies;
    final edited =
        (youtube ??
                PlatformCopy(
                  platform: PlatformId.youtube,
                  text: caption ?? post.caption,
                ))
            .copyWith(title: title == null ? null : () => title, text: caption);
    return [
      ...post.copies.where((c) => c.platform != PlatformId.youtube),
      edited,
    ];
  }
}

/// One "delete everywhere" in progress.
final class _Deletion {
  new(List<DeletionStep> steps) : _steps = steps {
    _controller.add(this.steps);
  }

  List<DeletionStep> _steps;
  final StreamController<List<DeletionStep>> _controller = StreamController();

  Stream<List<DeletionStep>> get stream => _controller.stream;

  List<DeletionStep> get steps => List.unmodifiable(_steps);

  DeletionOutcome? outcomeOf(PlatformId platform) =>
      _steps.where((s) => s.platform == platform).firstOrNull?.outcome;

  void resolve(PlatformId platform, DeletionOutcome outcome) => _steps = [
    for (final step in _steps)
      if (step.platform == platform) step.copyWith(outcome: outcome) else step,
  ];

  void emit() => _controller.add(steps);

  /// No step is pending or waiting for the creator.
  bool get isSettled => _steps.every(
    (s) =>
        s.outcome != DeletionOutcome.pending &&
        s.outcome != DeletionOutcome.awaitingUser,
  );

  bool get isComplete =>
      _steps.every((s) => s.outcome == DeletionOutcome.removed);

  void close() => unawaited(_controller.close());
}
