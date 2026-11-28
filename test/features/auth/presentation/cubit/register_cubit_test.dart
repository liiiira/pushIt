import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pushit/core/failures.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/auth/domain/auth_validators.dart';
import 'package:pushit/features/auth/presentation/cubit/register_cubit.dart';

class _MockAuth extends Mock implements AuthRepository;

void main() {
  late _MockAuth auth; // fresh for each test

  setUp(() {
    auth = _MockAuth();
    when(
      () => auth.register(
        name: any(named: 'name'),
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async {});
    when(auth.signInWithGoogle).thenAnswer((_) async {});
  });

  const filled = RegisterState(
    name: 'Lyes B.',
    email: 'lyes@example.com',
    password: 'longenough',
    hasAcceptedTerms: true,
  );

  blocTest<RegisterCubit, RegisterState>(
    'keeps what the user enters; the terms start unticked',
    build: () => RegisterCubit(auth: auth),
    act: (cubit) => cubit
      ..nameChanged('Lyes B.')
      ..emailChanged('lyes@example.com')
      ..passwordChanged('longenough')
      ..termsChanged(isAccepted: true),
    expect: () => const [
      RegisterState(name: 'Lyes B.'),
      RegisterState(name: 'Lyes B.', email: 'lyes@example.com'),
      RegisterState(
        name: 'Lyes B.',
        email: 'lyes@example.com',
        password: 'longenough',
      ),
      filled,
    ],
  );

  blocTest<RegisterCubit, RegisterState>(
    'shows every error instead of registering an invalid form',
    build: () => RegisterCubit(auth: auth),
    seed: () => const RegisterState(email: 'lyes@', password: 'short'),
    act: (cubit) => cubit.submitted(),
    expect: () => const [
      RegisterState(email: 'lyes@', password: 'short', showsErrors: true),
    ],
    verify: (cubit) {
      expect(cubit.state.nameError, NameError.empty);
      expect(cubit.state.emailError, EmailError.invalid);
      expect(cubit.state.passwordError, PasswordError.tooShort);
      expect(cubit.state.needsTerms, isTrue);
      verifyNever(
        () => auth.register(
          name: any(named: 'name'),
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
    },
  );

  blocTest<RegisterCubit, RegisterState>(
    'registers with the trimmed name and email; the router then leaves',
    build: () => RegisterCubit(auth: auth),
    seed: () => filled.copyWith(name: ' Lyes B. ', email: 'lyes@example.com '),
    act: (cubit) => cubit.submitted(),
    expect: () => [
      filled.copyWith(
        name: ' Lyes B. ',
        email: 'lyes@example.com ',
        isSubmitting: true,
      ),
      filled.copyWith(name: ' Lyes B. ', email: 'lyes@example.com '),
    ],
    verify: (_) => verify(
      () => auth.register(
        name: 'Lyes B.',
        email: 'lyes@example.com',
        password: 'longenough',
      ),
    ).called(1),
  );

  blocTest<RegisterCubit, RegisterState>(
    'keeps the failure to show it',
    build: () {
      when(
        () => auth.register(
          name: any(named: 'name'),
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(const NetworkFailure());
      return RegisterCubit(auth: auth);
    },
    seed: () => filled,
    act: (cubit) => cubit.submitted(),
    expect: () => [
      filled.copyWith(isSubmitting: true),
      filled.copyWith(failure: () => const NetworkFailure()),
    ],
  );

  blocTest<RegisterCubit, RegisterState>(
    'continues with Google, terms or not',
    build: () => RegisterCubit(auth: auth),
    act: (cubit) => cubit.googleTapped(),
    expect: () => const [RegisterState(isSubmitting: true), RegisterState()],
    verify: (_) => verify(auth.signInWithGoogle).called(1),
  );
}
