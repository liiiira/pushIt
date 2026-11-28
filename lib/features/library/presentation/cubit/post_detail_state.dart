part of 'post_detail_cubit.dart';

final class PostDetailState extends Equatable {
  const new({
    this.status = ViewStatus.initial,
    this.post,
    this.showsStatistics = false,
    this.accounts = const [],
    this.busyPlatform,
    this.failure,
    this.actionFailure,
  });

  final ViewStatus status;
  final Post? post;

  /// Statistics are on paid plans only.
  final bool showsStatistics;

  /// The connected accounts, for the reconnect prompt (C5).
  final List<ConnectedAccount> accounts;

  /// The platform a retry or reconnect is running for.
  final PlatformId? busyPlatform;

  /// Why the post could not load.
  final AppFailure? failure;

  /// Why the last retry or reconnect failed; shown once.
  final AppFailure? actionFailure;

  /// The account [platform] posts with: the target's, else any on it.
  ConnectedAccount? accountFor(PlatformId platform) {
    final accountId = post?.targetFor(platform)?.accountId;
    return accounts.where((a) => a.id == accountId).firstOrNull ??
        accounts.where((a) => a.platform == platform).firstOrNull;
  }

  PostDetailState copyWith({
    ViewStatus? status,
    Post? Function()? post,
    bool? showsStatistics,
    List<ConnectedAccount>? accounts,
    PlatformId? Function()? busyPlatform,
    AppFailure? Function()? failure,
    AppFailure? Function()? actionFailure,
  }) => PostDetailState(
    status: status ?? this.status,
    post: post != null ? post() : this.post,
    showsStatistics: showsStatistics ?? this.showsStatistics,
    accounts: accounts != null ? List.unmodifiable(accounts) : this.accounts,
    busyPlatform: busyPlatform != null ? busyPlatform() : this.busyPlatform,
    failure: failure != null ? failure() : this.failure,
    actionFailure: actionFailure != null ? actionFailure() : this.actionFailure,
  );

  @override
  List<Object?> get props => [
    status,
    post,
    showsStatistics,
    accounts,
    busyPlatform,
    failure,
    actionFailure,
  ];
}
