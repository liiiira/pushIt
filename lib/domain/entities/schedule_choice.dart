import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:pushit/domain/enums/platform_id.dart';

/// When a post goes out: one time for every platform (D9) or a time per
/// platform (D10).
sealed class ScheduleChoice extends Equatable {
  const new();

  /// The time [platform] is scheduled for, or `null` when it has none.
  DateTime? timeFor(PlatformId platform);
}

final class SameTime extends ScheduleChoice {
  const new(this.at);

  final DateTime at;

  @override
  DateTime timeFor(PlatformId platform) => at;

  @override
  List<Object?> get props => [at];
}

final class PerPlatform extends ScheduleChoice {
  const new(Map<PlatformId, DateTime> times) : _times = times;

  final Map<PlatformId, DateTime> _times;

  Map<PlatformId, DateTime> get times => UnmodifiableMapView(_times);

  @override
  DateTime? timeFor(PlatformId platform) => _times[platform];

  @override
  List<Object?> get props => [_times];
}
