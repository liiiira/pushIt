part of 'register_cubit.dart';

final class RegisterState extends Equatable {
  const new({
    this.name = '',
    this.email = '',
    this.password = '',
    this.hasAcceptedTerms = false,
    this.showsErrors = false,
    this.isSubmitting = false,
    this.failure,
  });

  final String name;
  final String email;
  final String password;
  final bool hasAcceptedTerms;

  /// From the first try on, the form shows what is wrong as the user types.
  final bool showsErrors;
  final bool isSubmitting;

  /// Why the last try failed.
  final AppFailure? failure;

  bool get isValid =>
      validateName(name) == null &&
      validateEmail(email) == null &&
      validateNewPassword(password) == null &&
      hasAcceptedTerms;

  NameError? get nameError => showsErrors ? validateName(name) : null;

  EmailError? get emailError => showsErrors ? validateEmail(email) : null;

  PasswordError? get passwordError =>
      showsErrors ? validateNewPassword(password) : null;

  /// Whether to ask for the terms box.
  bool get needsTerms => showsErrors && !hasAcceptedTerms;

  RegisterState copyWith({
    String? name,
    String? email,
    String? password,
    bool? hasAcceptedTerms,
    bool? showsErrors,
    bool? isSubmitting,
    AppFailure? Function()? failure,
  }) => RegisterState(
    name: name ?? this.name,
    email: email ?? this.email,
    password: password ?? this.password,
    hasAcceptedTerms: hasAcceptedTerms ?? this.hasAcceptedTerms,
    showsErrors: showsErrors ?? this.showsErrors,
    isSubmitting: isSubmitting ?? this.isSubmitting,
    failure: failure != null ? failure() : this.failure,
  );

  @override
  List<Object?> get props => [
    name,
    email,
    password,
    hasAcceptedTerms,
    showsErrors,
    isSubmitting,
    failure,
  ];
}
