import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pushit/core/clock.dart';
import 'package:pushit/core/failures.dart';
import 'package:pushit/core/view_status.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/home/presentation/cubit/home_cubit.dart';

import '../../../../helpers/helpers.dart';

class _MockPosts extends Mock implements PostsRepository;

class _MockAccounts extends Mock implements AccountsRepository;

class _MockSubscription extends Mock implements SubscriptionRepository;

class _MockAuth extends Mock implements AuthRepository;

/// A clock the test can move.
final class _MovableClock implements Clock {
  DateTime current = testNow;

  @override
  DateTime now() => current;
}

const _user = User(
  id: 'u',
  name: 'Lyes B.',
  email: 'lyes@example.com',
  isEmailVerified: true,
);

const _expired = ConnectedAccount(
  id: 'tt',
  platform: PlatformId.tiktok,
  handle: '@me',
  label: 'Me',
  accountType: 'creator',
  mode: AccountMode.assisted,
  health: AccountHealth.expired,
);

Post _scheduledIn(Duration delay) => Post(
  id: 'p',
  video: const VideoAsset(
    id: 'v',
    fileName: 'v.mp4',
    duration: Duration(seconds: 42),
    sizeBytes: 1,
    width: 1080,
    height: 1920,
  ),
  caption: 'Studio tour',
  isDraft: false,
  createdAt: testNow,
  updatedAt: testNow,
  targets: [
    PostTarget(
      platform: PlatformId.youtube,
      accountId: 'yt',
      scheduledAt: testNow.add(delay),
      status: TargetStatus.scheduled,
    ),
  ],
);

void main() {
  late _MockPosts posts; // fresh for each test
  late _MockAccounts accounts; // fresh for each test
  late _MockSubscription subscription; // fresh for each test
  late _MockAuth auth; // fresh for each test
  late StreamController<List<Post>> postsStream; // fresh for each test
  late StreamController<List<ConnectedAccount>> accountsStream; // ditto
  late StreamController<Subscription> subscriptionStream; // ditto
  late StreamController<void> ticks; // fresh for each test
  late _MovableClock clock; // fresh for each test

  setUp(() {
    posts = _MockPosts();
    accounts = _MockAccounts();
    subscription = _MockSubscription();
    auth = _MockAuth();
    postsStream = StreamController.broadcast();
    accountsStream = StreamController.broadcast();
    subscriptionStream = StreamController.broadcast();
    ticks = StreamController.broadcast();
    clock = _MovableClock();
    when(posts.watchPosts).thenAnswer((_) => postsStream.stream);
    when(accounts.watchAccounts).thenAnswer((_) => accountsStream.stream);
    when(subscription.watchSubscription)
        .thenAnswer((_) => subscriptionStream.stream);
    when(auth.watchUser).thenAnswer((_) => Stream.value(_user));
    when(() => accounts.reconnect(any())).thenAnswer((_) async {});
  });

  HomeCubit build() => HomeCubit(
    posts: posts,
    accounts: accounts,
    subscription: subscription,
    auth: auth,
    clock: clock,
    ticks: () => ticks.stream,
  );

  Future<void> emitAll({List<Post>? postList}) async {
    postsStream.add(postList ?? [_scheduledIn(const Duration(hours: 3))]);
    accountsStream.add(const [_expired]);
    subscriptionStream.add(const Subscription(plan: proPlan));
    await pumpEventQueue();
  }

  test('loads until posts, accounts and plan have all arrived', () async {
    final cubit = build()..started();
    addTearDown(cubit.close);
    await pumpEventQueue();

    expect(cubit.state.status, ViewStatus.loading);
    expect(cubit.state.userName, 'Lyes B.');

    postsStream.add(const []);
    accountsStream.add(const []);
    await pumpEventQueue();
    expect(cubit.state.status, ViewStatus.loading);

    subscriptionStream.add(const Subscription(plan: freePlan));
    await pumpEventQueue();
    expect(cubit.state.status, ViewStatus.ready);
    expect(cubit.state.dashboard?.firstUse, isNotNull);
  });

  test('builds the dashboard and follows changes', () async {
    final cubit = build()..started();
    addTearDown(cubit.close);

    await emitAll();

    final dashboard = cubit.state.dashboard!;
    expect(dashboard.next?.post.id, 'p');
    expect(dashboard.reconnects.single.account, _expired);

    accountsStream.add(const []);
    await pumpEventQueue();
    expect(cubit.state.dashboard?.reconnects, isEmpty);
  });

  test('counts down with the clock, once a minute', () async {
    final cubit = build()..started();
    addTearDown(cubit.close);
    await emitAll();
    expect(cubit.state.dashboard?.next?.countdown.hours, 3);

    clock.current = testNow.add(const Duration(hours: 1));
    ticks.add(null);
    await pumpEventQueue();

    expect(cubit.state.dashboard?.next?.countdown.hours, 2);
  });

  test('shows the failure, then retries every stream', () async {
    final cubit = build()..started();
    addTearDown(cubit.close);

    postsStream.addError(const NetworkFailure());
    await pumpEventQueue();
    expect(cubit.state.status, ViewStatus.failure);
    expect(cubit.state.failure, const NetworkFailure());

    cubit.retryTapped();
    await pumpEventQueue();
    expect(cubit.state.status, ViewStatus.loading);
    verify(posts.watchPosts).called(2);
    verify(accounts.watchAccounts).called(2);
    verify(subscription.watchSubscription).called(2);

    await emitAll();
    expect(cubit.state.status, ViewStatus.ready);
  });

  test('reconnects an account', () async {
    final cubit = build()..started();
    addTearDown(cubit.close);
    await emitAll();

    await cubit.reconnectTapped(_expired);

    verify(() => accounts.reconnect('tt')).called(1);
  });

  test('stops listening when closed', () async {
    final cubit = build()..started();
    await emitAll();

    await cubit.close();

    expect(postsStream.hasListener, isFalse);
    expect(accountsStream.hasListener, isFalse);
    expect(subscriptionStream.hasListener, isFalse);
    expect(ticks.hasListener, isFalse);
  });
}
