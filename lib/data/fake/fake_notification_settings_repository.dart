import 'package:pushit/data/fake/fake_database.dart';
import 'package:pushit/domain/domain.dart';

final class FakeNotificationSettingsRepository
    implements NotificationSettingsRepository {
  const new(this._database);

  final FakeDatabase _database;

  @override
  Future<NotificationPreferences> load() =>
      _database.act(() => _database.notificationPreferences.value);

  @override
  Future<void> save(NotificationPreferences preferences) => _database.act(
    () => _database.notificationPreferences.value = preferences,
  );
}
