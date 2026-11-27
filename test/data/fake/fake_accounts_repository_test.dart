import 'package:flutter_test/flutter_test.dart';
import 'package:pushit/core/failures.dart';
import 'package:pushit/data/fake/fake_accounts_repository.dart';
import 'package:pushit/data/fake/scenario.dart';
import 'package:pushit/domain/domain.dart';

import 'fake_support.dart';

void main() {
  for (final scenario in Scenario.values) {
    group(scenario.name, () {
      late FakeAccountsRepository repository; // set up fresh for each test

      setUp(() => repository = FakeAccountsRepository(fakeDatabase(scenario)));

      if (scenario == Scenario.error) {
        test('watchAccounts fails with a network failure', () async {
          await expectLater(
            repository.watchAccounts().first,
            throwsA(isA<NetworkFailure>()),
          );
        });
        return;
      }

      test('watchAccounts serves the scenario accounts', () async {
        final accounts = await repository.watchAccounts().first;
        final platforms = accounts.map((a) => a.platform).toList();
        switch (scenario) {
          case Scenario.firstUse:
            expect(accounts, isEmpty);
          case Scenario.freeLimit:
            expect(platforms, [
              PlatformId.youtube,
              PlatformId.instagram,
              PlatformId.facebook,
            ]);
          case Scenario.populated ||
              Scenario.offline ||
              Scenario.slow ||
              Scenario.error:
            expect(platforms, [
              PlatformId.youtube,
              PlatformId.instagram,
              PlatformId.facebook,
              PlatformId.tiktok,
            ]);
            final tiktok = accounts.last;
            expect(tiktok.handle, '@lyes.makes');
            expect(tiktok.health, AccountHealth.expired);
            expect(accounts[1].mode, AccountMode.assisted);
            expect(accounts.first.label, 'Lyes makes');
            expect(accounts[2].label, 'Lyes makes, Page');
        }
      });

      test('connect adds an account, or hits the plan limit', () async {
        final connect = repository.connect(
          PlatformId.threads,
          AccountMode.automatic,
        );
        if (scenario == Scenario.freeLimit) {
          await expectLater(connect, throwsA(isA<LimitReachedFailure>()));
          return;
        }
        final account = await connect;
        expect(account.platform, PlatformId.threads);
        expect(account.mode, AccountMode.automatic);
        expect(account.health, AccountHealth.connected);
        expect(await repository.watchAccounts().first, contains(account));
      });

      test('disconnect removes an account; unknown ids fail', () async {
        final before = await repository.watchAccounts().first;
        if (before.isNotEmpty) {
          await repository.disconnect(before.first.id);
          expect(await repository.watchAccounts().first, before.skip(1));
        }
        await expectLater(
          repository.disconnect('missing'),
          throwsA(isA<NotFoundFailure>()),
        );
      });

      if (populatedData.contains(scenario)) {
        test('reconnect fixes an expired account', () async {
          await repository.reconnect('acc-tiktok');
          final accounts = await repository.watchAccounts().first;
          final tiktok = accounts.firstWhere(
            (a) => a.platform == PlatformId.tiktok,
          );
          expect(tiktok.health, AccountHealth.connected);
          expect(tiktok.signInExpiresAt!.isAfter(testNow), isTrue);
        });
      }

      test('watchAccounts emits every change', () async {
        final emitted = <int>[];
        final subscription = repository.watchAccounts().listen(
          (accounts) => emitted.add(accounts.length),
        );
        await pumpEventQueue();
        if (scenario != Scenario.freeLimit) {
          await repository.connect(PlatformId.bluesky, AccountMode.automatic);
          await pumpEventQueue();
          expect(emitted, [emitted.first, emitted.first + 1]);
        }
        await subscription.cancel();
      });
    });
  }
}
