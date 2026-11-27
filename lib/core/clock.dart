/// The source of the current time.
///
/// Inject it instead of calling `DateTime.now()`, so tests and fake data can
/// pin time with [FixedClock].
abstract interface class Clock {
  DateTime now();
}

/// The device clock.
final class SystemClock implements Clock {
  const new();

  @override
  DateTime now() => DateTime.now();
}

/// A clock frozen at one instant, for tests and fixtures.
final class FixedClock implements Clock {
  const new(this._instant);

  final DateTime _instant;

  @override
  DateTime now() => _instant;
}
