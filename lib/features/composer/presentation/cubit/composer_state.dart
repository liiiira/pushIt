part of 'composer_cubit.dart';

final class ComposerState extends Equatable {
  const new({
    this.draft = const PostDraft(),
    this.draftId,
    this.uploadItem,
    this.upload,
    this.accounts = const [],
    this.plan = freePlan,
    this.hasPlatformChoice = false,
  });

  final PostDraft draft;

  /// The saved draft this post continues, if any.
  final String? draftId;

  /// The gallery video being uploaded.
  final GalleryItem? uploadItem;

  /// `null` before a video is picked.
  final UploadProgress? upload;

  /// The connected accounts (D4's platforms).
  final List<ConnectedAccount> accounts;
  final Plan plan;

  /// Whether the platforms were chosen (by default or by the creator),
  /// so later account changes leave them alone.
  final bool hasPlatformChoice;

  ComposerState copyWith({
    PostDraft? draft,
    String? Function()? draftId,
    GalleryItem? Function()? uploadItem,
    UploadProgress? Function()? upload,
    List<ConnectedAccount>? accounts,
    Plan? plan,
    bool? hasPlatformChoice,
  }) => ComposerState(
    draft: draft ?? this.draft,
    draftId: draftId != null ? draftId() : this.draftId,
    uploadItem: uploadItem != null ? uploadItem() : this.uploadItem,
    upload: upload != null ? upload() : this.upload,
    accounts: accounts != null ? List.unmodifiable(accounts) : this.accounts,
    plan: plan ?? this.plan,
    hasPlatformChoice: hasPlatformChoice ?? this.hasPlatformChoice,
  );

  @override
  List<Object?> get props => [
    draft,
    draftId,
    uploadItem,
    upload,
    accounts,
    plan,
    hasPlatformChoice,
  ];
}
