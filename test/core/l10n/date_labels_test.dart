import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/l10n/date_labels.dart';

import '../../helpers/helpers.dart';

void main() {
  testWidgets('says today, tomorrow or yesterday, or the date', (tester) async {
    late BuildContext context;
    await tester.pumpApp(
      Builder(
        builder: (built) {
          context = built;
          return const SizedBox.shrink();
        },
      ),
    );
    final now = DateTime(2026, 11, 12, 15, 48);

    expect(
      context.dayAndTimeLabel(DateTime(2026, 11, 12, 19), now: now),
      'today, 19:00',
    );
    expect(
      context.dayAndTimeLabel(DateTime(2026, 11, 13, 9, 5), now: now),
      'tomorrow, 09:05',
    );
    expect(
      context.dayAndTimeLabel(DateTime(2026, 11, 11, 23, 30), now: now),
      'yesterday, 23:30',
    );
    expect(
      context.dayAndTimeLabel(DateTime(2026, 11, 17, 19), now: now),
      'Tue 17 Nov, 19:00',
    );
  });
}
