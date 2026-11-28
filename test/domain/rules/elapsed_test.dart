import 'package:flutter_test/flutter_test.dart';
import 'package:pushit/domain/domain.dart';

void main() {
  group('elapsedBetween', () {
    final now = DateTime(2026, 11, 12, 15, 48);

    test('under a minute is just now', () {
      expect(elapsedBetween(now.subtract(const Duration(seconds: 59)), now), (
        unit: ElapsedUnit.justNow,
        count: 0,
      ));
    });

    test('minutes, hours, then days', () {
      expect(elapsedBetween(now.subtract(const Duration(minutes: 5)), now), (
        unit: ElapsedUnit.minutes,
        count: 5,
      ));
      expect(elapsedBetween(now.subtract(const Duration(hours: 2)), now), (
        unit: ElapsedUnit.hours,
        count: 2,
      ));
      expect(
        elapsedBetween(now.subtract(const Duration(days: 3, hours: 1)), now),
        (unit: ElapsedUnit.days, count: 3),
      );
    });
  });
}
