import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/app/app.dart';
import 'package:pushit/app/router/app_redirect.dart';
import 'package:pushit/app/router/app_router.dart';
import 'package:pushit/core/design_system/tokens/app_colors.dart';
import 'package:pushit/core/design_system/widgets/placeholder_page.dart';

void main() {
  testWidgets('runs the router and names the app', (tester) async {
    final router = buildAppRouter(
      access: ValueNotifier(
        const AppAccess(isOnboarded: false, isSignedIn: false),
      ),
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(PushItApp(router: router));
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

    await tester.pumpWidget(PushItApp(router: router));

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.theme?.extension<AppColors>(), AppColors.light);
    expect(app.darkTheme?.extension<AppColors>(), AppColors.dark);
  });
}
