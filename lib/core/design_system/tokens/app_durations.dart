/// Animation and simulated-latency durations (docs/DESIGN_TOKENS.md).
abstract final class AppDurations {
  static const fast = Duration(milliseconds: 150);
  static const normal = Duration(milliseconds: 250);
  static const slow = Duration(milliseconds: 400);

  /// Latency of every fake repository call.
  static const fakeLatency = Duration(milliseconds: 400);

  /// Latency of every fake repository call in the `slow` scenario.
  static const fakeLatencySlow = Duration(seconds: 2);
}
