import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/tokens/app_colors.dart';
import 'package:pushit/core/design_system/tokens/app_radii.dart';
import 'package:pushit/core/design_system/widgets/app_text_field.dart';

import '../../../helpers/helpers.dart';

AppColors _colorsOf(TestLayout layout) =>
    layout.brightness == Brightness.dark ? AppColors.dark : AppColors.light;

InputDecoration _decorationOf(WidgetTester tester) =>
    tester.widget<TextField>(find.byType(TextField)).decoration!;

Widget _frame(Widget child) => Scaffold(
  body: Padding(padding: const EdgeInsets.all(24), child: child),
);

void main() {
  testAcrossLayouts('shows a label over a borderless surface field', (
    tester,
    layout,
  ) async {
    final changes = <String>[];
    await tester.pumpApp(
      _frame(
        AppTextField(
          label: 'Email',
          hint: 'you@example.com',
          onChanged: changes.add,
        ),
      ),
      layout: layout,
    );

    final colors = _colorsOf(layout);
    final decoration = _decorationOf(tester);
    expect(decoration.filled, isTrue);
    expect(decoration.fillColor, colors.surface);
    final border = decoration.enabledBorder! as OutlineInputBorder;
    expect(border.borderSide, BorderSide.none);
    expect(
      border.borderRadius,
      const BorderRadius.all(Radius.circular(AppRadii.input)),
    );
    expect(
      tester
          .renderObject<RenderParagraph>(find.text('Email'))
          .text
          .style
          ?.color,
      colors.sub,
    );
    expect(decoration.hintText, 'you@example.com');
    expect(
      tester.getSemantics(find.byType(TextField)).label,
      contains('Email'),
    );

    await tester.enterText(find.byType(TextField), 'lyes@example.com');
    expect(changes, ['lyes@example.com']);
  });

  testAcrossLayouts('shows an error with an icon and an outline', (
    tester,
    layout,
  ) async {
    await tester.pumpApp(
      _frame(
        const AppTextField(
          label: 'Password',
          errorText: 'At least 8 characters.',
          isObscured: true,
        ),
      ),
      layout: layout,
    );

    final colors = _colorsOf(layout);
    expect(find.text('At least 8 characters.'), findsOneWidget);
    expect(find.byIcon(LucideIcons.circleAlert), findsOneWidget);
    final border = _decorationOf(tester).enabledBorder! as OutlineInputBorder;
    expect(border.borderSide.color, colors.text);
    expect(
      tester.widget<TextField>(find.byType(TextField)).obscureText,
      isTrue,
    );
  });

  testAcrossLayouts('grows to several lines when multiline', (
    tester,
    layout,
  ) async {
    await tester.pumpApp(
      _frame(
        const AppTextField(
          label: 'What happened',
          hint: 'Tell us what you did and what you expected.',
          isMultiline: true,
        ),
      ),
      layout: layout,
    );

    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.minLines, AppTextField.multilineMinLines);
    expect(field.maxLines, isNull);
    expect(field.keyboardType, TextInputType.multiline);
  });

  testWidgets('starts from an initial value', (tester) async {
    await tester.pumpApp(
      _frame(const AppTextField(label: 'Caption', initialValue: 'Mic test')),
    );

    expect(find.text('Mic test'), findsOneWidget);
  });

  testWidgets('uses the given controller', (tester) async {
    final controller = TextEditingController(text: 'Studio tour');
    addTearDown(controller.dispose);
    await tester.pumpApp(
      _frame(AppTextField(label: 'Title', controller: controller)),
    );

    await tester.enterText(find.byType(TextField), 'Studio tour, part 2');

    expect(controller.text, 'Studio tour, part 2');
  });
}
