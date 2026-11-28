import 'package:flutter_test/flutter_test.dart';
import 'package:pushit/domain/domain.dart';

void main() {
  final now = DateTime(2026, 11, 12, 15, 48);

  test('same calendar day is today, whatever the time', () {
    expect(relativeDayOf(DateTime(2026, 11, 12), now: now), RelativeDay.today);
    expect(
      relativeDayOf(DateTime(2026, 11, 12, 23, 59), now: now),
      RelativeDay.today,
    );
  });

  test('the day before is yesterday, the day after tomorrow', () {
    expect(
      relativeDayOf(DateTime(2026, 11, 11, 23, 59), now: now),
      RelativeDay.yesterday,
    );
    expect(
      relativeDayOf(DateTime(2026, 11, 13), now: now),
      RelativeDay.tomorrow,
    );
  });

  test('any other day is other, across months and years', () {
    expect(relativeDayOf(DateTime(2026, 11, 17), now: now), RelativeDay.other);
    expect(relativeDayOf(DateTime(2026, 11, 10), now: now), RelativeDay.other);
    expect(
      relativeDayOf(DateTime(2027), now: DateTime(2026, 12, 31, 22)),
      RelativeDay.tomorrow,
    );
  });

  test('dateOnly drops the time', () {
    expect(dateOnly(now), DateTime(2026, 11, 12));
  });
}
