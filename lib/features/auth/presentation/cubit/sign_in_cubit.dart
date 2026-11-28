import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pushit/core/failures.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/auth/domain/auth_validators.dart';
import 'package:pushit/features/auth/presentation/cubit/auth_attempt.dart';

part 'sign_in_state.dart';

/// A5: email and password, or Google.
class SignInCubit extends Cubit<SignInState> {
  new({required this._auth}) : super(const SignInState());

  final AuthRepository _auth;

  void emailChanged(String email) =>
      emit(state.copyWith(email: email, failure: () => null));

  void passwordChanged(String password) =>
      emit(state.copyWith(password: password, failure: () => null));

  /// Signs in, or shows what is wrong with the form.
  Future<void> submitted() async {
    if (state.isSubmitting) return;
    if (!state.isValid) return emit(state.copyWith(showsErrors: true));
    await _attempt(
      () => _auth.signIn(email: state.email.trim(), password: state.password),
    );
  }

  Future<void> googleTapped() async {
    if (state.isSubmitting) return;
    await _attempt(_auth.signInWithGoogle);
  }

  Future<void> _attempt(Future<void> Function() call) async {
    emit(state.copyWith(isSubmitting: true, failure: () => null));
    final failure = await attemptAuth(call);
    if (isClosed) return;
    emit(state.copyWith(isSubmitting: false, failure: () => failure));
  }
}
