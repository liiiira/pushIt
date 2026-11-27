import 'package:flutter_test/flutter_test.dart';
import 'package:pushit/app/router/app_redirect.dart';
import 'package:pushit/app/router/route_paths.dart';

void main() {
  const newUser = AppAccess(isOnboarded: false, isSignedIn: false);
  const signedOut = AppAccess(isOnboarded: true, isSignedIn: false);
  const signedIn = AppAccess(isOnboarded: true, isSignedIn: true);
  const everyone = [newUser, signedOut, signedIn];

  const authPaths = [
    RoutePaths.signIn,
    RoutePaths.register,
    RoutePaths.verifyEmail,
    RoutePaths.resetPassword,
  ];

  test('the root always goes to the splash', () {
    for (final access in everyone) {
      expect(appRedirect('/', access), RoutePaths.splash);
    }
  });

  test('the splash and the dev routes are never redirected', () {
    for (final access in everyone) {
      expect(appRedirect(RoutePaths.splash, access), isNull);
      expect(appRedirect(RoutePaths.devComponents, access), isNull);
      expect(appRedirect(RoutePaths.developer, access), isNull);
    }
  });

  group('not onboarded', () {
    test('stays on the onboarding', () {
      expect(appRedirect(RoutePaths.onboarding, newUser), isNull);
    });

    test('is sent to the onboarding from anywhere else', () {
      for (final path in [
        RoutePaths.home,
        RoutePaths.signIn,
        RoutePaths.libraryPostFor('p1'),
      ]) {
        expect(appRedirect(path, newUser), RoutePaths.onboarding, reason: path);
      }
    });
  });

  group('onboarded and signed out', () {
    test('may open every auth screen', () {
      for (final path in authPaths) {
        expect(appRedirect(path, signedOut), isNull, reason: path);
      }
    });

    test('is sent to sign-in from the app and the onboarding', () {
      for (final path in [
        RoutePaths.home,
        RoutePaths.compose,
        RoutePaths.libraryPostFor('p1'),
        RoutePaths.settings,
        RoutePaths.onboarding,
      ]) {
        expect(appRedirect(path, signedOut), RoutePaths.signIn, reason: path);
      }
    });
  });

  group('signed in', () {
    test('may open the app', () {
      for (final path in [
        RoutePaths.home,
        RoutePaths.compose,
        RoutePaths.libraryPostFor('p1'),
        RoutePaths.settings,
        RoutePaths.verifyEmail,
      ]) {
        expect(appRedirect(path, signedIn), isNull, reason: path);
      }
    });

    test('is sent home from sign-in, register, reset and onboarding', () {
      for (final path in [
        RoutePaths.signIn,
        RoutePaths.register,
        RoutePaths.resetPassword,
        RoutePaths.onboarding,
      ]) {
        expect(appRedirect(path, signedIn), RoutePaths.home, reason: path);
      }
    });
  });
}
