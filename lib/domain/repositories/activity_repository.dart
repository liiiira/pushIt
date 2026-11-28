import 'package:pushit/domain/entities/activity_item.dart';

/// Past notifications, newest first, kept 30 days. Throws `AppFailure`.
abstract interface class ActivityRepository {
  Stream<List<ActivityItem>> watchActivity();
}
