import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pushit/features/onboarding/presentation/cubit/onboarding_cubit.dart';

import '../../../../helpers/helpers.dart';

void main() {
  late InMemoryAppPreferences preferences; // fresh for each test

  setUp(() => preferences = InMemoryAppPreferences());

  test('starts on the first of three pages', () {
    final cubit = OnboardingCubit(preferences: preferences);
    addTearDown(cubit.close);

    expect(cubit.state, const OnboardingState());
    expect(cubit.state.page, 0);
    expect(cubit.state.isLastPage, isFalse);
    expect(OnboardingCubit.pageCount, 3);
  });

  blocTest<OnboardingCubit, OnboardingState>(
    'Next moves one page on',
    build: () => OnboardingCubit(preferences: preferences),
    act: (cubit) async {
      await cubit.nextTapped();
      await cubit.nextTapped();
    },
    expect: () => const [OnboardingState(page: 1), OnboardingState(page: 2)],
    verify: (cubit) {
      expect(cubit.state.isLastPage, isTrue);
      expect(preferences.isOnboarded, isFalse);
    },
  );

  blocTest<OnboardingCubit, OnboardingState>(
    'follows a swipe',
    build: () => OnboardingCubit(preferences: preferences),
    act: (cubit) => cubit.pageChanged(2),
    expect: () => const [OnboardingState(page: 2)],
  );

  blocTest<OnboardingCubit, OnboardingState>(
    'the last page finishes the onboarding',
    build: () => OnboardingCubit(preferences: preferences),
    seed: () => const OnboardingState(page: 2),
    act: (cubit) => cubit.nextTapped(),
    expect: () => const <OnboardingState>[],
    verify: (_) => expect(preferences.isOnboarded, isTrue),
  );

  blocTest<OnboardingCubit, OnboardingState>(
    'Skip finishes the onboarding from any page',
    build: () => OnboardingCubit(preferences: preferences),
    act: (cubit) => cubit.skipTapped(),
    expect: () => const <OnboardingState>[],
    verify: (_) => expect(preferences.isOnboarded, isTrue),
  );
}
