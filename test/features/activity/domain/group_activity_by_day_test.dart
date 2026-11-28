import 'package:flutter_test/flutter_test.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/activity/domain/group_activity_by_day.dart';

import '../../../helpers/helpers.dart';

ActivityItem _item(String id, DateTime at) =>
    ActivityItem(id: id, kind: ActivityKind.published, occurredAt: at);

void main() {
  const group = GroupActivityByDay();

  test('groups into today, yesterday and earlier, newest first', () {
    final groups = group([
      _item('today-late', DateTime(2026, 11, 12, 13, 31)),
      _item('today-early', DateTime(2026, 11, 12, 0, 1)),
      _item('yesterday', DateTime(2026, 11, 11, 23, 59)),
      _item('monday', DateTime(2026, 11, 9, 12, 2)),
      _item('october', DateTime(2026, 10, 20, 8)),
    ], now: testNow);

    expect(groups.map((g) => g.day), [
      ActivityDay.today,
      ActivityDay.yesterday,
      ActivityDay.earlier,
    ]);
    expect(groups.map((g) => g.items.map((i) => i.id).toList()), [
      ['today-late', 'today-early'],
      ['yesterday'],
      ['monday', 'october'],
    ]);
  });

  test('leaves out empty days and sorts what arrives unsorted', () {
    final groups = group([
      _item('older', DateTime(2026, 11, 2)),
      _item('newer', DateTime(2026, 11, 5)),
    ], now: testNow);

    expect(groups.single.day, ActivityDay.earlier);
    expect(groups.single.items.map((i) => i.id), ['newer', 'older']);
  });

  test('has no groups without activity', () {
    expect(group(const [], now: testNow), isEmpty);
  });
}
