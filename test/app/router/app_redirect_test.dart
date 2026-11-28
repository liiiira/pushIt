import 'package:flutter_test/flutter_test.dart';
import 'package:pushit/app/router/app_redirect.dart';
import 'package:pushit/app/router/route_paths.dart';

void main() {
  const newUser = AppAccess(isOnboarded: false, isSignedIn: false);
  const signedOut = AppAccess(isOnboarded: true, isSignedIn: false);
  const signedIn = AppAccess(isOnboarded: true, isSignedIn: true);
  const unverified = AppAccess(
    isOnboarded: true,
    isSignedIn: true,
    isEmailVerified: false,
  );
  const unknown = AppAccess.unknown(isOnboarded: true);
  const everyone = [unknown, newUser, signedOut, signedIn, unverified];

  test('the root always goes to the splash', () {
    for (final access in everyone) {
      expect(appRedirect('/', access), RoutePaths.splash);
    }
  });

  test('the dev routes are never redirected', () {
    for (final access in everyone) {
      expect(appRedirect(RoutePaths.devComponents, access), isNull);
      expect(appRedirect(RoutePaths.developer, access), isNull);
    }
  });

  group('before the sign-in state is known', () {
    test('stays on the splash', () {
      expect(appRedirect(RoutePaths.splash, unknown), isNull);
      expect(
        appRedirect(
          RoutePaths.splash,
          const AppAccess.unknown(isOnboarded: false),
        ),
        isNull,
      );
    });

    test('is sent to the splash from anywhere else', () {
      for (final path in [
        RoutePaths.home,
        RoutePaths.onboarding,
        RoutePaths.signIn,
        RoutePaths.libraryPostFor('p1'),
      ]) {
        expect(appRedirect(path, unknown), RoutePaths.splash, reason: path);
      }
    });
  });

  test('the splash, once the state is known, leads where the user starts', () {
    expect(appRedirect(RoutePaths.splash, newUser), RoutePaths.onboarding);
    expect(appRedirect(RoutePaths.splash, signedOut), RoutePaths.signIn);
    expect(appRedirect(RoutePaths.splash, signedIn), RoutePaths.home);
    expect(appRedirect(RoutePaths.splash, unverified), RoutePaths.home);
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
    test('may open sign-in, register and reset', () {
      for (final path in [
        RoutePaths.signIn,
        RoutePaths.register,
        RoutePaths.resetPassword,
      ]) {
        expect(appRedirect(path, signedOut), isNull, reason: path);
      }
    });

    test('is sent to sign-in from verify email, which needs an account', () {
      expect(appRedirect(RoutePaths.verifyEmail, signedOut), RoutePaths.signIn);
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

  group('signed in, email not verified yet', () {
    test('may open the app and verify email', () {
      for (final path in [
        RoutePaths.home,
        RoutePaths.libraryPostFor('p1'),
        RoutePaths.verifyEmail,
      ]) {
        expect(appRedirect(path, unverified), isNull, reason: path);
      }
    });

    test('is sent to verify email from sign-in, register and reset', () {
      for (final path in [
        RoutePaths.signIn,
        RoutePaths.register,
        RoutePaths.resetPassword,
      ]) {
        expect(
          appRedirect(path, unverified),
          RoutePaths.verifyEmail,
          reason: path,
        );
      }
    });

    test('is sent home from the onboarding', () {
      expect(appRedirect(RoutePaths.onboarding, unverified), RoutePaths.home);
    });
  });
}
