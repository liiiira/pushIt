part of 'delete_confirm_cubit.dart';

final class DeleteConfirmState extends Equatable {
  const new({this.status = ViewStatus.initial, this.post, this.failure});

  final ViewStatus status;
  final Post? post;
  final AppFailure? failure;

  DeleteConfirmState copyWith({
    ViewStatus? status,
    Post? Function()? post,
    AppFailure? Function()? failure,
  }) => DeleteConfirmState(
    status: status ?? this.status,
    post: post != null ? post() : this.post,
    failure: failure != null ? failure() : this.failure,
  );

  @override
  List<Object?> get props => [status, post, failure];
}
