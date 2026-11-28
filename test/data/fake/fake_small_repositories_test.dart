import 'package:flutter_test/flutter_test.dart';
import 'package:pushit/core/failures.dart';
import 'package:pushit/data/fake/fake_connectivity_repository.dart';
import 'package:pushit/data/fake/fake_feedback_repository.dart';
import 'package:pushit/data/fake/fake_notification_settings_repository.dart';
import 'package:pushit/data/fake/fake_referral_repository.dart';
import 'package:pushit/data/fake/scenario.dart';
import 'package:pushit/domain/domain.dart';

import 'fake_support.dart';

void main() {
  for (final scenario in Scenario.values) {
    group(scenario.name, () {
      test('connectivity is offline only in the offline scenario', () async {
        final repository = FakeConnectivityRepository(fakeDatabase(scenario));
        expect(
          await repository.watchOnline().first,
          scenario != Scenario.offline,
        );
      });

      test('notification preferences load the defaults and save', () async {
        final repository = FakeNotificationSettingsRepository(
          fakeDatabase(scenario),
        );
        const defaults = NotificationPreferences(
          published: true,
          failed: true,
          reconnectReminders: true,
          assisted: true,
          weeklyPlan: false,
        );
        expect(await repository.load(), defaults);

        final changed = defaults.copyWith(weeklyPlan: true, published: false);
        await repository.save(changed);
        expect(await repository.load(), changed);
      });

      test('referral', () async {
        final referral = await FakeReferralRepository(fakeDatabase(scenario))
            .referral();
        expect(referral.code, 'LYES-4F2K');
        if (scenario == Scenario.firstUse) {
          expect((referral.joinedCount, referral.monthsEarned), (0, 0));
        } else {
          expect((referral.joinedCount, referral.monthsEarned), (2, 2));
        }
      });

      test('feedback is recorded, and an empty message rejected', () async {
        final repository = FakeFeedbackRepository(fakeDatabase(scenario));
        await repository.send(
          FeedbackKind.idea,
          'Dark mode on the widget',
          includeDeviceDetails: true,
        );
        expect(repository.sent, [
          (
            kind: FeedbackKind.idea,
            message: 'Dark mode on the widget',
            includeDeviceDetails: true,
          ),
        ]);
        await expectLater(
          repository.send(
            FeedbackKind.problem,
            '   ',
            includeDeviceDetails: false,
          ),
          throwsA(isA<ValidationFailure>()),
        );
      });
    });
  }
}
