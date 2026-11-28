import 'package:flutter_test/flutter_test.dart';
import 'package:pushit/core/failures.dart';
import 'package:pushit/data/fake/fake_activity_repository.dart';
import 'package:pushit/data/fake/scenario.dart';
import 'package:pushit/domain/domain.dart';

import 'fake_support.dart';

void main() {
  for (final scenario in Scenario.values) {
    test('${scenario.name}: watchActivity', () async {
      final activity = FakeActivityRepository(fakeDatabase(scenario))
          .watchActivity()
          .first;

      switch (scenario) {
        case Scenario.error:
          await expectLater(activity, throwsA(isA<NetworkFailure>()));
        case Scenario.firstUse:
          expect(await activity, isEmpty);
        case Scenario.populated ||
            Scenario.freeLimit ||
            Scenario.offline ||
            Scenario.slow:
          final items = await activity;
          expect(items.map((i) => i.kind), [
            ActivityKind.failed,
            ActivityKind.published,
            ActivityKind.reconnectNeeded,
            ActivityKind.published,
            ActivityKind.published,
          ]);
          expect(items.first.postTitle, 'Mic test');
          expect(items.first.platform, PlatformId.tiktok);
          expect(items.first.occurredAt, today(13, 31));
          expect(items[1].platformCount, 3);
          final times = items.map((i) => i.occurredAt).toList();
          expect(
            times,
            [...times]..sort((a, b) => b.compareTo(a)),
            reason: 'newest first',
          );
      }
    });
  }
}
