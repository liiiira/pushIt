import 'package:pushit/domain/entities/notification_preferences.dart';

/// Methods throw `AppFailure`.
abstract interface class NotificationSettingsRepository {
  Future<NotificationPreferences> load();

  Future<void> save(NotificationPreferences preferences);
}
