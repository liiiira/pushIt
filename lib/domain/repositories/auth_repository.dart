import 'package:pushit/domain/entities/user.dart';

/// Sign-in and the account of the creator. Methods throw `AppFailure`.
abstract interface class AuthRepository {
  /// The signed-in user, or `null` when signed out. Emits on every change.
  Stream<User?> watchUser();

  Future<void> signIn({required String email, required String password});

  Future<void> signInWithGoogle();

  Future<void> register({
    required String name,
    required String email,
    required String password,
  });

  Future<void> resendVerification();

  Future<void> sendPasswordReset({required String email});

  Future<void> signOut();

  Future<void> deleteAccount();
}
