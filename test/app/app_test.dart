import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/app/app.dart';
import 'package:pushit/app/router/app_redirect.dart';
import 'package:pushit/app/router/app_router.dart';
import 'package:pushit/core/clock.dart';
import 'package:pushit/core/design_system/tokens/app_colors.dart';
import 'package:pushit/core/design_system/widgets/placeholder_page.dart';
import 'package:pushit/data/fake/scenario.dart';
import 'package:pushit/domain/domain.dart';

import '../helpers/helpers.dart';

void main() {
  testWidgets('runs the router and names the app', (tester) async {
    final router = buildAppRouter(
      access: ValueNotifier(
        const AppAccess(isOnboarded: false, isSignedIn: false),
      ),
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      PushItApp(dependencies: testDependencies(), router: router),
    );
    await tester.pumpAndSettle();

    expect(find.byType(PlaceholderPage), findsOneWidget);
    final title = tester.widget<Title>(find.byType(Title));
    expect(title.title, 'pushIt');
  });

  testWidgets('uses the light and dark app themes', (tester) async {
    final router = buildAppRouter(
      access: ValueNotifier(
        const AppAccess(isOnboarded: false, isSignedIn: false),
      ),
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      PushItApp(dependencies: testDependencies(), router: router),
    );

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.theme?.extension<AppColors>(), AppColors.light);
    expect(app.darkTheme?.extension<AppColors>(), AppColors.dark);
  });

  testWidgets('exposes every repository and the clock', (tester) async {
    final dependencies = testDependencies();
    final found = <Object>[];
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, _) {
            found
              ..clear()
              ..addAll([
                context.read<Clock>(),
                context.read<AuthRepository>(),
                context.read<AccountsRepository>(),
                context.read<MediaRepository>(),
                context.read<PostsRepository>(),
                context.read<CaptionSuggestionsRepository>(),
                context.read<ActivityRepository>(),
                context.read<SubscriptionRepository>(),
                context.read<NotificationSettingsRepository>(),
                context.read<ReferralRepository>(),
                context.read<FeedbackRepository>(),
                context.read<ConnectivityRepository>(),
              ]);
            return const SizedBox.shrink();
          },
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      PushItApp(dependencies: dependencies, router: router),
    );

    expect(found, [
      same(dependencies.clock),
      same(dependencies.auth),
      same(dependencies.accounts),
      same(dependencies.media),
      same(dependencies.posts),
      same(dependencies.captionSuggestions),
      same(dependencies.activity),
      same(dependencies.subscription),
      same(dependencies.notificationSettings),
      same(dependencies.referral),
      same(dependencies.feedback),
      same(dependencies.connectivity),
    ]);
  });

  test('test dependencies use the fixed test clock and no latency', () {
    final dependencies = testDependencies(scenario: Scenario.firstUse);

    expect(dependencies.scenario, Scenario.firstUse);
    expect(dependencies.clock.now(), testNow);
  });
}
