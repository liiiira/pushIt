import 'package:pushit/data/fake/fixtures/fixture_ids.dart';
import 'package:pushit/domain/domain.dart';

const User fixtureUser = User(
  id: FixtureIds.user,
  name: 'Lyes B.',
  email: 'lyes@example.com',
  isEmailVerified: true,
);

const Referral fixtureReferral = Referral(
  code: 'LYES-4F2K',
  joinedCount: 2,
  monthsEarned: 2,
);

const NotificationPreferences fixtureNotificationPreferences =
    NotificationPreferences(
      published: true,
      failed: true,
      reconnectReminders: true,
      assisted: true,
      weeklyPlan: false,
    );
