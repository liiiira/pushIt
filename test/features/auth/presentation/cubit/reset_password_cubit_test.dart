import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pushit/core/failures.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/auth/domain/auth_validators.dart';
import 'package:pushit/features/auth/presentation/cubit/reset_password_cubit.dart';

class _MockAuth extends Mock implements AuthRepository;

void main() {
  late _MockAuth auth; // fresh for each test

  setUp(() {
    auth = _MockAuth();
    when(() => auth.sendPasswordReset(email: any(named: 'email')))
        .thenAnswer((_) async {});
  });

  blocTest<ResetPasswordCubit, ResetPasswordState>(
    'shows the error instead of sending to an invalid email',
    build: () => ResetPasswordCubit(auth: auth),
    seed: () => const ResetPasswordState(email: 'lyes'),
    act: (cubit) => cubit.submitted(),
    expect: () => const [ResetPasswordState(email: 'lyes', showsErrors: true)],
    verify: (cubit) {
      expect(cubit.state.emailError, EmailError.invalid);
      verifyNever(() => auth.sendPasswordReset(email: any(named: 'email')));
    },
  );

  blocTest<ResetPasswordCubit, ResetPasswordState>(
    'sends the link and says where it went',
    build: () => ResetPasswordCubit(auth: auth),
    act: (cubit) async {
      cubit.emailChanged(' lyes@example.com ');
      await cubit.submitted();
    },
    expect: () => const [
      ResetPasswordState(email: ' lyes@example.com '),
      ResetPasswordState(email: ' lyes@example.com ', isSubmitting: true),
      ResetPasswordState(
        email: ' lyes@example.com ',
        sentTo: 'lyes@example.com',
      ),
    ],
    verify: (cubit) {
      expect(cubit.state.isSent, isTrue);
      verify(() => auth.sendPasswordReset(email: 'lyes@example.com')).called(1);
    },
  );

  blocTest<ResetPasswordCubit, ResetPasswordState>(
    'keeps the failure to show it',
    build: () {
      when(() => auth.sendPasswordReset(email: any(named: 'email')))
          .thenThrow(const NetworkFailure());
      return ResetPasswordCubit(auth: auth);
    },
    seed: () => const ResetPasswordState(email: 'lyes@example.com'),
    act: (cubit) => cubit.submitted(),
    expect: () => const [
      ResetPasswordState(email: 'lyes@example.com', isSubmitting: true),
      ResetPasswordState(email: 'lyes@example.com', failure: NetworkFailure()),
    ],
  );
}
