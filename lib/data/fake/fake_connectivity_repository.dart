import 'package:pushit/data/fake/fake_database.dart';
import 'package:pushit/domain/domain.dart';

/// Offline only in the offline scenario, unless [setOnline] changes it.
final class FakeConnectivityRepository implements ConnectivityRepository {
  const new(this._database);

  final FakeDatabase _database;

  @override
  Stream<bool> watchOnline() => _database.online.watch();

  /// For the Developer menu: simulate losing or regaining the connection.
  // A setter would hide that this is a simulation hook.
  // ignore: use_setters_to_change_properties
  void setOnline({required bool isOnline}) => _database.online.value = isOnline;
}
