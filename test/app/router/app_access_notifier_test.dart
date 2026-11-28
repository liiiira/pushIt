import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pushit/app/router/app_access_notifier.dart';
import 'package:pushit/app/router/app_redirect.dart';
import 'package:pushit/core/failures.dart';
import 'package:pushit/data/fake/scenario.dart';
import 'package:pushit/domain/domain.dart';

import '../../helpers/helpers.dart';

class _MockAuth extends Mock implements AuthRepository;

void main() {
  test('is unknown until the sign-in state arrives', () {
    final auth = _MockAuth();
    when(auth.watchUser).thenAnswer((_) => const Stream.empty());

    final notifier = AppAccessNotifier(
      preferences: InMemoryAppPreferences(isOnboarded: true),
      auth: auth,
    );
    addTearDown(notifier.dispose);

    expect(notifier.value, const AppAccess.unknown(isOnboarded: true));
  });

  for (final scenario in Scenario.values) {
    test('starts signed out on the fakes ($scenario)', () async {
      final dependencies = testDependencies(scenario: scenario);
      final notifier = AppAccessNotifier(
        preferences: InMemoryAppPreferences(),
        auth: dependencies.auth,
      );
      addTearDown(notifier.dispose);

      await pumpEventQueue();

      expect(
        notifier.value,
        const AppAccess(isOnboarded: false, isSignedIn: false),
      );
    });
  }

  test('follows sign-in, registration and sign-out', () async {
    final auth = testDependencies().auth;
    final notifier = AppAccessNotifier(
      preferences: InMemoryAppPreferences(isOnboarded: true),
      auth: auth,
    );
    addTearDown(notifier.dispose);

    await auth.signIn(email: 'lyes@example.com', password: 'password');
    await pumpEventQueue();
    expect(
      notifier.value,
      const AppAccess(isOnboarded: true, isSignedIn: true),
    );

    await auth.signOut();
    await pumpEventQueue();
    expect(
      notifier.value,
      const AppAccess(isOnboarded: true, isSignedIn: false),
    );

    await auth.register(
      name: 'Lyes',
      email: 'lyes@example.com',
      password: 'password',
    );
    await pumpEventQueue();
    expect(
      notifier.value,
      const AppAccess(
        isOnboarded: true,
        isSignedIn: true,
        isEmailVerified: false,
      ),
    );
  });

  test('follows the onboarding being done', () async {
    final preferences = InMemoryAppPreferences();
    final notifier = AppAccessNotifier(
      preferences: preferences,
      auth: testDependencies().auth,
    );
    addTearDown(notifier.dispose);
    await pumpEventQueue();

    await preferences.setOnboarded();
    await pumpEventQueue();

    expect(
      notifier.value,
      const AppAccess(isOnboarded: true, isSignedIn: false),
    );
  });

  test('counts an auth error as signed out, so the splash moves on', () async {
    final auth = _MockAuth();
    when(auth.watchUser)
        .thenAnswer((_) => Stream.error(const NetworkFailure()));
    final notifier = AppAccessNotifier(
      preferences: InMemoryAppPreferences(isOnboarded: true),
      auth: auth,
    );
    addTearDown(notifier.dispose);

    await pumpEventQueue();

    expect(
      notifier.value,
      const AppAccess(isOnboarded: true, isSignedIn: false),
    );
  });

  test('stops listening when disposed', () async {
    final users = StreamController<User?>();
    addTearDown(users.close);
    final auth = _MockAuth();
    when(auth.watchUser).thenAnswer((_) => users.stream);
    final notifier = AppAccessNotifier(
      preferences: InMemoryAppPreferences(),
      auth: auth,
    );
    expect(users.hasListener, isTrue);

    notifier.dispose();
    await pumpEventQueue();

    expect(users.hasListener, isFalse);
  });
}
