import 'package:go_router/go_router.dart';
import 'package:pushit/app/router/route_paths.dart';
import 'package:pushit/core/design_system/widgets/placeholder_page.dart';
import 'package:pushit/features/auth/presentation/pages/register_page.dart';
import 'package:pushit/features/auth/presentation/pages/sign_in_page.dart';

/// A5 sign in, A6 create account, A7 verify email, A8 reset password.
List<RouteBase> authRoutes() => [
  GoRoute(path: RoutePaths.signIn, builder: (_, _) => const SignInPage()),
  GoRoute(path: RoutePaths.register, builder: (_, _) => const RegisterPage()),
  GoRoute(
    path: RoutePaths.verifyEmail,
    builder: (_, _) => const PlaceholderPage(screenId: 'A7'),
  ),
  GoRoute(
    path: RoutePaths.resetPassword,
    builder: (_, _) => const PlaceholderPage(screenId: 'A8'),
  ),
];
