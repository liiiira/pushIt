import 'package:flutter_test/flutter_test.dart';
import 'package:pushit/core/view_status.dart';

void main() {
  test('ViewStatus lists the five page states in order', () {
    expect(ViewStatus.values, [
      ViewStatus.initial,
      ViewStatus.loading,
      ViewStatus.ready,
      ViewStatus.empty,
      ViewStatus.failure,
    ]);
  });
}
