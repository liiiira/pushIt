import 'package:flutter_test/flutter_test.dart';
import 'package:pushit/core/clock.dart';
import 'package:pushit/core/failures.dart';
import 'package:pushit/data/fake/fake_database.dart';
import 'package:pushit/data/fake/scenario.dart';

import 'fake_support.dart';

void main() {
  test('slow has two seconds of latency, the others none', () {
    for (final scenario in Scenario.values) {
      expect(
        FakeDatabase.defaultLatencyFor(scenario),
        scenario == Scenario.slow ? const Duration(seconds: 2) : Duration.zero,
        reason: scenario.name,
      );
    }
  });

  test('the slow scenario really waits before answering', () async {
    final database = FakeDatabase(
      scenario: Scenario.slow,
      clock: FixedClock(testNow),
    );
    final stopwatch = Stopwatch()..start();
    await database.act(() => 1);
    expect(stopwatch.elapsed, greaterThanOrEqualTo(const Duration(seconds: 2)));
  });

  for (final scenario in Scenario.values) {
    test('${scenario.name}: list loads fail only in error', () async {
      final database = fakeDatabase(scenario);
      final load = database.load(() => 1);
      if (scenario == Scenario.error) {
        await expectLater(load, throwsA(isA<NetworkFailure>()));
      } else {
        expect(await load, 1);
      }
      expect(await database.act(() => 2), 2);
    });
  }
}
