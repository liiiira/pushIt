import 'package:pushit/core/failures.dart';
import 'package:pushit/core/l10n/l10n.dart';
import 'package:pushit/features/auth/domain/auth_validators.dart';

/// Phrases the auth forms' errors.
extension AuthLabels on AppLocalizations {
  String emailErrorText(EmailError error) => switch (error) {
    EmailError.empty => authEmailEmpty,
    EmailError.invalid => authEmailInvalid,
  };

  /// [isNew]: the password of a new account (A6).
  String passwordErrorText(PasswordError error, {bool isNew = false}) =>
      switch (error) {
        PasswordError.empty => isNew ? authNewPasswordEmpty : authPasswordEmpty,
        PasswordError.tooShort => authPasswordTooShort(minPasswordLength),
      };

  String nameErrorText(NameError error) => switch (error) {
    NameError.empty => authNameEmpty,
  };

  /// Why an auth call failed; [rejected] says what a `ValidationFailure`
  /// means on this screen.
  String authFailureText(AppFailure failure, {required String rejected}) =>
      switch (failure) {
        ValidationFailure() => rejected,
        NetworkFailure() => authErrorNetwork,
        _ => authErrorUnknown,
      };
}
