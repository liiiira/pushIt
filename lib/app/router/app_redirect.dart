import 'package:equatable/equatable.dart';
import 'package:pushit/app/router/route_paths.dart';

/// What the router needs to know to guard routes.
final class AppAccess extends Equatable {
  const new({required this.isOnboarded, required this.isSignedIn});

  final bool isOnboarded;
  final bool isSignedIn;

  @override
  List<Object?> get props => [isOnboarded, isSignedIn];
}

const Set<String> _openToEveryone = {
  RoutePaths.splash,
  RoutePaths.developer,
  RoutePaths.devComponents,
};

const Set<String> _signedOutOnly = {
  RoutePaths.signIn,
  RoutePaths.register,
  RoutePaths.resetPassword,
};

/// Where to send the user instead of [location] (a path, no query), or
/// `null` to let the navigation through.
///
/// - `/` goes to the splash, which decides where to go next.
/// - Not onboarded: the onboarding only.
/// - Signed out: the auth screens only.
/// - Signed in: anything but the onboarding and the signed-out auth screens.
///   Verify email stays reachable while signed in.
String? appRedirect(String location, AppAccess access) {
  if (location == RoutePaths.root) return RoutePaths.splash;
  if (_openToEveryone.contains(location)) return null;

  final isOnboarding = location == RoutePaths.onboarding;
  if (!access.isOnboarded) return isOnboarding ? null : RoutePaths.onboarding;

  final isAuth =
      _signedOutOnly.contains(location) || location == RoutePaths.verifyEmail;
  if (!access.isSignedIn) return isAuth ? null : RoutePaths.signIn;

  if (isOnboarding || _signedOutOnly.contains(location)) {
    return RoutePaths.home;
  }
  return null;
}
