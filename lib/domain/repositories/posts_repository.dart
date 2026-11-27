import 'package:pushit/domain/entities/deletion_step.dart';
import 'package:pushit/domain/entities/edit_result.dart';
import 'package:pushit/domain/entities/post.dart';
import 'package:pushit/domain/entities/post_draft.dart';
import 'package:pushit/domain/entities/schedule_choice.dart';
import 'package:pushit/domain/enums/platform_id.dart';

/// Posts and drafts, and every action on them. Methods throw `AppFailure`.
abstract interface class PostsRepository {
  /// Every post and draft, newest first. Emits on every change.
  Stream<List<Post>> watchPosts();

  /// One post; emits `NotFoundFailure` as an error when it does not exist.
  Stream<Post> watchPost(String id);

  /// Creates a draft, or updates [draftId]. Throws `ValidationFailure`
  /// when the draft has no video.
  Future<Post> saveDraft(PostDraft draft, {String? draftId});

  Future<void> discardDraft(String id);

  /// Schedules [draft] (and removes [draftId] when given). Throws
  /// `LimitReachedFailure` when the plan's monthly limit is reached, and
  /// `ValidationFailure` when the draft cannot be scheduled.
  Future<Post> schedule(PostDraft draft, {String? draftId});

  /// Throws `ValidationFailure` once publishing has started.
  Future<Post> reschedule(String postId, ScheduleChoice choice);

  /// Cancels a scheduled post. Throws `ValidationFailure` once publishing
  /// has started.
  Future<void> cancel(String postId);

  /// Tries a failed platform again.
  Future<Post> retry(String postId, PlatformId platform);

  /// Edits the title (YouTube) and caption on every platform that allows
  /// it; the others report `EditOutcome.notSupported`.
  Future<List<EditResult>> editEverywhere(
    String postId, {
    String? title,
    String? caption,
  });

  /// Deletes the post on every platform. Each event is the full list of
  /// steps; assisted platforms stay `DeletionOutcome.awaitingUser` until
  /// [confirmAssisted].
  Stream<List<DeletionStep>> deleteEverywhere(String postId);

  /// The creator did the assisted action on [platform]: posted it, or,
  /// while the post is being deleted, deleted it.
  Future<void> confirmAssisted(String postId, PlatformId platform);

  /// Reminds the creator again after [delay].
  Future<void> snoozeAssisted(
    String postId,
    PlatformId platform,
    Duration delay,
  );
}
