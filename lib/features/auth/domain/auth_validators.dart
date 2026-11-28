/// Form checks for sign-in and registration (A5, A6, A8). They return what
/// is wrong as an enum, or `null` when the value is fine; views turn that
/// into text.
library;

/// The shortest password a new account may have.
const int minPasswordLength = 8;

enum EmailError { empty, invalid }

enum PasswordError { empty, tooShort }

enum NameError { empty }

// One `@`, no spaces, and a dot in the domain.
final RegExp _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

EmailError? validateEmail(String email) {
  final trimmed = email.trim();
  if (trimmed.isEmpty) return EmailError.empty;
  return _email.hasMatch(trimmed) ? null : EmailError.invalid;
}

/// The password of a new account: at least [minPasswordLength] characters.
PasswordError? validateNewPassword(String password) {
  if (password.isEmpty) return PasswordError.empty;
  return password.length < minPasswordLength ? PasswordError.tooShort : null;
}

/// The password to sign in with: only required, since older accounts may
/// have shorter ones.
PasswordError? validatePassword(String password) =>
    password.isEmpty ? PasswordError.empty : null;

NameError? validateName(String name) =>
    name.trim().isEmpty ? NameError.empty : null;
