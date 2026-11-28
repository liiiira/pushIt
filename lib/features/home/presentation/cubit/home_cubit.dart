import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pushit/core/clock.dart';
import 'package:pushit/core/failures.dart';
import 'package:pushit/core/view_status.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/home/domain/build_dashboard.dart';

part 'home_state.dart';

/// B1, B2: the dashboard from the posts, accounts and plan, kept up to date
/// as they change and as time passes.
class HomeCubit extends Cubit<HomeState> {
  /// [ticks] fires once a minute, to count down (tests pass their own).
  new({
    required this._posts,
    required this._accounts,
    required this._subscription,
    required this._auth,
    required this._clock,
    Stream<void> Function()? ticks,
    this._build = const BuildDashboard(),
  }) : _ticks = ticks ?? _everyMinute,
       super(const HomeState());

  static Stream<void> _everyMinute() =>
      Stream<void>.periodic(const Duration(minutes: 1));

  final PostsRepository _posts;
  final AccountsRepository _accounts;
  final SubscriptionRepository _subscription;
  final AuthRepository _auth;
  final Clock _clock;
  final Stream<void> Function() _ticks;
  final BuildDashboard _build;

  final List<StreamSubscription<Object?>> _subscriptions = [];
  StreamSubscription<User?>? _user;
  List<Post>? _latestPosts;
  List<ConnectedAccount>? _latestAccounts;
  Plan? _plan;

  void started() {
    _user = _auth.watchUser().listen(
      (user) => emit(state.copyWith(userName: () => user?.name)),
    );
    _listen();
  }

  /// I3: loads everything again.
  void retryTapped() => _listen();

  /// After the reconnect prompt (C5); the accounts stream then updates.
  Future<void> reconnectTapped(ConnectedAccount account) async {
    try {
      await _accounts.reconnect(account.id);
    } on AppFailure catch (failure) {
      if (isClosed) return;
      emit(state.copyWith(actionFailure: () => failure));
      emit(state.copyWith(actionFailure: () => null));
    }
  }

  void _listen() {
    _cancel();
    _latestPosts = null;
    _latestAccounts = null;
    _plan = null;
    emit(state.copyWith(status: ViewStatus.loading, failure: () => null));
    _subscriptions.addAll([
      _posts.watchPosts().listen((posts) {
        _latestPosts = posts;
        _publish();
      }, onError: _failed),
      _accounts.watchAccounts().listen((accounts) {
        _latestAccounts = accounts;
        _publish();
      }, onError: _failed),
      _subscription.watchSubscription().listen((subscription) {
        _plan = subscription.plan;
        _publish();
      }, onError: _failed),
      _ticks().listen((_) => _publish()),
    ]);
  }

  void _publish() {
    final posts = _latestPosts;
    final accounts = _latestAccounts;
    final plan = _plan;
    if (posts == null || accounts == null || plan == null) return;
    emit(
      state.copyWith(
        status: ViewStatus.ready,
        dashboard: () => _build(
          posts: posts,
          accounts: accounts,
          plan: plan,
          now: _clock.now(),
        ),
      ),
    );
  }

  void _failed(Object error) {
    _cancel();
    emit(
      state.copyWith(
        status: ViewStatus.failure,
        failure: () => error is AppFailure ? error : UnknownFailure(error),
      ),
    );
  }

  void _cancel() {
    final active = [..._subscriptions];
    _subscriptions.clear();
    for (final subscription in active) {
      unawaited(subscription.cancel());
    }
  }

  @override
  Future<void> close() async {
    _cancel();
    await _user?.cancel();
    await super.close();
  }
}
