import 'package:pushit/core/clock.dart';
import 'package:pushit/data/dependencies.dart';
import 'package:pushit/data/fake/scenario.dart';

/// The instant every test runs at: Thu 12 Nov 2026, 15:48
/// (docs/CONVENTIONS.md §7), so the next post reads "in 3 h 12 min".
final DateTime testNow = DateTime(2026, 11, 12, 15, 48);

/// Agent B's fakes for [scenario], at [testNow], with no latency.
///
/// Pass them to a page test with
/// `tester.pumpApp(page, repositories: repositoryProvidersOf(deps))`.
Dependencies testDependencies({Scenario scenario = Scenario.populated}) =>
    Dependencies.fake(
      scenario: scenario,
      clock: FixedClock(testNow),
      latency: Duration.zero,
    );
