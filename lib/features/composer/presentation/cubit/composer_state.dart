part of 'composer_cubit.dart';

/// Where scheduling stands (D8 → D13).
enum Submission { idle, submitting, scheduled, limitReached, failed }

final class ComposerState extends Equatable {
  const new({
    this.draft = const PostDraft(),
    this.draftId,
    this.uploadItem,
    this.upload,
    this.accounts = const [],
    this.plan = freePlan,
    this.hasPlatformChoice = false,
    this.usage,
    this.submission = Submission.idle,
    this.scheduledPost,
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

  /// This month's usage, for the limit-reached sheet (H3).
  final Usage? usage;
  final Submission submission;

  /// The post once scheduled (D13).
  final Post? scheduledPost;

  /// The platform check (D8).
  List<PlatformCheckIssue> get issues =>
      const CheckPlatforms()(draft, accounts, plan);

  /// The selected platforms without a problem.
  Set<PlatformId> get readyPlatforms {
    final issues = this.issues;
    if (issues.any((issue) => issue is FileTooLarge)) return const {};
    final blocked = {
      for (final issue in issues)
        switch (issue) {
          DurationTooLong(:final platform) ||
          NotConnected(:final platform) ||
          PaidPlanRequired(:final platform) => platform,
          PrivacyNotChosen() => PlatformId.tiktok,
          FileTooLarge() => null,
        },
    };
    return Set.unmodifiable(draft.platforms.difference(blocked));
  }

  ComposerState copyWith({
    PostDraft? draft,
    String? Function()? draftId,
    GalleryItem? Function()? uploadItem,
    UploadProgress? Function()? upload,
    List<ConnectedAccount>? accounts,
    Plan? plan,
    bool? hasPlatformChoice,
    Usage? usage,
    Submission? submission,
    Post? Function()? scheduledPost,
  }) => ComposerState(
    draft: draft ?? this.draft,
    draftId: draftId != null ? draftId() : this.draftId,
    uploadItem: uploadItem != null ? uploadItem() : this.uploadItem,
    upload: upload != null ? upload() : this.upload,
    accounts: accounts != null ? List.unmodifiable(accounts) : this.accounts,
    plan: plan ?? this.plan,
    hasPlatformChoice: hasPlatformChoice ?? this.hasPlatformChoice,
    usage: usage ?? this.usage,
    submission: submission ?? this.submission,
    scheduledPost: scheduledPost != null ? scheduledPost() : this.scheduledPost,
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
    usage,
    submission,
    scheduledPost,
  ];
}
