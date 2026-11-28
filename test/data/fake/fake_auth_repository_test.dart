import 'package:flutter_test/flutter_test.dart';
import 'package:pushit/core/failures.dart';
import 'package:pushit/data/fake/fake_auth_repository.dart';
import 'package:pushit/data/fake/fixtures/fixture_user.dart';
import 'package:pushit/data/fake/scenario.dart';

import 'fake_support.dart';

void main() {
  for (final scenario in Scenario.values) {
    group(scenario.name, () {
      late FakeAuthRepository repository; // set up fresh for each test

      setUp(() => repository = FakeAuthRepository(fakeDatabase(scenario)));

      test('starts signed out', () async {
        expect(await repository.watchUser().first, isNull);
      });

      test('signIn signs the fixture user in with that email', () async {
        await repository.signIn(email: 'me@example.com', password: 'secret12');
        final user = await repository.watchUser().first;
        expect(user?.name, fixtureUser.name);
        expect(user?.email, 'me@example.com');
        expect(user?.isEmailVerified, isTrue);
      });

      test('signIn rejects an empty email or password', () async {
        await expectLater(
          repository.signIn(email: '', password: 'secret12'),
          throwsA(isA<ValidationFailure>()),
        );
        await expectLater(
          repository.signIn(email: 'me@example.com', password: ''),
          throwsA(isA<ValidationFailure>()),
        );
      });

      test('signInWithGoogle signs the fixture user in', () async {
        await repository.signInWithGoogle();
        expect(await repository.watchUser().first, fixtureUser);
      });

      test('register creates an unverified user', () async {
        await repository.register(
          name: 'Sam',
          email: 'sam@example.com',
          password: 'secret12',
        );
        final user = await repository.watchUser().first;
        expect(user?.name, 'Sam');
        expect(user?.email, 'sam@example.com');
        expect(user?.isEmailVerified, isFalse);
      });

      test('resendVerification needs a signed-in user', () async {
        await expectLater(
          repository.resendVerification(),
          throwsA(isA<ValidationFailure>()),
        );
        await repository.signInWithGoogle();
        await repository.resendVerification();
      });

      test('sendPasswordReset needs an email address', () async {
        await repository.sendPasswordReset(email: 'me@example.com');
        await expectLater(
          repository.sendPasswordReset(email: 'nope'),
          throwsA(isA<ValidationFailure>()),
        );
      });

      test('signOut and deleteAccount sign out', () async {
        await repository.signInWithGoogle();
        await repository.signOut();
        expect(await repository.watchUser().first, isNull);

        await repository.signInWithGoogle();
        await repository.deleteAccount();
        expect(await repository.watchUser().first, isNull);
      });
    });
  }
}
