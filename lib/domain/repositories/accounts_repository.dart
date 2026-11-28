import 'package:pushit/domain/entities/connected_account.dart';
import 'package:pushit/domain/enums/account_mode.dart';
import 'package:pushit/domain/enums/platform_id.dart';

/// The creator's connected platform accounts. Methods throw `AppFailure`;
/// [connect] throws `LimitReachedFailure` at the plan's account limit.
abstract interface class AccountsRepository {
  Stream<List<ConnectedAccount>> watchAccounts();

  Future<ConnectedAccount> connect(PlatformId platform, AccountMode mode);

  Future<void> reconnect(String accountId);

  Future<void> disconnect(String accountId);
}
