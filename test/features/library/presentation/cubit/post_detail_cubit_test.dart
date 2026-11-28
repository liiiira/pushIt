import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pushit/core/failures.dart';
import 'package:pushit/core/view_status.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/library/presentation/cubit/post_detail_cubit.dart';

class _MockPosts extends Mock implements PostsRepository;

class _MockAccounts extends Mock implements AccountsRepository;

class _MockSubscription extends Mock implements SubscriptionRepository;

final Post _post = Post(
  id: 'p1',
  video: const VideoAsset(
    id: 'v',
    fileName: 'v.mp4',
    duration: Duration(seconds: 21),
    sizeBytes: 1,
    width: 1080,
    height: 1920,
  ),
  caption: 'Mic test',
  targets: const [
    PostTarget(
      platform: PlatformId.youtube,
      accountId: 'acc-yt',
      status: TargetStatus.published,
    ),
    PostTarget(
      platform: PlatformId.tiktok,
      accountId: 'acc-tt',
      status: TargetStatus.failed,
      failureReason: TargetFailureReason.signInExpired,
    ),
  ],
  isDraft: false,
  createdAt: DateTime(2026, 11, 12),
  updatedAt: DateTime(2026, 11, 12),
);

void main() {
  late _MockPosts posts; // fresh for each test
  late _MockAccounts accounts; // fresh for each test
  late _MockSubscription subscription; // fresh for each test
  late StreamController<Post> post; // fresh for each test

  setUp(() {
    posts = _MockPosts();
    accounts = _MockAccounts();
    subscription = _MockSubscription();
    post = StreamController<Post>();
    when(() => posts.watchPost('p1')).thenAnswer((_) => post.stream);
    when(() => subscription.watchSubscription())
        .thenAnswer((_) => Stream.value(const Subscription(plan: proPlan)));
    when(() => accounts.watchAccounts())
        .thenAnswer((_) => const Stream.empty());
  });

  // close() only completes once a listener got the done event.
  tearDown(() => unawaited(post.close()));

  PostDetailCubit build() => PostDetailCubit(
    postId: 'p1',
    posts: posts,
    accounts: accounts,
    subscription: subscription,
  );

  blocTest<PostDetailCubit, PostDetailState>(
    'started loads the post and whether statistics show',
    build: build,
    act: (cubit) async {
      cubit.started();
      await Future<void>.delayed(Duration.zero);
      post.add(_post);
    },
    expect: () => [
      const PostDetailState(status: ViewStatus.loading),
      const PostDetailState(status: ViewStatus.loading, showsStatistics: true),
      PostDetailState(
        status: ViewStatus.ready,
        post: _post,
        showsStatistics: true,
      ),
    ],
  );

  blocTest<PostDetailCubit, PostDetailState>(
    'the Free plan hides statistics',
    setUp: () => when(() => subscription.watchSubscription())
        .thenAnswer((_) => Stream.value(const Subscription(plan: freePlan))),
    build: build,
    act: (cubit) async {
      cubit.started();
      post.add(_post);
    },
    verify: (cubit) => expect(cubit.state.showsStatistics, isFalse),
  );

  blocTest<PostDetailCubit, PostDetailState>(
    'a missing post is a failure',
    build: build,
    act: (cubit) async {
      cubit.started();
      post.addError(const NotFoundFailure());
    },
    verify: (cubit) {
      expect(cubit.state.status, ViewStatus.failure);
      expect(cubit.state.failure, const NotFoundFailure());
    },
  );

  blocTest<PostDetailCubit, PostDetailState>(
    'retryTapped retries the platform and clears the busy flag',
    setUp: () =>
        when(() => posts.retry('p1', PlatformId.tiktok))
            .thenAnswer((_) async => _post),
    build: build,
    seed: () => PostDetailState(status: ViewStatus.ready, post: _post),
    act: (cubit) => cubit.retryTapped(PlatformId.tiktok),
    expect: () => [
      PostDetailState(
        status: ViewStatus.ready,
        post: _post,
        busyPlatform: PlatformId.tiktok,
      ),
      PostDetailState(status: ViewStatus.ready, post: _post),
    ],
    verify: (_) => verify(() => posts.retry('p1', PlatformId.tiktok)).called(1),
  );

  blocTest<PostDetailCubit, PostDetailState>(
    'a failed action is reported without losing the post',
    setUp: () =>
        when(() => posts.retry('p1', PlatformId.tiktok))
            .thenThrow(const NetworkFailure()),
    build: build,
    seed: () => PostDetailState(status: ViewStatus.ready, post: _post),
    act: (cubit) => cubit.retryTapped(PlatformId.tiktok),
    expect: () => [
      PostDetailState(
        status: ViewStatus.ready,
        post: _post,
        busyPlatform: PlatformId.tiktok,
      ),
      PostDetailState(
        status: ViewStatus.ready,
        post: _post,
        actionFailure: const NetworkFailure(),
      ),
    ],
  );

  blocTest<PostDetailCubit, PostDetailState>(
    'reconnectAndRetryTapped reconnects the account, then retries',
    setUp: () {
      when(() => accounts.reconnect('acc-tt')).thenAnswer((_) async {});
      when(() => posts.retry('p1', PlatformId.tiktok))
          .thenAnswer((_) async => _post);
    },
    build: build,
    seed: () => PostDetailState(status: ViewStatus.ready, post: _post),
    act: (cubit) => cubit.reconnectAndRetryTapped(PlatformId.tiktok),
    verify: (_) {
      verifyInOrder([
        () => accounts.reconnect('acc-tt'),
        () => posts.retry('p1', PlatformId.tiktok),
      ]);
    },
  );

  blocTest<PostDetailCubit, PostDetailState>(
    'actionFailureShown clears the reported failure',
    build: build,
    seed: () => PostDetailState(
      status: ViewStatus.ready,
      post: _post,
      actionFailure: const NetworkFailure(),
    ),
    act: (cubit) => cubit.actionFailureShown(),
    expect: () => [PostDetailState(status: ViewStatus.ready, post: _post)],
  );

  blocTest<PostDetailCubit, PostDetailState>(
    'started also follows the accounts, for the reconnect prompt',
    setUp: () =>
        when(() => accounts.watchAccounts())
            .thenAnswer((_) => Stream.value(const [_tiktokAccount])),
    build: build,
    act: (cubit) async {
      cubit.started();
      post.add(_post);
    },
    verify: (cubit) {
      expect(cubit.state.accounts, const [_tiktokAccount]);
      expect(cubit.state.accountFor(PlatformId.tiktok), _tiktokAccount);
      expect(cubit.state.accountFor(PlatformId.youtube), isNull);
    },
  );
}

const _tiktokAccount = ConnectedAccount(
  id: 'acc-tt',
  platform: PlatformId.tiktok,
  handle: '@lyes.makes',
  label: 'Lyes makes',
  accountType: 'creator',
  mode: AccountMode.assisted,
  health: AccountHealth.expired,
);
