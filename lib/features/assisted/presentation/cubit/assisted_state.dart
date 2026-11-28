part of 'assisted_cubit.dart';

enum AssistedMode { post, delete }

enum AssistedOutcome { none, done, snoozed }

final class AssistedState extends Equatable {
  const new({
    this.status = ViewStatus.initial,
    this.post,
    this.ticked = const {},
    this.outcome = AssistedOutcome.none,
    this.failure,
    this.actionFailure,
  });

  final ViewStatus status;
  final Post? post;

  /// The checklist steps done, by index.
  final Set<int> ticked;

  /// Set once the creator confirmed or snoozed; the view then closes.
  final AssistedOutcome outcome;
  final AppFailure? failure;
  final AppFailure? actionFailure;

  AssistedState copyWith({
    ViewStatus? status,
    Post? Function()? post,
    Set<int>? ticked,
    AssistedOutcome? outcome,
    AppFailure? Function()? failure,
    AppFailure? Function()? actionFailure,
  }) => AssistedState(
    status: status ?? this.status,
    post: post != null ? post() : this.post,
    ticked: ticked != null ? Set.unmodifiable(ticked) : this.ticked,
    outcome: outcome ?? this.outcome,
    failure: failure != null ? failure() : this.failure,
    actionFailure: actionFailure != null ? actionFailure() : this.actionFailure,
  );

  @override
  List<Object?> get props => [
    status,
    post,
    ticked,
    outcome,
    failure,
    actionFailure,
  ];
}
