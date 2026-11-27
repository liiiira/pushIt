import 'package:go_router/go_router.dart';
import 'package:pushit/app/router/route_paths.dart';
import 'package:pushit/core/design_system/widgets/placeholder_page.dart';

/// A5 sign in, A6 create account, A7 verify email, A8 reset password.
List<RouteBase> authRoutes() => [
  GoRoute(
    path: RoutePaths.signIn,
    builder: (_, _) => const PlaceholderPage(screenId: 'A5'),
  ),
  GoRoute(
    path: RoutePaths.register,
    builder: (_, _) => const PlaceholderPage(screenId: 'A6'),
  ),
  GoRoute(
    path: RoutePaths.verifyEmail,
    builder: (_, _) => const PlaceholderPage(screenId: 'A7'),
  ),
  GoRoute(
    path: RoutePaths.resetPassword,
    builder: (_, _) => const PlaceholderPage(screenId: 'A8'),
  ),
];
