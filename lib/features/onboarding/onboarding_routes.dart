import 'package:go_router/go_router.dart';
import 'package:pushit/app/router/route_paths.dart';
import 'package:pushit/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:pushit/features/onboarding/presentation/pages/splash_page.dart';

/// A1 splash, A2–A4 onboarding pager.
List<RouteBase> onboardingRoutes() => [
  GoRoute(path: RoutePaths.splash, builder: (_, _) => const SplashPage()),
  GoRoute(
    path: RoutePaths.onboarding,
    builder: (_, _) => const OnboardingPage(),
  ),
];
