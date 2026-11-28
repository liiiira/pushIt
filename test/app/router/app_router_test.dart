import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/app/app.dart';
import 'package:pushit/app/router/app_redirect.dart';
import 'package:pushit/app/router/app_router.dart';
import 'package:pushit/app/router/route_paths.dart';
import 'package:pushit/core/design_system/widgets/app_bottom_nav.dart';
import 'package:pushit/core/design_system/widgets/offline_banner.dart';
import 'package:pushit/core/design_system/widgets/placeholder_page.dart';
import 'package:pushit/core/l10n/l10n.dart';
import 'package:pushit/data/dependencies.dart';
import 'package:pushit/data/fake/fake_connectivity_repository.dart';
import 'package:pushit/data/fake/scenario.dart';
import 'package:pushit/features/dev/presentation/pages/components_page.dart';

import '../../helpers/helpers.dart';

const _launching = AppAccess.unknown(isOnboarded: true);
const _newUser = AppAccess(isOnboarded: false, isSignedIn: false);
const _signedOut = AppAccess(isOnboarded: true, isSignedIn: false);
const _signedIn = AppAccess(isOnboarded: true, isSignedIn: true);

/// Checks that the router shows [screenId] at [path], whether the screen is
/// built yet or still a `PlaceholderPage`: the path must match, and any
/// placeholder on screen must name [screenId]. Real pages replace the
/// placeholders one by one without touching this test.
void _expectAt(GoRouter router, String path, String screenId) {
  expect(router.state.uri.path, path, reason: screenId);
  for (final placeholder
      in find
          .byType(PlaceholderPage)
          .evaluate()
          .map((element) => element.widget as PlaceholderPage)) {
    expect(placeholder.screenId, screenId, reason: path);
  }
}

Future<GoRouter> _pumpRouter(
  WidgetTester tester, {
  required ValueListenable<AppAccess> access,
  Scenario scenario = Scenario.populated,
  Dependencies? dependencies,
}) async {
  final router = buildAppRouter(access: access);
  addTearDown(router.dispose);
  await tester.pumpWidget(
    PushItApp(
      dependencies: dependencies ?? testDependencies(scenario: scenario),
      preferences: InMemoryAppPreferences(),
      router: router,
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

/// Goes to [location] and expects [screenId] there, or at [redirectedTo].
Future<void> _expectScreen(
  WidgetTester tester,
  GoRouter router,
  String location,
  String screenId, {
  String? redirectedTo,
}) async {
  router.go(location);
  await tester.pumpAndSettle();
  _expectAt(router, redirectedTo ?? location, screenId);
}

void main() {
  testWidgets('starts on the splash', (tester) async {
    final router = await _pumpRouter(tester, access: ValueNotifier(_launching));

    _expectAt(router, RoutePaths.splash, 'A1');
  });

  testWidgets('leaves the splash once the sign-in state is known', (
    tester,
  ) async {
    final access = ValueNotifier(_launching);
    addTearDown(access.dispose);
    final router = await _pumpRouter(tester, access: access);

    access.value = _signedIn;
    await tester.pumpAndSettle();

    _expectAt(router, RoutePaths.home, 'B1');
  });

  testWidgets('serves the onboarding to a new user', (tester) async {
    final router = await _pumpRouter(tester, access: ValueNotifier(_newUser));

    await _expectScreen(tester, router, RoutePaths.onboarding, 'A2');
  });

  testWidgets('serves the signed-out auth screens when signed out', (
    tester,
  ) async {
    final router = await _pumpRouter(tester, access: ValueNotifier(_signedOut));

    await _expectScreen(tester, router, RoutePaths.signIn, 'A5');
    await _expectScreen(tester, router, RoutePaths.register, 'A6');
    await _expectScreen(tester, router, RoutePaths.resetPassword, 'A8');
  });

  testWidgets('serves every app screen when signed in', (tester) async {
    final router = await _pumpRouter(tester, access: ValueNotifier(_signedIn));
    final screens = <String, String>{
      RoutePaths.verifyEmail: 'A7',
      RoutePaths.home: 'B1',
      RoutePaths.activity: 'B3',
      RoutePaths.accounts: 'C1',
      RoutePaths.addAccount: 'C2',
      RoutePaths.accountDetailFor('a1'): 'C4',
      RoutePaths.compose: 'D1',
      RoutePaths.composeUpload: 'D2',
      RoutePaths.composePost: 'D4',
      RoutePaths.composePostCaptions: 'D5',
      RoutePaths.composePostCover: 'D6',
      RoutePaths.composePostTikTok: 'D7',
      RoutePaths.composePostCheck: 'D8',
      RoutePaths.composeDrafts: 'D12',
      RoutePaths.composeScheduled: 'D13',
      RoutePaths.calendar: 'E1',
      RoutePaths.library: 'F1',
      RoutePaths.libraryPostFor('p1'): 'F3',
      RoutePaths.libraryPostEditFor('p1'): 'F5',
      RoutePaths.libraryPostDeleteFor('p1'): 'F6',
      RoutePaths.libraryPostDeleteResultFor('p1'): 'F7',
      RoutePaths.assistedFor('p1', 'tiktok'): 'G2',
      RoutePaths.assistedDeleteFor('p1', 'tiktok'): 'G3',
      RoutePaths.settings: 'H1',
      RoutePaths.plans: 'H2',
      RoutePaths.notificationSettings: 'H4',
      RoutePaths.invite: 'H5',
      RoutePaths.feedback: 'H6',
      RoutePaths.appearance: 'appearance',
      RoutePaths.developer: 'developer',
    };

    for (final MapEntry(key: location, value: screenId) in screens.entries) {
      await _expectScreen(tester, router, location, screenId);
    }

    router.go(RoutePaths.devComponents);
    await tester.pumpAndSettle();
    expect(find.byType(ComponentsPage), findsOneWidget);
  });

  testWidgets('applies the redirects', (tester) async {
    final router = await _pumpRouter(tester, access: ValueNotifier(_signedOut));

    await _expectScreen(
      tester,
      router,
      RoutePaths.root,
      'A5',
      redirectedTo: RoutePaths.signIn,
    );
    await _expectScreen(
      tester,
      router,
      RoutePaths.libraryPostFor('p1'),
      'A5',
      redirectedTo: RoutePaths.signIn,
    );
  });

  testWidgets('follows access changes', (tester) async {
    final access = ValueNotifier(_signedOut);
    addTearDown(access.dispose);
    final router = await _pumpRouter(tester, access: access);
    await _expectScreen(tester, router, RoutePaths.signIn, 'A5');

    access.value = _signedIn;
    await tester.pumpAndSettle();

    _expectAt(router, RoutePaths.home, 'B1');
  });

  group('shell', () {
    testWidgets('shows the bottom nav on the four tabs only', (tester) async {
      final router = await _pumpRouter(
        tester,
        access: ValueNotifier(_signedIn),
      );

      for (final tab in [
        RoutePaths.home,
        RoutePaths.calendar,
        RoutePaths.library,
        RoutePaths.accounts,
      ]) {
        router.go(tab);
        await tester.pumpAndSettle();
        expect(find.byType(AppBottomNav), findsOneWidget, reason: tab);
      }

      for (final fullScreen in [
        RoutePaths.activity,
        RoutePaths.addAccount,
        RoutePaths.libraryPostFor('p1'),
        RoutePaths.compose,
        RoutePaths.settings,
      ]) {
        router.go(fullScreen);
        await tester.pumpAndSettle();
        expect(find.byType(AppBottomNav), findsNothing, reason: fullScreen);
      }
    });

    testWidgets('switches tabs from the bottom nav', (tester) async {
      final router = await _pumpRouter(
        tester,
        access: ValueNotifier(_signedIn),
      );
      router.go(RoutePaths.home);
      await tester.pumpAndSettle();
      final l10n = lookupAppLocalizations(const Locale('en'));

      await tester.tap(find.text(l10n.commonNavLibrary));
      await tester.pumpAndSettle();
      _expectAt(router, RoutePaths.library, 'F1');

      await tester.tap(find.text(l10n.commonNavCalendar));
      await tester.pumpAndSettle();
      _expectAt(router, RoutePaths.calendar, 'E1');

      await tester.tap(find.text(l10n.commonNavAccounts));
      await tester.pumpAndSettle();
      _expectAt(router, RoutePaths.accounts, 'C1');

      await tester.tap(find.text(l10n.commonNavHome));
      await tester.pumpAndSettle();
      _expectAt(router, RoutePaths.home, 'B1');
    });

    testWidgets('opens the composer full screen from the create button', (
      tester,
    ) async {
      final router = await _pumpRouter(
        tester,
        access: ValueNotifier(_signedIn),
      );
      router.go(RoutePaths.library);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(AppBottomNav.createKey));
      await tester.pumpAndSettle();

      _expectAt(router, RoutePaths.compose, 'D1');
      expect(find.byType(AppBottomNav), findsNothing);

      router.pop();
      await tester.pumpAndSettle();
      _expectAt(router, RoutePaths.library, 'F1');
      expect(find.byType(AppBottomNav), findsOneWidget);
    });

    testWidgets("opens another tab's screens from Home and comes back", (
      tester,
    ) async {
      final router = await _pumpRouter(
        tester,
        access: ValueNotifier(_signedIn),
      );
      router.go(RoutePaths.home);
      await tester.pumpAndSettle();

      for (final location in [
        RoutePaths.libraryPostFor('p1'),
        RoutePaths.addAccount,
        RoutePaths.activity,
        RoutePaths.settings,
      ]) {
        unawaited(router.push<void>(location));
        await tester.pumpAndSettle();
        expect(router.state.uri.path, location);

        router.pop();
        await tester.pumpAndSettle();
        expect(router.state.uri.path, RoutePaths.home, reason: location);
        expect(
          tester.widget<AppBottomNav>(find.byType(AppBottomNav)).currentIndex,
          0,
          reason: location,
        );
      }
    });

    testWidgets('shows the offline banner on the tabs while offline', (
      tester,
    ) async {
      final router = await _pumpRouter(
        tester,
        access: ValueNotifier(_signedIn),
        scenario: Scenario.offline,
      );
      router.go(RoutePaths.home);
      await tester.pumpAndSettle();

      expect(find.byType(OfflineBanner), findsOneWidget);
      expect(
        tester.getTopLeft(find.byType(OfflineBanner)).dy,
        lessThan(tester.getTopLeft(find.byType(StatefulNavigationShell)).dy),
      );
      expect(
        tester.getRect(find.byType(StatefulNavigationShell)).bottom,
        lessThanOrEqualTo(tester.getTopLeft(find.byType(AppBottomNav)).dy),
      );
    });

    testWidgets('keeps the tabs when the connection comes back', (
      tester,
    ) async {
      final dependencies = testDependencies(scenario: Scenario.offline);
      final router = await _pumpRouter(
        tester,
        access: ValueNotifier(_signedIn),
        dependencies: dependencies,
      );
      router.go(RoutePaths.library);
      await tester.pumpAndSettle();
      final tabs = tester.state(find.byType(StatefulNavigationShell));
      expect(find.byType(OfflineBanner), findsOneWidget);

      (dependencies.connectivity as FakeConnectivityRepository).setOnline(
        isOnline: true,
      );
      await tester.pumpAndSettle();

      expect(find.byType(OfflineBanner), findsNothing);
      expect(tester.state(find.byType(StatefulNavigationShell)), same(tabs));
      _expectAt(router, RoutePaths.library, 'F1');
    });

    testWidgets('shows no offline banner while online', (tester) async {
      final router = await _pumpRouter(
        tester,
        access: ValueNotifier(_signedIn),
      );
      router.go(RoutePaths.home);
      await tester.pumpAndSettle();

      expect(find.byType(OfflineBanner), findsNothing);
    });
  });
}
