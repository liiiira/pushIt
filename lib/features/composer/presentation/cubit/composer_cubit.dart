import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/composer/domain/composer_rules.dart';

part 'composer_state.dart';

/// The post being composed, shared by every composer screen (D1–D13).
///
/// Provided by the composer shell route, so it lives while any
/// `/compose/*` screen is open.
class ComposerCubit extends Cubit<ComposerState> {
  new({
    required this._media,
    required this._posts,
    required this._accounts,
    required this._subscription,
  }) : super(const ComposerState());

  final MediaRepository _media;
  final PostsRepository _posts;
  final AccountsRepository _accounts;
  final SubscriptionRepository _subscription;
  StreamSubscription<UploadProgress>? _upload;
  final List<StreamSubscription<Object?>> _watches = [];

  /// Follows the connected accounts and the plan.
  void started() {
    _watches
      ..add(
        _accounts.watchAccounts().listen(
          (accounts) => _emitWithDefaults(state.copyWith(accounts: accounts)),
          onError: (Object _) {},
        ),
      )
      ..add(
        _subscription.watchSubscription().listen(
          (subscription) => emit(state.copyWith(plan: subscription.plan)),
          onError: (Object _) {},
        ),
      );
  }

  /// Uploads [item] and keeps the video once uploaded (D1 → D2).
  void uploadStarted(GalleryItem item) {
    unawaited(_upload?.cancel());
    emit(
      state.copyWith(
        uploadItem: () => item,
        upload: () => Uploading(sentBytes: 0, totalBytes: item.sizeBytes),
        draft: state.draft.copyWith(video: () => null),
      ),
    );
    _upload = _media
        .upload(item.id)
        .listen(
          (progress) => _emitWithDefaults(
            state.copyWith(
              upload: () => progress,
              draft: progress is Uploaded
                  ? state.draft.copyWith(video: () => progress.video)
                  : null,
            ),
          ),
          onError: (Object _) =>
              emit(state.copyWith(upload: () => const UploadFailed())),
        );
  }

  Future<void> pauseTapped() => _media.pause();

  Future<void> resumeTapped() => _media.resume();

  /// Starts the failed upload over.
  void retryUploadTapped() {
    final item = state.uploadItem;
    if (item != null) uploadStarted(item);
  }

  /// Stops the upload and forgets the video.
  Future<void> cancelUploadTapped() async {
    await _upload?.cancel();
    _upload = null;
    await _media.cancel();
    emit(
      state.copyWith(
        uploadItem: () => null,
        upload: () => null,
        draft: state.draft.copyWith(video: () => null),
      ),
    );
  }

  /// Continues a saved draft (D12), keeping its platforms.
  void draftResumed(Post draft) {
    unawaited(_upload?.cancel());
    _upload = null;
    emit(
      ComposerState(
        draft: draftFromPost(draft),
        draftId: draft.id,
        upload: Uploaded(draft.video),
        accounts: state.accounts,
        plan: state.plan,
        hasPlatformChoice: true,
      ),
    );
  }

  void captionChanged(String caption) =>
      emit(state.copyWith(draft: state.draft.copyWith(caption: caption)));

  void platformToggled(PlatformId platform) {
    final platforms = {...state.draft.platforms};
    if (!platforms.remove(platform)) platforms.add(platform);
    emit(
      state.copyWith(
        draft: state.draft.copyWith(platforms: platforms),
        hasPlatformChoice: true,
      ),
    );
  }

  /// Sets [platform]'s own title (YouTube) or text (D5). A copy that is
  /// back to the main caption, without a title, is dropped.
  void copyChanged(PlatformId platform, {String? title, String? text}) {
    final draft = state.draft;
    final existing = draft.copies
        .where((c) => c.platform == platform)
        .firstOrNull;
    final nextTitle = title ?? existing?.title;
    final copy = PlatformCopy(
      platform: platform,
      title: nextTitle == null || nextTitle.trim().isEmpty ? null : nextTitle,
      text: text ?? existing?.text ?? draft.caption,
    );
    final others = draft.copies.where((c) => c.platform != platform);
    final isMain = copy.title == null && copy.text == draft.caption;
    emit(
      state.copyWith(
        draft: draft.copyWith(copies: [...others, if (!isMain) copy]),
      ),
    );
  }

  /// [platform] goes back to the main caption.
  void copyReset(PlatformId platform) => emit(
    state.copyWith(
      draft: state.draft.copyWith(
        copies: [...state.draft.copies.where((c) => c.platform != platform)],
      ),
    ),
  );

  /// Uses a suggested caption (D11) as [suggestion]'s platform text.
  void suggestionUsed(CaptionSuggestion suggestion) =>
      copyChanged(suggestion.platform, text: suggestion.text);

  void coverChanged(Duration at) =>
      emit(state.copyWith(draft: state.draft.copyWith(coverAt: at)));

  void tiktokChanged(TikTokSettings settings) =>
      emit(state.copyWith(draft: state.draft.copyWith(tiktok: settings)));

  /// Saves the post as a draft when it has a video ("Drafts are saved
  /// automatically"). Resolves to whether a draft was saved; closing never
  /// waits on a failure.
  Future<bool> closeTapped() async {
    if (state.draft.video == null) return false;
    try {
      final saved = await _posts.saveDraft(state.draft, draftId: state.draftId);
      emit(state.copyWith(draftId: () => saved.id));
      return true;
    } on Object {
      return false;
    }
  }

  /// Applies the default platforms once the video and the accounts are
  /// known, unless they were already chosen.
  void _emitWithDefaults(ComposerState next) {
    final video = next.draft.video;
    if (next.hasPlatformChoice || video == null || next.accounts.isEmpty) {
      emit(next);
      return;
    }
    emit(
      next.copyWith(
        draft: next.draft.copyWith(
          platforms: defaultPlatforms(next.accounts, video, next.plan),
        ),
        hasPlatformChoice: true,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _upload?.cancel();
    for (final watch in _watches) {
      await watch.cancel();
    }
    await super.close();
  }
}
