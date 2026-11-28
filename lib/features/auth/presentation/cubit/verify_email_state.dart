part of 'verify_email_cubit.dart';

final class VerifyEmailState extends Equatable {
  const new({
    required this.secondsLeft,
    this.email,
    this.isSending = false,
    this.failure,
  });

  /// Where the link went; `null` until the user is known.
  final String? email;

  /// Before the link can be sent again.
  final int secondsLeft;
  final bool isSending;

  /// Why the last send or sign-out failed.
  final AppFailure? failure;

  bool get canResend => secondsLeft <= 0 && !isSending;

  VerifyEmailState copyWith({
    String? Function()? email,
    int? secondsLeft,
    bool? isSending,
    AppFailure? Function()? failure,
  }) => VerifyEmailState(
    email: email != null ? email() : this.email,
    secondsLeft: secondsLeft ?? this.secondsLeft,
    isSending: isSending ?? this.isSending,
    failure: failure != null ? failure() : this.failure,
  );

  @override
  List<Object?> get props => [email, secondsLeft, isSending, failure];
}
