import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pushit/core/failures.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/auth/domain/auth_validators.dart';
import 'package:pushit/features/auth/presentation/cubit/auth_attempt.dart';

part 'verify_email_state.dart';

/// A7: the email the link went to, and a countdown before it can be sent
/// again.
class VerifyEmailCubit extends Cubit<VerifyEmailState> {
  /// [ticks] fires once a second (tests pass their own).
  new({required this._auth, Stream<void> Function()? ticks})
    : _ticks = ticks ?? _everySecond,
      super(VerifyEmailState(secondsLeft: resendCooldown.inSeconds));

  static Stream<void> _everySecond() =>
      Stream<void>.periodic(const Duration(seconds: 1));

  final AuthRepository _auth;
  final Stream<void> Function() _ticks;
  StreamSubscription<User?>? _user;
  StreamSubscription<void>? _countdown;

  /// The link was just sent (A6), so the countdown starts at once.
  void started() {
    _user = _auth.watchUser().listen(
      (user) => emit(state.copyWith(email: () => user?.email)),
    );
    _startCountdown();
  }

  Future<void> resendTapped() async {
    if (!state.canResend) return;
    emit(state.copyWith(isSending: true, failure: () => null));
    final failure = await attemptAuth(_auth.resendVerification);
    if (isClosed) return;
    emit(state.copyWith(isSending: false, failure: () => failure));
    if (failure == null) _startCountdown();
  }

  /// Leaves by signing out: the account is not finished until verified,
  /// and the router then opens sign-in.
  Future<void> backTapped() async {
    final failure = await attemptAuth(_auth.signOut);
    if (isClosed || failure == null) return;
    emit(state.copyWith(failure: () => failure));
  }

  void _startCountdown() {
    unawaited(_countdown?.cancel());
    emit(state.copyWith(secondsLeft: resendCooldown.inSeconds));
    _countdown = _ticks().listen((_) {
      final secondsLeft = state.secondsLeft - 1;
      emit(state.copyWith(secondsLeft: secondsLeft));
      if (secondsLeft <= 0) unawaited(_countdown?.cancel());
    });
  }

  @override
  Future<void> close() async {
    await _user?.cancel();
    await _countdown?.cancel();
    await super.close();
  }
}
