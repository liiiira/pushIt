import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pushit/core/design_system/widgets/text_action_button.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/auth/presentation/pages/verify_email_page.dart';

import '../../../../helpers/helpers.dart';

class _MockAuth extends Mock implements AuthRepository;

const _user = User(
  id: 'u1',
  name: 'Lyes B.',
  email: 'lyes@example.com',
  isEmailVerified: false,
);

TextActionButton _sendAgain(WidgetTester tester) => tester.widget(
  find.ancestor(
    of: find.textContaining('Send again'),
    matching: find.byType(TextActionButton),
  ),
);

void main() {
  late _MockAuth auth; // fresh for each test

  setUp(() {
    auth = _MockAuth();
    when(auth.watchUser).thenAnswer((_) => Stream.value(_user));
    when(auth.resendVerification).thenAnswer((_) async {});
    when(auth.signOut).thenAnswer((_) async {});
  });

  Future<void> pump(WidgetTester tester, {TestLayout? layout}) async {
    await tester.pumpApp(
      const VerifyEmailPage(),
      layout: layout,
      repositories: [RepositoryProvider<AuthRepository>.value(value: auth)],
    );
    await tester.pump();
  }

  testAcrossLayouts('A7: says where the link went, and when to send again', (
    tester,
    layout,
  ) async {
    await pump(tester, layout: layout);

    expect(find.byIcon(LucideIcons.mail), findsOneWidget);
    expect(find.text('Check your email'), findsOneWidget);
    expect(
      find.text(
        'We sent a link to lyes@example.com. Open it on this phone to '
        'finish creating your account.',
      ),
      findsOneWidget,
    );
    expect(find.text('Open email app'), findsOneWidget);
    expect(find.text('Send again in 1:00'), findsOneWidget);
    expect(_sendAgain(tester).onPressed, isNull);

    await tester.pump(const Duration(seconds: 18));
    expect(find.text('Send again in 0:42'), findsOneWidget);
  });

  testWidgets('sends again once the countdown is over', (tester) async {
    await pump(tester);

    await tester.pump(const Duration(seconds: 60));
    expect(find.text('Send again'), findsOneWidget);
    await tester.tap(find.text('Send again'));
    await tester.pump();

    verify(auth.resendVerification).called(1);
    expect(find.text('Send again in 1:00'), findsOneWidget);
  });

  testWidgets('the back arrow signs out', (tester) async {
    await pump(tester);

    await tester.tap(find.byTooltip('Back'));
    await tester.pump();

    verify(auth.signOut).called(1);
  });
}
