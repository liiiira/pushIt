import 'package:equatable/equatable.dart';
import 'package:pushit/app/router/route_paths.dart';

/// What the router needs to know to guard routes.
final class AppAccess extends Equatable {
  /// The sign-in state is known.
  const new({
    required this.isOnboarded,
    required this.isSignedIn,
    this.isEmailVerified = true,
  }) : isKnown = true;

  /// Before the sign-in state is known, at launch: the splash shows.
  const new unknown({required this.isOnboarded})
    : isSignedIn = false,
      isEmailVerified = false,
      isKnown = false;

  final bool isOnboarded;
  final bool isSignedIn;

  /// Whether the signed-in user verified their email (A7); `true` when
  /// signed out, as there is nothing to verify.
  final bool isEmailVerified;

  /// Whether the sign-in state is known yet.
  final bool isKnown;

  @override
  List<Object?> get props => [
    isOnboarded,
    isSignedIn,
    isEmailVerified,
    isKnown,
  ];
}

const Set<String> _devRoutes = {RoutePaths.developer, RoutePaths.devComponents};

const Set<String> _signedOutOnly = {
  RoutePaths.signIn,
  RoutePaths.register,
  RoutePaths.resetPassword,
};

/// Where to send the user instead of [location] (a path, no query), or
/// `null` to let the navigation through.
///
/// - `/` goes to the splash. The dev routes are open to everyone.
/// - Until the sign-in state is known: the splash only (A1).
/// - Then the splash leads to the onboarding, sign-in or home.
/// - Not onboarded: the onboarding only.
/// - Signed out: the auth screens only.
/// - Signed in: anything but the onboarding and the signed-out auth
///   screens, which lead home, or to verify email while the email is not
///   verified. Verify email stays reachable while signed in.
String? appRedirect(String location, AppAccess access) {
  if (location == RoutePaths.root) return RoutePaths.splash;
  if (_devRoutes.contains(location)) return null;

  final isSplash = location == RoutePaths.splash;
  if (!access.isKnown) return isSplash ? null : RoutePaths.splash;
  if (isSplash) return _startOf(access);

  final isOnboarding = location == RoutePaths.onboarding;
  if (!access.isOnboarded) return isOnboarding ? null : RoutePaths.onboarding;

  final isAuth =
      _signedOutOnly.contains(location) || location == RoutePaths.verifyEmail;
  if (!access.isSignedIn) return isAuth ? null : RoutePaths.signIn;

  if (_signedOutOnly.contains(location)) {
    return access.isEmailVerified ? RoutePaths.home : RoutePaths.verifyEmail;
  }
  if (isOnboarding) return RoutePaths.home;
  return null;
}

/// Where the splash leads once the sign-in state is known.
String _startOf(AppAccess access) {
  if (!access.isOnboarded) return RoutePaths.onboarding;
  if (!access.isSignedIn) return RoutePaths.signIn;
  return RoutePaths.home;
}
