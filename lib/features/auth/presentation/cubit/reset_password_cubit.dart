import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pushit/core/failures.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/auth/domain/auth_validators.dart';
import 'package:pushit/features/auth/presentation/cubit/auth_attempt.dart';

part 'reset_password_state.dart';

/// A8: sends a link to choose a new password, then confirms where it went.
class ResetPasswordCubit extends Cubit<ResetPasswordState> {
  new({required this._auth}) : super(const ResetPasswordState());

  final AuthRepository _auth;

  void emailChanged(String email) =>
      emit(state.copyWith(email: email, failure: () => null));

  Future<void> submitted() async {
    if (state.isSubmitting) return;
    if (validateEmail(state.email) != null) {
      return emit(state.copyWith(showsErrors: true));
    }
    final email = state.email.trim();
    emit(state.copyWith(isSubmitting: true, failure: () => null));
    final failure = await attemptAuth(
      () => _auth.sendPasswordReset(email: email),
    );
    if (isClosed) return;
    emit(
      state.copyWith(
        isSubmitting: false,
        failure: () => failure,
        sentTo: () => failure == null ? email : null,
      ),
    );
  }
}
