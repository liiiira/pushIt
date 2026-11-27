import 'package:flutter_test/flutter_test.dart';
import 'package:pushit/core/clock.dart';

void main() {
  group('FixedClock', () {
    test('always returns the instant it was built with', () {
      final instant = DateTime(2026, 11, 12, 15, 48);
      final clock = FixedClock(instant);

      expect(clock.now(), instant);
      expect(clock.now(), instant);
    });
  });

  group('SystemClock', () {
    test('returns the current time', () {
      const clock = SystemClock();
      final before = DateTime.now();

      final now = clock.now();

      expect(now.isBefore(before), isFalse);
      expect(now.isAfter(DateTime.now()), isFalse);
    });
  });

  test('both clocks are usable through the Clock interface', () {
    final clocks = <Clock>[const SystemClock(), FixedClock(DateTime(2026))];

    expect(clocks, hasLength(2));
  });
}
