import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pushit/core/failures.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/auth/domain/auth_validators.dart';
import 'package:pushit/features/auth/presentation/cubit/sign_in_cubit.dart';

class _MockAuth extends Mock implements AuthRepository;

void main() {
  late _MockAuth auth; // fresh for each test

  setUp(() {
    auth = _MockAuth();
    when(
      () => auth.signIn(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async {});
    when(auth.signInWithGoogle).thenAnswer((_) async {});
  });

  const filled = SignInState(email: 'lyes@example.com', password: 'secret');

  test('shows no error before the first try', () {
    const state = SignInState();
    expect(state.emailError, isNull);
    expect(state.passwordError, isNull);
  });

  blocTest<SignInCubit, SignInState>(
    'keeps what the user types',
    build: () => SignInCubit(auth: auth),
    act: (cubit) => cubit
      ..emailChanged('lyes@example.com')
      ..passwordChanged('secret'),
    expect: () => const [SignInState(email: 'lyes@example.com'), filled],
  );

  blocTest<SignInCubit, SignInState>(
    'shows the errors instead of signing in with an invalid form',
    build: () => SignInCubit(auth: auth),
    seed: () => const SignInState(email: 'lyes'),
    act: (cubit) => cubit.submitted(),
    expect: () => const [SignInState(email: 'lyes', showsErrors: true)],
    verify: (cubit) {
      expect(cubit.state.emailError, EmailError.invalid);
      expect(cubit.state.passwordError, PasswordError.empty);
      verifyNever(
        () => auth.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
    },
  );

  blocTest<SignInCubit, SignInState>(
    'signs in with the trimmed email; the router then leaves',
    build: () => SignInCubit(auth: auth),
    seed: () => filled.copyWith(email: ' lyes@example.com '),
    act: (cubit) => cubit.submitted(),
    expect: () => [
      filled.copyWith(email: ' lyes@example.com ', isSubmitting: true),
      filled.copyWith(email: ' lyes@example.com '),
    ],
    verify: (_) =>
        verify(() => auth.signIn(email: 'lyes@example.com', password: 'secret'))
            .called(1),
  );

  blocTest<SignInCubit, SignInState>(
    'keeps the failure to show it',
    build: () {
      when(
        () => auth.signIn(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(const ValidationFailure());
      return SignInCubit(auth: auth);
    },
    seed: () => filled,
    act: (cubit) => cubit.submitted(),
    expect: () => [
      filled.copyWith(isSubmitting: true),
      filled.copyWith(failure: () => const ValidationFailure()),
    ],
  );

  blocTest<SignInCubit, SignInState>(
    'forgets the failure when the user edits',
    build: () => SignInCubit(auth: auth),
    seed: () => filled.copyWith(failure: () => const NetworkFailure()),
    act: (cubit) => cubit.passwordChanged('secret2'),
    expect: () => [filled.copyWith(password: 'secret2')],
  );

  blocTest<SignInCubit, SignInState>(
    'continues with Google',
    build: () => SignInCubit(auth: auth),
    act: (cubit) => cubit.googleTapped(),
    expect: () => const [SignInState(isSubmitting: true), SignInState()],
    verify: (_) => verify(auth.signInWithGoogle).called(1),
  );

  test('ignores taps while signing in, and the result once closed', () async {
    final pending = Completer<void>();
    when(auth.signInWithGoogle).thenAnswer((_) => pending.future);
    final cubit = SignInCubit(auth: auth)..emit(filled);

    unawaited(cubit.googleTapped());
    await cubit.submitted();
    await cubit.close();
    pending.complete();
    await pumpEventQueue();

    verify(auth.signInWithGoogle).called(1);
    verifyNever(
      () => auth.signIn(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    );
  });
}
