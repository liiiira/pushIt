import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/app/router/app_redirect.dart';
import 'package:pushit/app/router/app_router.dart';
import 'package:pushit/app/router/route_paths.dart';
import 'package:pushit/core/design_system/widgets/placeholder_page.dart';
import 'package:pushit/core/l10n/l10n.dart';

const _newUser = AppAccess(isOnboarded: false, isSignedIn: false);
const _signedOut = AppAccess(isOnboarded: true, isSignedIn: false);
const _signedIn = AppAccess(isOnboarded: true, isSignedIn: true);

Finder _placeholder(String screenId) => find.byWidgetPredicate(
  (widget) => widget is PlaceholderPage && widget.screenId == screenId,
  description: 'PlaceholderPage($screenId)',
);

Future<GoRouter> _pumpRouter(
  WidgetTester tester, {
  required ValueListenable<AppAccess> access,
}) async {
  final router = buildAppRouter(access: access);
  addTearDown(router.dispose);
  await tester.pumpWidget(
    MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

Future<void> _expectScreen(
  WidgetTester tester,
  GoRouter router,
  String location,
  String screenId,
) async {
  router.go(location);
  await tester.pumpAndSettle();
  expect(_placeholder(screenId), findsOneWidget, reason: location);
  expect(find.byType(PlaceholderPage), findsOneWidget, reason: location);
}

void main() {
  testWidgets('starts on the splash', (tester) async {
    await _pumpRouter(tester, access: ValueNotifier(_newUser));

    expect(_placeholder('A1'), findsOneWidget);
  });

  testWidgets('serves the onboarding to a new user', (tester) async {
    final router = await _pumpRouter(tester, access: ValueNotifier(_newUser));

    await _expectScreen(tester, router, RoutePaths.onboarding, 'A2');
  });

  testWidgets('serves every auth screen when signed out', (tester) async {
    final router = await _pumpRouter(tester, access: ValueNotifier(_signedOut));

    await _expectScreen(tester, router, RoutePaths.signIn, 'A5');
    await _expectScreen(tester, router, RoutePaths.register, 'A6');
    await _expectScreen(tester, router, RoutePaths.verifyEmail, 'A7');
    await _expectScreen(tester, router, RoutePaths.resetPassword, 'A8');
  });

  testWidgets('serves every app screen when signed in', (tester) async {
    final router = await _pumpRouter(tester, access: ValueNotifier(_signedIn));
    final screens = <String, String>{
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
      RoutePaths.devComponents: 'components',
    };

    for (final MapEntry(key: location, value: screenId) in screens.entries) {
      await _expectScreen(tester, router, location, screenId);
    }
  });

  testWidgets('applies the redirects', (tester) async {
    final router = await _pumpRouter(tester, access: ValueNotifier(_signedOut));

    await _expectScreen(tester, router, RoutePaths.root, 'A1');
    await _expectScreen(tester, router, RoutePaths.libraryPostFor('p1'), 'A5');
  });

  testWidgets('follows access changes', (tester) async {
    final access = ValueNotifier(_signedOut);
    addTearDown(access.dispose);
    final router = await _pumpRouter(tester, access: access);
    await _expectScreen(tester, router, RoutePaths.signIn, 'A5');

    access.value = _signedIn;
    await tester.pumpAndSettle();

    expect(_placeholder('B1'), findsOneWidget);
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
        expect(find.byType(NavigationBar), findsOneWidget, reason: tab);
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
        expect(find.byType(NavigationBar), findsNothing, reason: fullScreen);
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
      expect(_placeholder('F1'), findsOneWidget);

      await tester.tap(find.text(l10n.commonNavCalendar));
      await tester.pumpAndSettle();
      expect(_placeholder('E1'), findsOneWidget);

      await tester.tap(find.text(l10n.commonNavAccounts));
      await tester.pumpAndSettle();
      expect(_placeholder('C1'), findsOneWidget);

      await tester.tap(find.text(l10n.commonNavHome));
      await tester.pumpAndSettle();
      expect(_placeholder('B1'), findsOneWidget);
    });
  });
}
