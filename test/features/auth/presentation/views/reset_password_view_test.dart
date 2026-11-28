import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/auth/presentation/pages/reset_password_page.dart';

import '../../../../helpers/helpers.dart';

class _MockAuth extends Mock implements AuthRepository;

void main() {
  late _MockAuth auth; // fresh for each test

  setUp(() {
    auth = _MockAuth();
    when(() => auth.sendPasswordReset(email: any(named: 'email')))
        .thenAnswer((_) async {});
  });

  Future<void> pump(
    WidgetTester tester, {
    TestLayout? layout,
    MockGoRouter? router,
  }) => tester.pumpApp(
    const ResetPasswordPage(),
    layout: layout,
    router: router,
    repositories: [RepositoryProvider<AuthRepository>.value(value: auth)],
  );

  Future<void> send(WidgetTester tester) async {
    await tester.enterText(find.byType(TextField), 'lyes@example.com');
    await tester.tap(find.text('Send reset link'));
    await tester.pump();
  }

  testAcrossLayouts('A8: asks for the email', (tester, layout) async {
    await pump(tester, layout: layout);

    expect(find.text('Reset password'), findsOneWidget);
    expect(
      find.text(
        'Enter your email and we will send you a link to choose a new '
        'password.',
      ),
      findsOneWidget,
    );
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Send reset link'), findsOneWidget);

    await tester.tap(find.text('Send reset link'));
    await tester.pump();
    expect(find.text('Enter your email.'), findsOneWidget);
  });

  testAcrossLayouts('A8: confirms the link was sent', (tester, layout) async {
    await pump(tester, layout: layout);

    await send(tester);

    verify(() => auth.sendPasswordReset(email: 'lyes@example.com')).called(1);
    expect(find.text('Check your email'), findsOneWidget);
    expect(
      find.text(
        'We sent a link to lyes@example.com. Open it to choose a new '
        'password.',
      ),
      findsOneWidget,
    );
    expect(find.text('Open email app'), findsOneWidget);
    expect(find.text('Back to sign in'), findsOneWidget);
  });

  testWidgets('goes back to sign-in once sent', (tester) async {
    final router = MockGoRouter();
    when(router.canPop).thenReturn(true);
    await pump(tester, router: router);
    await send(tester);

    await tester.tap(find.text('Back to sign in'));

    verify(router.pop).called(1);
  });
}
