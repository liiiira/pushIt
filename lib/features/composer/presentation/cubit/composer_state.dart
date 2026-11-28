part of 'composer_cubit.dart';

final class ComposerState extends Equatable {
  const new({
    this.draft = const PostDraft(),
    this.draftId,
    this.uploadItem,
    this.upload,
  });

  final PostDraft draft;

  /// The saved draft this post continues, if any.
  final String? draftId;

  /// The gallery video being uploaded.
  final GalleryItem? uploadItem;

  /// `null` before a video is picked.
  final UploadProgress? upload;

  ComposerState copyWith({
    PostDraft? draft,
    String? Function()? draftId,
    GalleryItem? Function()? uploadItem,
    UploadProgress? Function()? upload,
  }) => ComposerState(
    draft: draft ?? this.draft,
    draftId: draftId != null ? draftId() : this.draftId,
    uploadItem: uploadItem != null ? uploadItem() : this.uploadItem,
    upload: upload != null ? upload() : this.upload,
  );

  @override
  List<Object?> get props => [draft, draftId, uploadItem, upload];
}
