import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:pushit/domain/domain.dart';

part 'composer_state.dart';

/// The post being composed, shared by every composer screen (D1–D13).
///
/// Provided by the composer shell route, so it lives while any
/// `/compose/*` screen is open.
class ComposerCubit extends Cubit<ComposerState> {
  new({required this._media}) : super(const ComposerState());

  final MediaRepository _media;
  StreamSubscription<UploadProgress>? _upload;

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
          (progress) => emit(
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

  /// Continues a saved draft (D12).
  void draftResumed(Post draft) {
    unawaited(_upload?.cancel());
    _upload = null;
    emit(
      ComposerState(
        draft: draftFromPost(draft),
        draftId: draft.id,
        upload: Uploaded(draft.video),
      ),
    );
  }

  @override
  Future<void> close() async {
    await _upload?.cancel();
    await super.close();
  }
}
