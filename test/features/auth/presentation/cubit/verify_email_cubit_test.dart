import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pushit/core/failures.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/auth/domain/auth_validators.dart';
import 'package:pushit/features/auth/presentation/cubit/verify_email_cubit.dart';

class _MockAuth extends Mock implements AuthRepository;

const _user = User(
  id: 'u1',
  name: 'Lyes B.',
  email: 'lyes@example.com',
  isEmailVerified: false,
);

void main() {
  late _MockAuth auth; // fresh for each test
  late StreamController<void> ticks; // fresh for each test
  late VerifyEmailCubit cubit; // fresh for each test

  setUp(() {
    auth = _MockAuth();
    when(auth.watchUser).thenAnswer((_) => Stream.value(_user));
    when(auth.resendVerification).thenAnswer((_) async {});
    when(auth.signOut).thenAnswer((_) async {});
    ticks = StreamController.broadcast();
    cubit = VerifyEmailCubit(auth: auth, ticks: () => ticks.stream);
  });

  tearDown(() async {
    await cubit.close();
    await ticks.close();
  });

  Future<void> tick([int times = 1]) async {
    for (var i = 0; i < times; i++) {
      ticks.add(null);
      await pumpEventQueue();
    }
  }

  test('shows the email and counts down from the cooldown', () async {
    expect(resendCooldown, const Duration(seconds: 60));

    cubit.started();
    await pumpEventQueue();

    expect(cubit.state.email, 'lyes@example.com');
    expect(cubit.state.secondsLeft, 60);
    expect(cubit.state.canResend, isFalse);

    await tick(18);
    expect(cubit.state.secondsLeft, 42);
  });

  test('lets the user send again once the countdown is over', () async {
    cubit.started();
    await tick(60);
    expect(cubit.state.secondsLeft, 0);
    expect(cubit.state.canResend, isTrue);

    await tick();
    expect(cubit.state.secondsLeft, 0, reason: 'stops at zero');
  });

  test('sends again, then counts down anew', () async {
    cubit.started();
    await tick(60);

    await cubit.resendTapped();

    verify(auth.resendVerification).called(1);
    expect(cubit.state.secondsLeft, 60);
    expect(cubit.state.isSending, isFalse);
    await tick();
    expect(cubit.state.secondsLeft, 59);
  });

  test('does not send again during the countdown', () async {
    cubit.started();

    await cubit.resendTapped();

    verifyNever(auth.resendVerification);
  });

  test('keeps the failure and lets the user try again', () async {
    when(auth.resendVerification).thenThrow(const NetworkFailure());
    cubit.started();
    await tick(60);

    await cubit.resendTapped();

    expect(cubit.state.failure, const NetworkFailure());
    expect(cubit.state.canResend, isTrue);
  });

  test('the back arrow signs out; the router then opens sign-in', () async {
    cubit.started();

    await cubit.backTapped();

    verify(auth.signOut).called(1);
  });
}
