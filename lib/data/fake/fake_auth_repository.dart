import 'package:pushit/core/failures.dart';
import 'package:pushit/data/fake/fake_database.dart';
import 'package:pushit/data/fake/fake_store.dart';
import 'package:pushit/data/fake/fixtures/fixture_user.dart';
import 'package:pushit/domain/domain.dart';

/// Starts signed out in every scenario; any non-empty credentials sign in
/// as the fixture user.
final class FakeAuthRepository implements AuthRepository {
  new(this._database);

  final FakeDatabase _database;
  final FakeStore<User?> _user = FakeStore(null);

  @override
  Stream<User?> watchUser() => _database.watch(_user);

  @override
  Future<void> signIn({required String email, required String password}) =>
      _database.act(() {
        if (email.trim().isEmpty || password.isEmpty) {
          throw const ValidationFailure();
        }
        _user.value = fixtureUser.copyWith(email: email.trim());
      });

  @override
  Future<void> signInWithGoogle() =>
      _database.act(() => _user.value = fixtureUser);

  @override
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) => _database.act(() {
    if (name.trim().isEmpty || email.trim().isEmpty || password.isEmpty) {
      throw const ValidationFailure();
    }
    _user.value = fixtureUser.copyWith(
      name: name.trim(),
      email: email.trim(),
      isEmailVerified: false,
    );
  });

  @override
  Future<void> resendVerification() => _database.act(() {
    if (_user.value == null) throw const ValidationFailure();
  });

  @override
  Future<void> sendPasswordReset({required String email}) => _database.act(() {
    if (!email.contains('@')) throw const ValidationFailure();
  });

  @override
  Future<void> signOut() => _database.act(() => _user.value = null);

  @override
  Future<void> deleteAccount() => _database.act(() => _user.value = null);
}
