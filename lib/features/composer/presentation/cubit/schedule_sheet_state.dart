part of 'schedule_sheet_cubit.dart';

enum ScheduleMode { oneTime, perPlatform }

final class ScheduleSheetState extends Equatable {
  const new({
    required this.platforms,
    required this.now,
    required this.oneTime,
    required this.times,
    this.mode = ScheduleMode.oneTime,
    this.editing,
  });

  /// Starts from [initial], or from the default time for every platform.
  factory from(
    Set<PlatformId> platforms, {
    required DateTime now,
    ScheduleChoice? initial,
  }) {
    final ordered = PlatformId.values.where(platforms.contains).toList();
    final fallback = defaultScheduleTime(now);
    final oneTime = switch (initial) {
      SameTime(:final at) => at,
      PerPlatform() =>
        ordered.map(initial.timeFor).nonNulls.firstOrNull ?? fallback,
      null => fallback,
    };
    return ScheduleSheetState(
      platforms: ordered,
      now: now,
      oneTime: oneTime,
      times: {
        for (final platform in ordered)
          platform: initial?.timeFor(platform) ?? oneTime,
      },
      mode: initial is PerPlatform
          ? ScheduleMode.perPlatform
          : ScheduleMode.oneTime,
      editing: ordered.firstOrNull,
    );
  }

  /// The selected platforms, in [PlatformId] order.
  final List<PlatformId> platforms;
  final DateTime now;
  final DateTime oneTime;
  final Map<PlatformId, DateTime> times;
  final ScheduleMode mode;

  /// The platform whose time D10 edits.
  final PlatformId? editing;

  /// The time the picker shows.
  DateTime get current => switch (mode) {
    ScheduleMode.oneTime => oneTime,
    ScheduleMode.perPlatform => times[editing] ?? oneTime,
  };

  ScheduleChoice get choice => switch (mode) {
    ScheduleMode.oneTime => SameTime(oneTime),
    ScheduleMode.perPlatform => PerPlatform(Map.unmodifiable(times)),
  };

  /// Why [choice] cannot be used; `null` when it can.
  ScheduleProblem? get problem =>
      validateSchedule(choice, platforms: platforms.toSet(), now: now);

  ScheduleSheetState copyWith({
    DateTime? oneTime,
    Map<PlatformId, DateTime>? times,
    ScheduleMode? mode,
    PlatformId? editing,
  }) => ScheduleSheetState(
    platforms: platforms,
    now: now,
    oneTime: oneTime ?? this.oneTime,
    times: times != null ? Map.unmodifiable(times) : this.times,
    mode: mode ?? this.mode,
    editing: editing ?? this.editing,
  );

  @override
  List<Object?> get props => [platforms, now, oneTime, times, mode, editing];
}
