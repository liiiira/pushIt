import 'dart:async';

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
  id: 'video-g1',
  fileName: 'studio_tour_p2.mp4',
  duration: Duration(minutes: 1, seconds: 42),
  sizeBytes: 300,
  width: 1080,
  height: 1920,
);

const _item = GalleryItem(
  id: 'g1',
  fileName: 'studio_tour_p2.mp4',
  duration: Duration(minutes: 1, seconds: 42),
  sizeBytes: 300,
  width: 1080,
  height: 1920,
);

ConnectedAccount _account(PlatformId platform) => ConnectedAccount(
  id: 'acc-${platform.name}',
  platform: platform,
  handle: '@me',
  label: 'Me',
  accountType: 'creator',
  mode: AccountMode.automatic,
  health: AccountHealth.connected,
);

final List<ConnectedAccount> _accounts = [
  _account(PlatformId.youtube),
  _account(PlatformId.facebook),
];

void main() {
  late _MockMedia media; // fresh for each test
  late _MockPosts posts; // fresh for each test
  late _MockAccounts accounts; // fresh for each test
  late _MockSubscription subscription; // fresh for each test

  setUpAll(() => registerFallbackValue(const PostDraft()));

  setUp(() {
    media = _MockMedia();
    posts = _MockPosts();
    accounts = _MockAccounts();
    subscription = _MockSubscription();
    when(() => accounts.watchAccounts())
        .thenAnswer((_) => Stream.value(_accounts));
    when(() => subscription.watchSubscription())
        .thenAnswer((_) => Stream.value(const Subscription(plan: proPlan)));
    when(() => subscription.watchUsage())
        .thenAnswer((_) => const Stream.empty());
    when(() => media.upload('g1'))
        .thenAnswer((_) => Stream.value(const Uploaded(_video)));
  });

  ComposerCubit build() => ComposerCubit(
    media: media,
    posts: posts,
    accounts: accounts,
    subscription: subscription,
  );

  blocTest<ComposerCubit, ComposerState>(
    'started follows the accounts and the plan',
    build: build,
    act: (cubit) => cubit.started(),
    verify: (cubit) {
      expect(cubit.state.accounts, _accounts);
      expect(cubit.state.plan, proPlan);
    },
  );

  blocTest<ComposerCubit, ComposerState>(
    'once uploaded, the platforms the video fits are selected',
    build: build,
    act: (cubit) async {
      cubit
        ..started()
        ..uploadStarted(_item);
      await Future<void>.delayed(Duration.zero);
    },
    verify: (cubit) =>
        expect(cubit.state.draft.platforms, {PlatformId.youtube}),
  );

  blocTest<ComposerCubit, ComposerState>(
    'edits update the draft',
    build: build,
    seed: () => const ComposerState(
      draft: PostDraft(video: _video, platforms: {PlatformId.youtube}),
    ),
    act: (cubit) => cubit
      ..captionChanged('Hello')
      ..platformToggled(PlatformId.facebook)
      ..platformToggled(PlatformId.youtube)
      ..coverChanged(const Duration(seconds: 4))
      ..tiktokChanged(const TikTokSettings(privacy: TikTokPrivacy.friends)),
    verify: (cubit) {
      final draft = cubit.state.draft;
      expect(draft.caption, 'Hello');
      expect(draft.platforms, {PlatformId.facebook});
      expect(draft.coverAt, const Duration(seconds: 4));
      expect(draft.tiktok.privacy, TikTokPrivacy.friends);
    },
  );

  blocTest<ComposerCubit, ComposerState>(
    'closeTapped saves a draft with a video and remembers its id',
    setUp: () =>
        when(() => posts.saveDraft(any(), draftId: any(named: 'draftId')))
            .thenAnswer(
              (_) async => Post(
                id: 'draft-9',
                video: _video,
                caption: '',
                isDraft: true,
                createdAt: DateTime(2026),
                updatedAt: DateTime(2026),
              ),
            ),
    build: build,
    seed: () => const ComposerState(draft: PostDraft(video: _video)),
    act: (cubit) async => expect(await cubit.closeTapped(), isTrue),
    verify: (cubit) {
      verify(() => posts.saveDraft(const PostDraft(video: _video))).called(1);
      expect(cubit.state.draftId, 'draft-9');
    },
  );

  blocTest<ComposerCubit, ComposerState>(
    'closeTapped without a video saves nothing',
    build: build,
    act: (cubit) async => expect(await cubit.closeTapped(), isFalse),
    verify: (_) => verifyNever(
      () => posts.saveDraft(any(), draftId: any(named: 'draftId')),
    ),
  );

  blocTest<ComposerCubit, ComposerState>(
    'a failed save still lets the composer close',
    setUp: () =>
        when(() => posts.saveDraft(any(), draftId: any(named: 'draftId')))
            .thenThrow(const NetworkFailure()),
    build: build,
    seed: () => const ComposerState(draft: PostDraft(video: _video)),
    act: (cubit) async => expect(await cubit.closeTapped(), isFalse),
  );
}
