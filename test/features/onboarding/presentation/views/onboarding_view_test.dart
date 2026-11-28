import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/widgets/page_indicator.dart';
import 'package:pushit/core/preferences/app_preferences.dart';
import 'package:pushit/features/onboarding/presentation/pages/onboarding_page.dart';

import '../../../../helpers/helpers.dart';

const List<({String title, String body, String action})> _pages = [
  (
    title: 'One video, every platform',
    body:
        'Upload once and schedule it for YouTube, Instagram, TikTok and '
        'Facebook together.',
    action: 'Next',
  ),
  (
    title: 'It posts while your phone is off',
    body:
        'At the time you choose, pushIt publishes for you. Where a platform '
        'does not allow that yet, we remind you and open the app with the '
        'video ready.',
    action: 'Next',
  ),
  (
    title: 'One place to edit or delete',
    body:
        'Every video keeps a record of where it went, so you can change it '
        'or remove it everywhere at once.',
    action: 'Connect an account',
  ),
];

Future<InMemoryAppPreferences> _pump(
  WidgetTester tester, {
  TestLayout? layout,
}) async {
  final preferences = InMemoryAppPreferences();
  await tester.pumpApp(
    const OnboardingPage(),
    layout: layout,
    repositories: [
      RepositoryProvider<AppPreferences>.value(value: preferences),
    ],
  );
  return preferences;
}

void _expectPage(WidgetTester tester, int index) {
  final page = _pages[index];
  expect(find.text(page.title), findsOneWidget);
  expect(find.text(page.body), findsOneWidget);
  expect(find.text(page.action), findsOneWidget);
  expect(find.text('Skip'), findsOneWidget);
  expect(tester.widget<PageIndicator>(find.byType(PageIndicator)).index, index);
}

void main() {
  for (final (index, page) in _pages.indexed) {
    testAcrossLayouts('A${index + 2}: ${page.title}', (tester, layout) async {
      await _pump(tester, layout: layout);

      for (var i = 0; i < index; i++) {
        await tester.tap(find.text('Next'));
        await tester.pumpAndSettle();
      }

      _expectPage(tester, index);
    });
  }

  testWidgets('follows a swipe', (tester) async {
    await _pump(tester);

    await tester.drag(find.byType(PageView), const Offset(-500, 0));
    await tester.pumpAndSettle();

    _expectPage(tester, 1);
  });

  testWidgets('Connect an account on the last page finishes', (tester) async {
    final preferences = await _pump(tester);
    for (var i = 0; i < 2; i++) {
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
    }

    await tester.tap(find.text('Connect an account'));
    await tester.pump();

    expect(preferences.isOnboarded, isTrue);
  });

  testWidgets('Skip finishes from the first page', (tester) async {
    final preferences = await _pump(tester);

    await tester.tap(find.text('Skip'));
    await tester.pump();

    expect(preferences.isOnboarded, isTrue);
  });
}
