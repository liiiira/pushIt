import 'package:flutter_test/flutter_test.dart';
import 'package:pushit/domain/domain.dart';

final _at = DateTime(2026, 11, 12, 19);

void main() {
  group('ScheduleChoice', () {
    test('SameTime gives every platform the same time', () {
      final choice = SameTime(_at);
      expect(choice.timeFor(PlatformId.youtube), _at);
      expect(choice.timeFor(PlatformId.x), _at);
      expect(choice, SameTime(_at));
    });

    test('PerPlatform gives each platform its own time, or none', () {
      final choice = PerPlatform({PlatformId.tiktok: _at});
      expect(choice.timeFor(PlatformId.tiktok), _at);
      expect(choice.timeFor(PlatformId.youtube), isNull);
    });

    test('PerPlatform exposes an unmodifiable map', () {
      final choice = PerPlatform({PlatformId.tiktok: _at});
      expect(choice.times.clear, throwsUnsupportedError);
      expect(choice, PerPlatform({PlatformId.tiktok: _at}));
    });
  });

  group('UploadProgress', () {
    test('Uploading and Paused report their fraction', () {
      expect(const Uploading(sentBytes: 25, totalBytes: 100).fraction, 0.25);
      expect(const Paused(sentBytes: 50, totalBytes: 100).fraction, 0.5);
      expect(const Uploading(sentBytes: 0, totalBytes: 0).fraction, 0);
    });

    test('variants are values', () {
      expect(const UploadFailed(), const UploadFailed());
      expect(
        const Uploading(sentBytes: 1, totalBytes: 2),
        isNot(const Paused(sentBytes: 1, totalBytes: 2)),
      );
    });
  });

  group('TikTokSettings', () {
    test('defaults: no privacy chosen and every switch off', () {
      const settings = TikTokSettings();
      expect(settings.privacy, isNull);
      expect(settings.allowComments, isFalse);
      expect(settings.allowDuet, isFalse);
      expect(settings.allowStitch, isFalse);
      expect(settings.isCommercial, isFalse);
      expect(isTikTokReady(settings), isFalse);
      expect(
        isTikTokReady(settings.copyWith(privacy: () => TikTokPrivacy.onlyMe)),
        isTrue,
      );
    });
  });

  group('PostDraft', () {
    test('defaults to an empty draft', () {
      const draft = PostDraft();
      expect(draft.video, isNull);
      expect(draft.caption, isEmpty);
      expect(draft.platforms, isEmpty);
      expect(draft.copies, isEmpty);
      expect(draft.coverAt, Duration.zero);
      expect(draft.tiktok, const TikTokSettings());
      expect(draft.schedule, isNull);
    });

    test('exposes unmodifiable collections', () {
      const draft = PostDraft(platforms: {PlatformId.youtube});
      expect(draft.platforms, {PlatformId.youtube});
      expect(draft.platforms.clear, throwsUnsupportedError);
      expect(draft.copies.clear, throwsUnsupportedError);
    });

    test('copyWith replaces fields and can clear the schedule', () {
      final draft = const PostDraft().copyWith(
        caption: 'Hi',
        schedule: () => SameTime(_at),
      );
      expect(draft.caption, 'Hi');
      expect(draft.schedule, SameTime(_at));
      expect(draft.copyWith(schedule: () => null).schedule, isNull);
    });
  });

  group('copyWith and equality', () {
    test('User', () {
      const user = User(
        id: 'u1',
        name: 'Lyes B.',
        email: 'lyes@example.com',
        isEmailVerified: false,
      );
      expect(user.copyWith(isEmailVerified: true).isEmailVerified, isTrue);
      expect(user.copyWith(), user);
    });

    test('ConnectedAccount', () {
      final account = ConnectedAccount(
        id: 'a1',
        platform: PlatformId.tiktok,
        handle: '@lyes.makes',
        label: 'Lyes makes',
        accountType: 'creator',
        mode: AccountMode.assisted,
        health: AccountHealth.expired,
        signInExpiresAt: _at,
      );
      final fixed = account.copyWith(
        health: AccountHealth.connected,
        signInExpiresAt: () => null,
      );
      expect(fixed.health, AccountHealth.connected);
      expect(fixed.signInExpiresAt, isNull);
      expect(account.copyWith(), account);
    });

    test('GalleryItem and VideoAsset', () {
      const item = GalleryItem(
        id: 'g1',
        fileName: 'a.mp4',
        duration: Duration(seconds: 3),
        sizeBytes: 10,
        width: 1080,
        height: 1920,
      );
      expect(item.copyWith(fileName: 'b.mp4').fileName, 'b.mp4');
      const asset = VideoAsset(
        id: 'v1',
        fileName: 'a.mp4',
        duration: Duration(seconds: 3),
        sizeBytes: 10,
        width: 1080,
        height: 1920,
      );
      expect(asset.copyWith(sizeBytes: 11).sizeBytes, 11);
      expect(asset.copyWith(), asset);
    });

    test('PlatformCopy can clear its title', () {
      const copy = PlatformCopy(
        platform: PlatformId.youtube,
        title: 'T',
        text: 'x',
      );
      expect(copy.copyWith(title: () => null).title, isNull);
      expect(copy.copyWith(), copy);
    });

    test('PostStats', () {
      final stats = PostStats(
        views: 1,
        likes: 2,
        comments: 3,
        refreshedAt: _at,
      );
      expect(stats.copyWith(views: 9).views, 9);
      expect(stats.copyWith(), stats);
    });

    test('Plan, Subscription and Usage', () {
      final pro = planFor(PlanTier.pro);
      expect(pro.copyWith(accountLimit: 11).accountLimit, 11);
      expect(pro.copyWith(monthlyPostLimit: () => 5).monthlyPostLimit, 5);
      final subscription = Subscription(
        plan: pro,
        period: BillingPeriod.yearly,
        renewsOn: _at,
      );
      final free = subscription.copyWith(
        plan: planFor(PlanTier.free),
        period: () => null,
        renewsOn: () => null,
      );
      expect(free.period, isNull);
      expect(free.renewsOn, isNull);
      final usage = Usage(
        postsThisMonth: 3,
        connectedAccounts: 4,
        resetsOn: _at,
      );
      expect(usage.copyWith(postsThisMonth: 4).postsThisMonth, 4);
      expect(usage.copyWith(), usage);
    });

    test('ActivityItem can clear its optional fields', () {
      final item = ActivityItem(
        id: 'act1',
        kind: ActivityKind.published,
        occurredAt: _at,
        postId: 'p1',
        postTitle: 'Morning b-roll',
        platform: PlatformId.youtube,
        platformCount: 3,
      );
      final bare = item.copyWith(
        postId: () => null,
        postTitle: () => null,
        platform: () => null,
        platformCount: () => null,
      );
      expect([
        bare.postId,
        bare.postTitle,
        bare.platform,
        bare.platformCount,
      ], everyElement(isNull));
      expect(item.copyWith(), item);
    });

    test('NotificationPreferences, Referral, CaptionSuggestion', () {
      const prefs = NotificationPreferences(
        published: true,
        failed: true,
        reconnectReminders: true,
        assisted: true,
        weeklyPlan: false,
      );
      expect(prefs.copyWith(weeklyPlan: true).weeklyPlan, isTrue);
      expect(prefs.copyWith(), prefs);

      const referral = Referral(code: 'LYES', joinedCount: 2, monthsEarned: 2);
      expect(referral.copyWith(joinedCount: 3).joinedCount, 3);

      const suggestion = CaptionSuggestion(
        platform: PlatformId.linkedin,
        text: 'x',
      );
      expect(suggestion.copyWith(text: 'y').text, 'y');
    });

    test('EditResult and DeletionStep', () {
      const edit = EditResult(
        platform: PlatformId.tiktok,
        outcome: EditOutcome.notSupported,
      );
      expect(
        edit.copyWith(outcome: EditOutcome.applied).outcome,
        EditOutcome.applied,
      );
      const step = DeletionStep(
        platform: PlatformId.tiktok,
        method: DeleteMethod.assisted,
        outcome: DeletionOutcome.awaitingUser,
      );
      expect(
        step.copyWith(outcome: DeletionOutcome.removed).outcome,
        DeletionOutcome.removed,
      );
    });

    test('PlatformCheckIssue variants are values', () {
      expect(
        const NotConnected(PlatformId.x),
        const NotConnected(PlatformId.x),
      );
      expect(
        const NotConnected(PlatformId.x),
        isNot(const PaidPlanRequired(PlatformId.x)),
      );
      expect(const PrivacyNotChosen(), const PrivacyNotChosen());
    });
  });
}
