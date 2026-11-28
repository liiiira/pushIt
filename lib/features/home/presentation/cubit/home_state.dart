part of 'home_cubit.dart';

final class HomeState extends Equatable {
  const new({
    this.status = ViewStatus.initial,
    this.dashboard,
    this.userName,
    this.failure,
    this.actionFailure,
  });

  final ViewStatus status;

  /// Set once ready.
  final Dashboard? dashboard;

  /// For the avatar's initials; `null` until known.
  final String? userName;

  /// Why loading failed (I3).
  final AppFailure? failure;

  /// Why the last action (reconnect) failed; set for one emission.
  final AppFailure? actionFailure;

  HomeState copyWith({
    ViewStatus? status,
    Dashboard? Function()? dashboard,
    String? Function()? userName,
    AppFailure? Function()? failure,
    AppFailure? Function()? actionFailure,
  }) => HomeState(
    status: status ?? this.status,
    dashboard: dashboard != null ? dashboard() : this.dashboard,
    userName: userName != null ? userName() : this.userName,
    failure: failure != null ? failure() : this.failure,
    actionFailure: actionFailure != null ? actionFailure() : this.actionFailure,
  );

  @override
  List<Object?> get props => [
    status,
    dashboard,
    userName,
    failure,
    actionFailure,
  ];
}
