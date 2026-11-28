import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/clock.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/accounts/accounts.dart';

import '../../../../helpers/helpers.dart';

const _tiktok = ConnectedAccount(
  id: 'tiktok-1',
  platform: PlatformId.tiktok,
  handle: '@lyes.makes',
  label: 'Lyes makes',
  accountType: 'creator',
  mode: AccountMode.assisted,
  health: AccountHealth.expired,
);

/// Opens the dialog from a button and keeps what it resolves to.
Future<bool? Function()> _open(
  WidgetTester tester, {
  ConnectedAccount account = _tiktok,
  ReconnectRisk risk = const ReconnectRisk(),
  TestLayout? layout,
}) async {
  bool? result;
  await tester.pumpApp(
    Builder(
      builder: (context) => Scaffold(
        body: Center(
          child: TextButton(
            onPressed: () async => result = await showReconnectDialog(
              context: context,
              account: account,
              risk: risk,
            ),
            child: const Text('open'),
          ),
        ),
      ),
    ),
    layout: layout,
    repositories: [RepositoryProvider<Clock>.value(value: FixedClock(testNow))],
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return () => result;
}

void main() {
  testAcrossLayouts('C5: says which posts fail unless the user reconnects', (
    tester,
    layout,
  ) async {
    final result = await _open(
      tester,
      risk: ReconnectRisk(
        postCount: 1,
        firstPostAt: DateTime(2026, 11, 12, 19),
      ),
      layout: layout,
    );

    expect(find.text('Reconnect TikTok'), findsOneWidget);
    expect(
      find.text(
        'TikTok signed this account out. One scheduled post will fail '
        'unless you reconnect before today, 19:00.',
      ),
      findsOneWidget,
    );
    expect(find.text('Later'), findsOneWidget);

    await tester.tap(find.text('Reconnect'));
    await tester.pumpAndSettle();
    expect(result(), isTrue);
  });

  testWidgets('counts several posts', (tester) async {
    await _open(
      tester,
      risk: ReconnectRisk(postCount: 3, firstPostAt: DateTime(2026, 11, 13, 9)),
    );

    expect(
      find.text(
        'TikTok signed this account out. 3 scheduled posts will fail '
        'unless you reconnect before tomorrow, 09:00.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('gives only the reason when no post is at risk', (tester) async {
    await _open(tester);

    expect(find.text('TikTok signed this account out.'), findsOneWidget);
  });

  testWidgets('says when a sign-in about to expire runs out', (tester) async {
    await _open(
      tester,
      account: _tiktok.copyWith(
        platform: PlatformId.facebook,
        health: AccountHealth.expiringSoon,
        signInExpiresAt: () => DateTime(2026, 11, 13, 9),
      ),
    );

    expect(find.text('Reconnect Facebook'), findsOneWidget);
    expect(
      find.text('Facebook signs this account out tomorrow, 09:00.'),
      findsOneWidget,
    );
  });

  testWidgets('says soon when the expiry time is unknown', (tester) async {
    await _open(
      tester,
      account: _tiktok.copyWith(health: AccountHealth.expiringSoon),
    );

    expect(find.text('TikTok signs this account out soon.'), findsOneWidget);
  });

  testWidgets('resolves to false on Later', (tester) async {
    final result = await _open(tester);

    await tester.tap(find.text('Later'));
    await tester.pumpAndSettle();

    expect(result(), isFalse);
    expect(find.text('Reconnect TikTok'), findsNothing);
  });

  testWidgets('resolves to false when dismissed', (tester) async {
    final result = await _open(tester);

    await tester.tapAt(const Offset(4, 4));
    await tester.pumpAndSettle();

    expect(result(), isFalse);
    expect(find.text('Reconnect TikTok'), findsNothing);
  });
}
