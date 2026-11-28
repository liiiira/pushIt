import 'package:pushit/core/clock.dart';
import 'package:pushit/data/fake/fake_database.dart';
import 'package:pushit/data/fake/scenario.dart';

/// Thu 12 Nov 2026, 15:48: the clock every fixture is designed around.
final DateTime testNow = DateTime(2026, 11, 12, 15, 48);

/// Today at [hour]:[minute] on the test clock.
DateTime today(int hour, [int minute = 0]) =>
    DateTime(testNow.year, testNow.month, testNow.day, hour, minute);

/// A database for [scenario] without latency, so tests run fast.
FakeDatabase fakeDatabase(Scenario scenario) => FakeDatabase(
  scenario: scenario,
  clock: FixedClock(testNow),
  latency: Duration.zero,
  uploadTick: Duration.zero,
);

/// The scenarios that serve the populated data set.
const Set<Scenario> populatedData = {
  Scenario.populated,
  Scenario.offline,
  Scenario.slow,
};
