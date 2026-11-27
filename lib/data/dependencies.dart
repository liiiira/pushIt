import 'package:pushit/core/clock.dart';
import 'package:pushit/data/fake/fake_accounts_repository.dart';
import 'package:pushit/data/fake/fake_activity_repository.dart';
import 'package:pushit/data/fake/fake_auth_repository.dart';
import 'package:pushit/data/fake/fake_caption_suggestions_repository.dart';
import 'package:pushit/data/fake/fake_connectivity_repository.dart';
import 'package:pushit/data/fake/fake_database.dart';
import 'package:pushit/data/fake/fake_feedback_repository.dart';
import 'package:pushit/data/fake/fake_media_repository.dart';
import 'package:pushit/data/fake/fake_notification_settings_repository.dart';
import 'package:pushit/data/fake/fake_posts_repository.dart';
import 'package:pushit/data/fake/fake_referral_repository.dart';
import 'package:pushit/data/fake/fake_subscription_repository.dart';
import 'package:pushit/data/fake/scenario.dart';
import 'package:pushit/domain/domain.dart';

/// Every repository the app needs, plus the [clock].
///
/// `main.dart` builds it once and `PushItApp` exposes each repository
/// through `MultiRepositoryProvider`. A later `Dependencies.remote` will
/// implement the same interfaces.
final class Dependencies {
  const new({
    required this.clock,
    required this.auth,
    required this.accounts,
    required this.media,
    required this.posts,
    required this.captionSuggestions,
    required this.activity,
    required this.subscription,
    required this.notificationSettings,
    required this.referral,
    required this.feedback,
    required this.connectivity,
    this.scenario,
  });

  /// In-memory fakes seeded for [scenario], sharing one state.
  ///
  /// [latency] overrides the scenario's latency (tests pass
  /// `Duration.zero`).
  factory fake({
    required Scenario scenario,
    required Clock clock,
    Duration? latency,
  }) {
    final database = FakeDatabase(
      scenario: scenario,
      clock: clock,
      latency: latency,
    );
    return Dependencies(
      clock: clock,
      scenario: scenario,
      auth: FakeAuthRepository(database),
      accounts: FakeAccountsRepository(database),
      media: FakeMediaRepository(database),
      posts: FakePostsRepository(database),
      captionSuggestions: FakeCaptionSuggestionsRepository(database),
      activity: FakeActivityRepository(database),
      subscription: FakeSubscriptionRepository(database),
      notificationSettings: FakeNotificationSettingsRepository(database),
      referral: FakeReferralRepository(database),
      feedback: FakeFeedbackRepository(database),
      connectivity: FakeConnectivityRepository(database),
    );
  }

  final Clock clock;

  /// The fake scenario; `null` for real backends.
  final Scenario? scenario;
  final AuthRepository auth;
  final AccountsRepository accounts;
  final MediaRepository media;
  final PostsRepository posts;
  final CaptionSuggestionsRepository captionSuggestions;
  final ActivityRepository activity;
  final SubscriptionRepository subscription;
  final NotificationSettingsRepository notificationSettings;
  final ReferralRepository referral;
  final FeedbackRepository feedback;
  final ConnectivityRepository connectivity;
}
