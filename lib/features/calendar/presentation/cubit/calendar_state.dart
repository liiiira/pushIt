part of 'calendar_cubit.dart';

enum CalendarMode { day, week }

final class CalendarState extends Equatable {
  const new({
    required this.selectedDay,
    this.status = ViewStatus.initial,
    this.posts = const [],
    this.mode = CalendarMode.day,
    this.failure,
    this.actionFailure,
  });

  final ViewStatus status;

  /// Every post but drafts.
  final List<Post> posts;
  final DateTime selectedDay;
  final CalendarMode mode;
  final AppFailure? failure;

  /// Why the last reschedule or cancel was refused; shown once.
  final AppFailure? actionFailure;

  List<DateTime> get week => weekOf(selectedDay);

  List<CalendarEntry> get dayEntries => entriesOn(posts, selectedDay);

  Set<DateTime> get busyDays => daysWithPosts(posts);

  CalendarState copyWith({
    ViewStatus? status,
    List<Post>? posts,
    DateTime? selectedDay,
    CalendarMode? mode,
    AppFailure? Function()? failure,
    AppFailure? Function()? actionFailure,
  }) => CalendarState(
    status: status ?? this.status,
    posts: posts != null ? List.unmodifiable(posts) : this.posts,
    selectedDay: selectedDay ?? this.selectedDay,
    mode: mode ?? this.mode,
    failure: failure != null ? failure() : this.failure,
    actionFailure: actionFailure != null ? actionFailure() : this.actionFailure,
  );

  @override
  List<Object?> get props => [
    status,
    posts,
    selectedDay,
    mode,
    failure,
    actionFailure,
  ];
}
