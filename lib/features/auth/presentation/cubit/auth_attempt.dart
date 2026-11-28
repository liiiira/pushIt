import 'package:pushit/core/failures.dart';

/// Runs one auth call for a form cubit and returns its failure, or `null`
/// on success. Success needs no state: the router leaves the screen once
/// `AuthRepository.watchUser` reports the user (`appRedirect`).
Future<AppFailure?> attemptAuth(Future<void> Function() call) async {
  try {
    await call();
    return null;
  } on AppFailure catch (failure) {
    return failure;
  }
}
