/// The fake-data scenarios (`--dart-define=SCENARIO=<name>`).
///
/// See docs/ARCHITECTURE.md §Scenarios for what each one reveals.
enum Scenario {
  /// Pro plan, 4 of 10 accounts, the posts and drafts from the designs.
  populated,

  /// Signed in, no accounts, no posts.
  firstUse,

  /// Free plan, 3 of 3 accounts, 10 of 10 videos this month.
  freeLimit,

  /// Offline, with the populated data cached.
  offline,

  /// List loads throw `NetworkFailure`.
  error,

  /// Two seconds of latency on every call.
  slow;

  /// The scenario called [name], or [populated] when unknown.
  static Scenario fromName(String name) =>
      values.where((s) => s.name == name).firstOrNull ?? populated;
}
