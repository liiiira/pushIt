import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pushit/core/failures.dart';
import 'package:pushit/core/view_status.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/composer/presentation/cubit/caption_variants_cubit.dart';
import 'package:pushit/features/composer/presentation/cubit/composer_cubit.dart';

class _MockMedia extends Mock implements MediaRepository;

class _MockPosts extends Mock implements PostsRepository;

class _MockAccounts extends Mock implements AccountsRepository;

class _MockSubscription extends Mock implements SubscriptionRepository;

class _MockSuggestions extends Mock implements CaptionSuggestionsRepository;

const _base = ComposerState(
  draft: PostDraft(
    caption: 'Main caption',
    platforms: {PlatformId.youtube, PlatformId.tiktok},
  ),
);

void main() {
  group('ComposerCubit copies', () {
    ComposerCubit build() => ComposerCubit(
      media: _MockMedia(),
      posts: _MockPosts(),
      accounts: _MockAccounts(),
      subscription: _MockSubscription(),
    );

    blocTest<ComposerCubit, ComposerState>(
      'copyChanged sets the title and the text of one platform',
      build: build,
      seed: () => _base,
      act: (cubit) => cubit
        ..copyChanged(PlatformId.youtube, title: 'Studio tour')
        ..copyChanged(PlatformId.youtube, text: 'Description'),
      verify: (cubit) => expect(cubit.state.draft.copies, const [
        PlatformCopy(
          platform: PlatformId.youtube,
          title: 'Studio tour',
          text: 'Description',
        ),
      ]),
    );

    blocTest<ComposerCubit, ComposerState>(
      'a copy that matches the main caption without a title is dropped',
      build: build,
      seed: () => _base,
      act: (cubit) => cubit
        ..copyChanged(PlatformId.tiktok, text: 'Changed')
        ..copyChanged(PlatformId.tiktok, text: 'Main caption'),
      verify: (cubit) => expect(cubit.state.draft.copies, isEmpty),
    );

    blocTest<ComposerCubit, ComposerState>(
      'copyReset goes back to the main caption',
      build: build,
      seed: () => _base,
      act: (cubit) => cubit
        ..copyChanged(PlatformId.tiktok, text: 'Changed')
        ..copyReset(PlatformId.tiktok),
      verify: (cubit) => expect(cubit.state.draft.copies, isEmpty),
    );

    blocTest<ComposerCubit, ComposerState>(
      'suggestionUsed takes the suggested text',
      build: build,
      seed: () => _base,
      act: (cubit) => cubit.suggestionUsed(
        const CaptionSuggestion(platform: PlatformId.tiktok, text: 'POV'),
      ),
      verify: (cubit) => expect(cubit.state.draft.copies, const [
        PlatformCopy(platform: PlatformId.tiktok, text: 'POV'),
      ]),
    );
  });

  group('CaptionVariantsCubit', () {
    late _MockSuggestions suggestions; // fresh for each test

    setUp(() => suggestions = _MockSuggestions());

    const platforms = {PlatformId.youtube};
    const result = [
      CaptionSuggestion(platform: PlatformId.youtube, text: 'Hi #shorts'),
    ];

    CaptionVariantsCubit build() => CaptionVariantsCubit(
      suggestions: suggestions,
      caption: 'Hi',
      platforms: platforms,
    );

    blocTest<CaptionVariantsCubit, CaptionVariantsState>(
      'loads the suggestions',
      setUp: () =>
          when(() => suggestions.suggest('Hi', platforms))
              .thenAnswer((_) async => result),
      build: build,
      act: (cubit) => cubit.started(),
      expect: () => [
        const CaptionVariantsState(status: ViewStatus.loading),
        const CaptionVariantsState(
          status: ViewStatus.ready,
          suggestions: result,
        ),
      ],
    );

    blocTest<CaptionVariantsCubit, CaptionVariantsState>(
      'a plan without variants is a limit failure',
      setUp: () =>
          when(() => suggestions.suggest('Hi', platforms))
              .thenThrow(const LimitReachedFailure()),
      build: build,
      act: (cubit) => cubit.started(),
      skip: 1,
      expect: () => [
        const CaptionVariantsState(
          status: ViewStatus.failure,
          failure: LimitReachedFailure(),
        ),
      ],
    );

    blocTest<CaptionVariantsCubit, CaptionVariantsState>(
      'used marks a suggestion as used',
      build: build,
      seed: () => const CaptionVariantsState(
        status: ViewStatus.ready,
        suggestions: result,
      ),
      act: (cubit) => cubit.used(PlatformId.youtube),
      expect: () => [
        const CaptionVariantsState(
          status: ViewStatus.ready,
          suggestions: result,
          used: {PlatformId.youtube},
        ),
      ],
    );
  });
}
