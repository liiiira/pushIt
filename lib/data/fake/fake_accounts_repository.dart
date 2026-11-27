import 'package:pushit/core/failures.dart';
import 'package:pushit/data/fake/fake_database.dart';
import 'package:pushit/data/fake/fixtures/fixture_accounts.dart';
import 'package:pushit/domain/domain.dart';

final class FakeAccountsRepository implements AccountsRepository {
  const new(this._database);

  final FakeDatabase _database;

  @override
  Stream<List<ConnectedAccount>> watchAccounts() =>
      _database.watchLoad(_database.accounts);

  @override
  Future<ConnectedAccount> connect(PlatformId platform, AccountMode mode) =>
      _database.act(() {
        final accounts = _database.accounts.value;
        if (isAccountLimitReached(
          _database.subscription.value.plan,
          connectedAccounts: accounts.length,
        )) {
          throw const LimitReachedFailure();
        }
        final account = fixtureNewAccount(
          id: _database.newId('acc'),
          platform: platform,
          mode: mode,
          now: _database.now(),
        );
        _database.accounts.value = List.unmodifiable([...accounts, account]);
        return account;
      });

  @override
  Future<void> reconnect(String accountId) => _database.act(
    () => _update(
      accountId,
      (account) => account.copyWith(
        health: AccountHealth.connected,
        signInExpiresAt: () => _database.now().add(const Duration(days: 60)),
      ),
    ),
  );

  @override
  Future<void> disconnect(String accountId) => _database.act(() {
    _find(accountId);
    _database.accounts.value = List.unmodifiable(
      _database.accounts.value.where((a) => a.id != accountId),
    );
  });

  ConnectedAccount _find(String accountId) =>
      _database.accounts.value.where((a) => a.id == accountId).firstOrNull ??
      (throw const NotFoundFailure());

  void _update(
    String accountId,
    ConnectedAccount Function(ConnectedAccount) change,
  ) {
    _find(accountId);
    _database.accounts.value = List.unmodifiable([
      for (final account in _database.accounts.value)
        if (account.id == accountId) change(account) else account,
    ]);
  }
}
