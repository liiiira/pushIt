import 'package:go_router/go_router.dart';
import 'package:pushit/app/router/route_paths.dart';
import 'package:pushit/core/design_system/widgets/placeholder_page.dart';

/// A1 splash, A2–A4 onboarding pager.
List<RouteBase> onboardingRoutes() => [
  GoRoute(
    path: RoutePaths.splash,
    builder: (_, _) => const PlaceholderPage(screenId: 'A1'),
  ),
  GoRoute(
    path: RoutePaths.onboarding,
    builder: (_, _) => const PlaceholderPage(screenId: 'A2'),
  ),
];
