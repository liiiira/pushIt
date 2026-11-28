part of 'sign_in_cubit.dart';

final class SignInState extends Equatable {
  const new({
    this.email = '',
    this.password = '',
    this.showsErrors = false,
    this.isSubmitting = false,
    this.failure,
  });

  final String email;
  final String password;

  /// From the first try on, the fields show what is wrong as the user
  /// types.
  final bool showsErrors;
  final bool isSubmitting;

  /// Why the last try failed.
  final AppFailure? failure;

  bool get isValid =>
      validateEmail(email) == null && validatePassword(password) == null;

  EmailError? get emailError => showsErrors ? validateEmail(email) : null;

  PasswordError? get passwordError =>
      showsErrors ? validatePassword(password) : null;

  SignInState copyWith({
    String? email,
    String? password,
    bool? showsErrors,
    bool? isSubmitting,
    AppFailure? Function()? failure,
  }) => SignInState(
    email: email ?? this.email,
    password: password ?? this.password,
    showsErrors: showsErrors ?? this.showsErrors,
    isSubmitting: isSubmitting ?? this.isSubmitting,
    failure: failure != null ? failure() : this.failure,
  );

  @override
  List<Object?> get props => [
    email,
    password,
    showsErrors,
    isSubmitting,
    failure,
  ];
}
