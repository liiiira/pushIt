import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/app/router/app_redirect.dart';
import 'package:pushit/app/router/app_shell.dart';
import 'package:pushit/app/router/route_paths.dart';
import 'package:pushit/features/accounts/accounts.dart';
import 'package:pushit/features/activity/activity.dart';
import 'package:pushit/features/assisted/assisted.dart';
import 'package:pushit/features/auth/auth.dart';
import 'package:pushit/features/calendar/calendar.dart';
import 'package:pushit/features/composer/composer.dart';
import 'package:pushit/features/dev/dev.dart';
import 'package:pushit/features/home/home.dart';
import 'package:pushit/features/library/library.dart';
import 'package:pushit/features/onboarding/onboarding.dart';
import 'package:pushit/features/plans/plans.dart';
import 'package:pushit/features/settings/settings.dart';

/// Composes every feature's routes into the app router. Only Agent A edits
/// this file.
///
/// - The four tabs live in a `StatefulShellRoute.indexedStack`.
/// - Everything else (and every tab sub-route, through `parentNavigatorKey`)
///   is full screen on the root navigator.
/// - [access] drives the redirects (`appRedirect`) and re-runs them when it
///   changes.
GoRouter buildAppRouter({
  required ValueListenable<AppAccess> access,
  String initialLocation = RoutePaths.splash,
}) {
  final rootNavigatorKey = GlobalKey<NavigatorState>();
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: initialLocation,
    refreshListenable: access,
    redirect: (_, state) => appRedirect(state.uri.path, access.value),
    routes: [
      ...onboardingRoutes(),
      ...authRoutes(),
      StatefulShellRoute.indexedStack(
        builder: (_, _, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: homeRoutes(
              children: activityRoutes(rootNavigatorKey: rootNavigatorKey),
            ),
          ),
          StatefulShellBranch(routes: calendarRoutes()),
          StatefulShellBranch(
            routes: libraryRoutes(rootNavigatorKey: rootNavigatorKey),
          ),
          StatefulShellBranch(
            routes: accountsRoutes(rootNavigatorKey: rootNavigatorKey),
          ),
        ],
      ),
      ...composerRoutes(),
      ...assistedRoutes(),
      ...settingsRoutes(
        children: [...plansRoutes(), if (kDebugMode) ...developerRoutes()],
      ),
      if (kDebugMode) ...devRoutes(),
    ],
  );
}
