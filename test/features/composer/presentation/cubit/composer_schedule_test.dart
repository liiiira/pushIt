import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pushit/core/failures.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/composer/presentation/cubit/composer_cubit.dart';

class _MockMedia extends Mock implements MediaRepository;

class _MockPosts extends Mock implements PostsRepository;

class _MockAccounts extends Mock implements AccountsRepository;

class _MockSubscription extends Mock implements SubscriptionRepository;

const _video = VideoAsset(
  id: 'v',
  fileName: 'v.mp4',
  duration: Duration(minutes: 1, seconds: 42),
  sizeBytes: 1,
  width: 1080,
  height: 1920,
);

ConnectedAccount _account(
  PlatformId platform, {
  AccountHealth health = AccountHealth.connected,
}) => ConnectedAccount(
  id: 'acc-${platform.name}',
  platform: platform,
  handle: '@me',
  label: 'Me',
  accountType: 'creator',
  mode: AccountMode.automatic,
  health: health,
);

final DateTime _at = DateTime(2026, 11, 12, 19);

final ComposerState _ready = ComposerState(
  draft: const PostDraft(
    video: _video,
    caption: 'Hi',
    platforms: {PlatformId.youtube, PlatformId.facebook, PlatformId.tiktok},
  ),
  draftId: 'draft-1',
  accounts: [
    _account(PlatformId.youtube),
    _account(PlatformId.facebook),
    _account(PlatformId.tiktok, health: AccountHealth.expired),
  ],
  plan: proPlan,
  hasPlatformChoice: true,
);

Post _scheduled(PostDraft draft) => Post(
  id: 'post-1',
  video: _video,
  caption: draft.caption,
  targets: [
    for (final platform in draft.platforms)
      PostTarget(
        platform: platform,
        scheduledAt: _at,
        status: TargetStatus.scheduled,
      ),
  ],
  isDraft: false,
  createdAt: _at,
  updatedAt: _at,
);

void main() {
  late _MockPosts posts; // fresh for each test
  late _MockAccounts accounts; // fresh for each test

  setUpAll(() => registerFallbackValue(const PostDraft()));

  setUp(() {
    posts = _MockPosts();
    accounts = _MockAccounts();
  });

  ComposerCubit build() => ComposerCubit(
    media: _MockMedia(),
    posts: posts,
    accounts: accounts,
    subscription: _MockSubscription(),
  );

  test('issues come from the platform check', () {
    expect(_ready.issues, [
      const NotConnected(PlatformId.tiktok),
      const PrivacyNotChosen(),
      const DurationTooLong(
        platform: PlatformId.facebook,
        limit: Duration(seconds: 90),
        actual: Duration(minutes: 1, seconds: 42),
      ),
    ]);
    expect(_ready.readyPlatforms, {PlatformId.youtube});
  });

  blocTest<ComposerCubit, ComposerState>(
    'keepReadyPlatforms drops the platforms with a problem',
    build: build,
    seed: () => _ready,
    act: (cubit) => cubit.keepReadyPlatforms(),
    verify: (cubit) =>
        expect(cubit.state.draft.platforms, {PlatformId.youtube}),
  );

  blocTest<ComposerCubit, ComposerState>(
    'scheduleChosen sets the schedule',
    build: build,
    seed: () => _ready,
    act: (cubit) => cubit.scheduleChosen(SameTime(_at)),
    verify: (cubit) => expect(cubit.state.draft.schedule, SameTime(_at)),
  );

  blocTest<ComposerCubit, ComposerState>(
    'scheduleTapped schedules the draft and keeps the post',
    setUp: () =>
        when(() => posts.schedule(any(), draftId: any(named: 'draftId')))
            .thenAnswer(
              (invocation) async =>
                  _scheduled(invocation.positionalArguments.first as PostDraft),
            ),
    build: build,
    seed: () => _ready.copyWith(
      draft: _ready.draft.copyWith(
        platforms: {PlatformId.youtube},
        schedule: () => SameTime(_at),
      ),
    ),
    act: (cubit) => cubit.scheduleTapped(),
    verify: (cubit) {
      expect(cubit.state.submission, Submission.scheduled);
      expect(cubit.state.scheduledPost?.id, 'post-1');
      verify(() => posts.schedule(any(), draftId: 'draft-1')).called(1);
    },
  );

  blocTest<ComposerCubit, ComposerState>(
    'the plan limit is reported',
    setUp: () =>
        when(() => posts.schedule(any(), draftId: any(named: 'draftId')))
            .thenThrow(const LimitReachedFailure()),
    build: build,
    seed: () => _ready,
    act: (cubit) => cubit.scheduleTapped(),
    verify: (cubit) => expect(cubit.state.submission, Submission.limitReached),
  );

  blocTest<ComposerCubit, ComposerState>(
    'other failures are reported, and can be acknowledged',
    setUp: () =>
        when(() => posts.schedule(any(), draftId: any(named: 'draftId')))
            .thenThrow(const NetworkFailure()),
    build: build,
    seed: () => _ready,
    act: (cubit) async {
      await cubit.scheduleTapped();
      expect(cubit.state.submission, Submission.failed);
      cubit.submissionShown();
    },
    verify: (cubit) => expect(cubit.state.submission, Submission.idle),
  );

  blocTest<ComposerCubit, ComposerState>(
    'reconnectTapped reconnects the account',
    setUp: () =>
        when(() => accounts.reconnect('acc-tiktok')).thenAnswer((_) async {}),
    build: build,
    seed: () => _ready,
    act: (cubit) => cubit.reconnectTapped(PlatformId.tiktok),
    verify: (_) => verify(() => accounts.reconnect('acc-tiktok')).called(1),
  );

  blocTest<ComposerCubit, ComposerState>(
    'newPostStarted forgets the post but keeps accounts and plan',
    build: build,
    seed: () => _ready,
    act: (cubit) => cubit.newPostStarted(),
    expect: () => [ComposerState(accounts: _ready.accounts, plan: proPlan)],
  );
}
