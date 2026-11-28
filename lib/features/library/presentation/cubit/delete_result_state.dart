part of 'delete_result_cubit.dart';

final class DeleteResultState extends Equatable {
  const new({
    this.status = ViewStatus.initial,
    this.steps = const [],
    this.failure,
  });

  final ViewStatus status;
  final List<DeletionStep> steps;
  final AppFailure? failure;

  DeleteResultState copyWith({
    ViewStatus? status,
    List<DeletionStep>? steps,
    AppFailure? Function()? failure,
  }) => DeleteResultState(
    status: status ?? this.status,
    steps: steps != null ? List.unmodifiable(steps) : this.steps,
    failure: failure != null ? failure() : this.failure,
  );

  @override
  List<Object?> get props => [status, steps, failure];
}
