part of 'edit_everywhere_cubit.dart';

final class EditEverywhereState extends Equatable {
  const new({
    this.status = ViewStatus.initial,
    this.post,
    this.title = '',
    this.caption = '',
    this.isSubmitting = false,
    this.results,
    this.failure,
    this.actionFailure,
  });

  final ViewStatus status;

  /// The post as loaded, to compare the edits against.
  final Post? post;
  final String title;
  final String caption;
  final bool isSubmitting;

  /// Set once the edit was applied; the view then closes.
  final List<EditResult>? results;
  final AppFailure? failure;
  final AppFailure? actionFailure;

  List<EditPlanRow> get plan {
    final post = this.post;
    return post == null ? const [] : editPlanFor(post);
  }

  bool get hasChanges {
    final post = this.post;
    return post != null && (title != post.title || caption != post.caption);
  }

  bool get canApply => hasChanges && caption.trim().isNotEmpty && !isSubmitting;

  EditEverywhereState copyWith({
    ViewStatus? status,
    Post? Function()? post,
    String? title,
    String? caption,
    bool? isSubmitting,
    List<EditResult>? Function()? results,
    AppFailure? Function()? failure,
    AppFailure? Function()? actionFailure,
  }) => EditEverywhereState(
    status: status ?? this.status,
    post: post != null ? post() : this.post,
    title: title ?? this.title,
    caption: caption ?? this.caption,
    isSubmitting: isSubmitting ?? this.isSubmitting,
    results: results != null ? results() : this.results,
    failure: failure != null ? failure() : this.failure,
    actionFailure: actionFailure != null ? actionFailure() : this.actionFailure,
  );

  @override
  List<Object?> get props => [
    status,
    post,
    title,
    caption,
    isSubmitting,
    results,
    failure,
    actionFailure,
  ];
}
