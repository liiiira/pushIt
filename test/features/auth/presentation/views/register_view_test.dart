import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pushit/app/router/route_paths.dart';
import 'package:pushit/core/design_system/widgets/app_checkbox.dart';
import 'package:pushit/core/design_system/widgets/primary_button.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/auth/presentation/pages/register_page.dart';

import '../../../../helpers/helpers.dart';

class _MockAuth extends Mock implements AuthRepository;

Future<void> _pump(
  WidgetTester tester,
  AuthRepository auth, {
  TestLayout? layout,
  MockGoRouter? router,
}) => tester.pumpApp(
  const RegisterPage(),
  layout: layout,
  router: router,
  repositories: [RepositoryProvider<AuthRepository>.value(value: auth)],
);

Finder _field(String label) => find.descendant(
  of: find.ancestor(of: find.text(label), matching: find.byType(Column)).first,
  matching: find.byType(TextField),
);

void main() {
  late _MockAuth auth; // fresh for each test

  setUp(() {
    auth = _MockAuth();
    when(
      () => auth.register(
        name: any(named: 'name'),
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async {});
    when(auth.signInWithGoogle).thenAnswer((_) async {});
  });

  testAcrossLayouts('A6: name, email, password and the terms', (
    tester,
    layout,
  ) async {
    await _pump(tester, auth, layout: layout);

    for (final text in [
      'Free for 3 accounts and 10 videos a month.',
      'Name',
      'Email',
      'Password',
      'At least 8 characters',
      'I agree to the terms and privacy policy',
      'Continue with Google',
      'Already have an account? Sign in',
    ]) {
      expect(find.text(text), findsOneWidget, reason: text);
    }
    expect(find.text('Create account'), findsNWidgets(2));
    expect(tester.widget<AppCheckbox>(find.byType(AppCheckbox)).value, isFalse);
  });

  testAcrossLayouts('A6: says what is missing after a try', (
    tester,
    layout,
  ) async {
    await _pump(tester, auth, layout: layout);

    await tester.tap(find.widgetWithText(PrimaryButton, 'Create account'));
    await tester.pump();

    for (final text in [
      'Enter your name.',
      'Enter your email.',
      'Enter a password.',
      'Agree to the terms and privacy policy to continue.',
    ]) {
      expect(find.text(text), findsOneWidget, reason: text);
    }

    await tester.enterText(_field('Password'), 'short');
    await tester.pump();
    expect(find.text('Use at least 8 characters.'), findsOneWidget);
  });

  testWidgets('creates the account with what was entered', (tester) async {
    await _pump(tester, auth);

    await tester.enterText(_field('Name'), 'Lyes B.');
    await tester.enterText(_field('Email'), 'lyes@example.com');
    await tester.enterText(_field('Password'), 'longenough');
    final terms = find.text('I agree to the terms and privacy policy');
    await tester.ensureVisible(terms);
    await tester.tap(terms);
    await tester.tap(find.widgetWithText(PrimaryButton, 'Create account'));
    await tester.pump();

    verify(
      () => auth.register(
        name: 'Lyes B.',
        email: 'lyes@example.com',
        password: 'longenough',
      ),
    ).called(1);
  });

  testWidgets('continues with Google', (tester) async {
    await _pump(tester, auth);

    await tester.tap(find.text('Continue with Google'));
    await tester.pump();

    verify(auth.signInWithGoogle).called(1);
  });

  testWidgets('goes to sign-in instead', (tester) async {
    final router = MockGoRouter();
    await _pump(tester, auth, router: router);

    await tester.tap(find.text('Already have an account? Sign in'));

    verify(() => router.go(RoutePaths.signIn)).called(1);
  });
}
