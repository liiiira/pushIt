import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pushit/core/failures.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/auth/domain/auth_validators.dart';
import 'package:pushit/features/auth/presentation/cubit/auth_attempt.dart';

part 'register_state.dart';

/// A6: name, email, password and the terms, or Google.
class RegisterCubit extends Cubit<RegisterState> {
  new({required this._auth}) : super(const RegisterState());

  final AuthRepository _auth;

  void nameChanged(String name) =>
      emit(state.copyWith(name: name, failure: () => null));

  void emailChanged(String email) =>
      emit(state.copyWith(email: email, failure: () => null));

  void passwordChanged(String password) =>
      emit(state.copyWith(password: password, failure: () => null));

  void termsChanged({required bool isAccepted}) =>
      emit(state.copyWith(hasAcceptedTerms: isAccepted, failure: () => null));

  /// Creates the account, or shows what is wrong with the form. The new
  /// account is signed in, unverified: the router then opens verify email.
  Future<void> submitted() async {
    if (state.isSubmitting) return;
    if (!state.isValid) return emit(state.copyWith(showsErrors: true));
    await _attempt(
      () => _auth.register(
        name: state.name.trim(),
        email: state.email.trim(),
        password: state.password,
      ),
    );
  }

  /// Google needs no terms box: its own consent screen covers it.
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
