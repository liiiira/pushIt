import 'package:equatable/equatable.dart';

/// Which notifications the creator wants (H4).
final class NotificationPreferences extends Equatable {
  const new({
    required this.published,
    required this.failed,
    required this.reconnectReminders,
    required this.assisted,
    required this.weeklyPlan,
  });

  final bool published;
  final bool failed;
  final bool reconnectReminders;
  final bool assisted;
  final bool weeklyPlan;

  NotificationPreferences copyWith({
    bool? published,
    bool? failed,
    bool? reconnectReminders,
    bool? assisted,
    bool? weeklyPlan,
  }) => NotificationPreferences(
    published: published ?? this.published,
    failed: failed ?? this.failed,
    reconnectReminders: reconnectReminders ?? this.reconnectReminders,
    assisted: assisted ?? this.assisted,
    weeklyPlan: weeklyPlan ?? this.weeklyPlan,
  );

  @override
  List<Object?> get props => [
    published,
    failed,
    reconnectReminders,
    assisted,
    weeklyPlan,
  ];
}
