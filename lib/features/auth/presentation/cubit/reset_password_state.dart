part of 'reset_password_cubit.dart';

final class ResetPasswordState extends Equatable {
  const new({
    this.email = '',
    this.showsErrors = false,
    this.isSubmitting = false,
    this.failure,
    this.sentTo,
  });

  final String email;

  /// From the first try on, the field shows what is wrong as the user types.
  final bool showsErrors;
  final bool isSubmitting;

  /// Why the last try failed.
  final AppFailure? failure;

  /// Where the link went, once sent.
  final String? sentTo;

  bool get isSent => sentTo != null;

  EmailError? get emailError => showsErrors ? validateEmail(email) : null;

  ResetPasswordState copyWith({
    String? email,
    bool? showsErrors,
    bool? isSubmitting,
    AppFailure? Function()? failure,
    String? Function()? sentTo,
  }) => ResetPasswordState(
    email: email ?? this.email,
    showsErrors: showsErrors ?? this.showsErrors,
    isSubmitting: isSubmitting ?? this.isSubmitting,
    failure: failure != null ? failure() : this.failure,
    sentTo: sentTo != null ? sentTo() : this.sentTo,
  );

  @override
  List<Object?> get props => [
    email,
    showsErrors,
    isSubmitting,
    failure,
    sentTo,
  ];
}
