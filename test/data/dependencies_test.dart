import 'package:flutter_test/flutter_test.dart';
import 'package:pushit/core/clock.dart';
import 'package:pushit/data/dependencies.dart';
import 'package:pushit/data/fake/scenario.dart';
import 'package:pushit/domain/domain.dart';

import 'fake/fake_support.dart';

void main() {
  for (final scenario in Scenario.values) {
    test('${scenario.name}: Dependencies.fake wires every fake', () async {
      final clock = FixedClock(testNow);
      final deps = Dependencies.fake(
        scenario: scenario,
        clock: clock,
        latency: Duration.zero,
      );

      expect(deps.clock, same(clock));
      expect(deps.scenario, scenario);
      expect(await deps.auth.watchUser().first, isNull);
      expect(
        await deps.connectivity.watchOnline().first,
        scenario != Scenario.offline,
      );
      expect(await deps.subscription.plans(), allPlans);
      expect(await deps.referral.referral(), isA<Referral>());
      expect(
        await deps.notificationSettings.load(),
        isA<NotificationPreferences>(),
      );
      await deps.feedback.send(
        FeedbackKind.other,
        'hi',
        includeDeviceDetails: false,
      );
      expect(deps.media, isA<MediaRepository>());
      expect(deps.posts, isA<PostsRepository>());
      expect(deps.activity, isA<ActivityRepository>());
      expect(deps.accounts, isA<AccountsRepository>());
      expect(deps.captionSuggestions, isA<CaptionSuggestionsRepository>());
    });
  }

  test('the fakes share one in-memory state', () async {
    final deps = Dependencies.fake(
      scenario: Scenario.populated,
      clock: FixedClock(testNow),
      latency: Duration.zero,
    );
    final before = await deps.subscription.watchUsage().first;
    await deps.accounts.connect(PlatformId.threads, AccountMode.automatic);
    final after = await deps.subscription.watchUsage().first;
    expect(after.connectedAccounts, before.connectedAccounts + 1);
  });

  test('two Dependencies do not share state', () async {
    Dependencies build() => Dependencies.fake(
      scenario: Scenario.populated,
      clock: FixedClock(testNow),
      latency: Duration.zero,
    );
    final first = build();
    final second = build();
    await first.accounts.connect(PlatformId.threads, AccountMode.automatic);
    expect(
      (await second.accounts.watchAccounts().first).length,
      (await first.accounts.watchAccounts().first).length - 1,
    );
  });

  test('the default latency follows the scenario', () {
    final deps = Dependencies.fake(
      scenario: Scenario.slow,
      clock: FixedClock(testNow),
    );
    expect(deps.scenario, Scenario.slow);
  });
}
