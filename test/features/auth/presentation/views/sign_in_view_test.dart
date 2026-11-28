import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pushit/app/router/route_paths.dart';
import 'package:pushit/core/design_system/widgets/primary_button.dart';
import 'package:pushit/core/design_system/widgets/secondary_button.dart';
import 'package:pushit/core/failures.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/auth/presentation/pages/sign_in_page.dart';

import '../../../../helpers/helpers.dart';

class _MockAuth extends Mock implements AuthRepository;

Future<void> _pump(
  WidgetTester tester,
  AuthRepository auth, {
  TestLayout? layout,
  MockGoRouter? router,
}) => tester.pumpApp(
  const SignInPage(),
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
      () => auth.signIn(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenAnswer((_) async {});
    when(auth.signInWithGoogle).thenAnswer((_) async {});
  });

  testAcrossLayouts('A5: email, password, and three ways on', (
    tester,
    layout,
  ) async {
    await _pump(tester, auth, layout: layout);

    for (final text in [
      'Welcome back.',
      'Email',
      'Password',
      'Forgot password?',
      'Continue with Google',
      'New here? Create an account',
    ]) {
      expect(find.text(text), findsOneWidget, reason: text);
    }
    expect(find.text('Sign in'), findsNWidgets(2));
    expect(find.text('Enter your email.'), findsNothing);
  });

  testAcrossLayouts('A5: says what is missing after a try', (
    tester,
    layout,
  ) async {
    await _pump(tester, auth, layout: layout);

    await tester.tap(find.widgetWithText(PrimaryButton, 'Sign in'));
    await tester.pump();

    expect(find.text('Enter your email.'), findsOneWidget);
    expect(find.text('Enter your password.'), findsOneWidget);

    await tester.enterText(_field('Email'), 'lyes@');
    await tester.pump();
    expect(
      find.text('Enter a valid email, like name@example.com.'),
      findsOneWidget,
    );
  });

  testWidgets('signs in with what was typed', (tester) async {
    await _pump(tester, auth);

    await tester.enterText(_field('Email'), 'lyes@example.com');
    await tester.enterText(_field('Password'), 'secret');
    await tester.tap(find.widgetWithText(PrimaryButton, 'Sign in'));
    await tester.pump();

    verify(() => auth.signIn(email: 'lyes@example.com', password: 'secret'))
        .called(1);
  });

  testWidgets('says when the email and password do not match', (tester) async {
    when(
      () => auth.signIn(
        email: any(named: 'email'),
        password: any(named: 'password'),
      ),
    ).thenThrow(const ValidationFailure());
    await _pump(tester, auth);

    await tester.enterText(_field('Email'), 'lyes@example.com');
    await tester.enterText(_field('Password'), 'wrong');
    await tester.tap(find.widgetWithText(PrimaryButton, 'Sign in'));
    await tester.pump();

    expect(find.text('That email and password do not match.'), findsOneWidget);
  });

  testWidgets('says when there is no connection', (tester) async {
    when(auth.signInWithGoogle).thenThrow(const NetworkFailure());
    await _pump(tester, auth);

    await tester.tap(find.text('Continue with Google'));
    await tester.pump();

    expect(
      find.text('No connection. Try again when you are back online.'),
      findsOneWidget,
    );
  });

  testWidgets('holds the buttons while signing in', (tester) async {
    final pending = Completer<void>();
    when(auth.signInWithGoogle).thenAnswer((_) => pending.future);
    await _pump(tester, auth);

    await tester.tap(find.text('Continue with Google'));
    await tester.pump();

    expect(
      tester
          .widget<PrimaryButton>(find.widgetWithText(PrimaryButton, 'Sign in'))
          .onPressed,
      isNull,
    );
    expect(
      tester.widget<SecondaryButton>(find.byType(SecondaryButton)).onPressed,
      isNull,
    );
    pending.complete();
  });

  testWidgets('opens reset password on top, and create account instead', (
    tester,
  ) async {
    final router = MockGoRouter();
    when(() => router.push<Object?>(any())).thenAnswer((_) async => null);
    await _pump(tester, auth, router: router);

    await tester.tap(find.text('Forgot password?'));
    verify(() => router.push<Object?>(RoutePaths.resetPassword)).called(1);

    await tester.tap(find.text('New here? Create an account'));
    verify(() => router.go(RoutePaths.register)).called(1);
  });

  testWidgets('fits above the keyboard on a small phone', (tester) async {
    tester.view
      ..physicalSize = const Size(360, 800)
      ..devicePixelRatio = 1
      ..viewInsets = const FakeViewPadding(bottom: 320);
    addTearDown(tester.view.reset);
    await _pump(
      tester,
      auth,
      layout: const TestLayout(
        size: Size(360, 800),
        brightness: Brightness.light,
        textScale: 1.3,
      ),
    );

    await tester.tap(find.widgetWithText(PrimaryButton, 'Sign in'));
    await tester.pump();

    expect(tester.takeException(), isNull);
  });
}
