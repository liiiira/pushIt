import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/tokens/app_colors.dart';
import 'package:pushit/core/design_system/tokens/app_radii.dart';
import 'package:pushit/core/design_system/widgets/app_bottom_sheet.dart';
import 'package:pushit/core/design_system/widgets/app_dialog.dart';
import 'package:pushit/core/design_system/widgets/primary_button.dart';
import 'package:pushit/core/design_system/widgets/text_action_button.dart';

import '../../../helpers/helpers.dart';

AppColors _colorsOf(TestLayout layout) =>
    layout.brightness == Brightness.dark ? AppColors.dark : AppColors.light;

/// A page with one button that runs [open] and keeps what it returns.
class _Opener extends StatelessWidget {
  const new({required this.open, required this.onResult});

  final Future<Object?> Function(BuildContext context) open;
  final ValueChanged<Object?> onResult;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: TextButton(
        onPressed: () async => onResult(await open(context)),
        child: const Text('open'),
      ),
    ),
  );
}

void main() {
  group('showAppBottomSheet', () {
    testAcrossLayouts('shows a handle, a title and the content on surface', (
      tester,
      layout,
    ) async {
      Object? result = 'unset';
      await tester.pumpApp(
        _Opener(
          open: (context) => showAppBottomSheet<String>(
            context: context,
            title: 'Connect Instagram',
            builder: (context) => PrimaryButton(
              label: 'Continue',
              onPressed: () => Navigator.pop(context, 'continued'),
            ),
          ),
          onResult: (value) => result = value,
        ),
        layout: layout,
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      final colors = _colorsOf(layout);
      expect(find.text('Connect Instagram'), findsOneWidget);
      expect(find.byKey(AppBottomSheetFrame.handleKey), findsOneWidget);
      final sheet = tester.widget<BottomSheet>(find.byType(BottomSheet));
      expect(sheet.backgroundColor, colors.surface);
      expect(
        (sheet.shape! as RoundedRectangleBorder).borderRadius,
        const BorderRadius.vertical(top: Radius.circular(AppRadii.sheet)),
      );
      final barrier = tester.widget<ModalBarrier>(
        find.byType(ModalBarrier).last,
      );
      expect(barrier.color, colors.scrim);

      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(result, 'continued');
      expect(find.text('Connect Instagram'), findsNothing);
    });

    testWidgets('closes with null when the scrim is tapped', (tester) async {
      Object? result = 'unset';
      await tester.pumpApp(
        _Opener(
          open: (context) => showAppBottomSheet<String>(
            context: context,
            builder: (_) => const SizedBox(height: 80),
          ),
          onResult: (value) => result = value,
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      await tester.tapAt(const Offset(20, 20));
      await tester.pumpAndSettle();

      expect(result, isNull);
    });
  });

  group('showAppDialog', () {
    testAcrossLayouts('shows a title, a message and stacked actions', (
      tester,
      layout,
    ) async {
      Object? result = 'unset';
      await tester.pumpApp(
        _Opener(
          open: (context) => showAppDialog<bool>(
            context: context,
            title: 'Delete your account?',
            message: 'This deletes your pushIt account, schedule and library.',
            actions: const [
              AppDialogAction(label: 'Delete account', value: true),
              AppDialogAction(
                label: 'Keep account',
                value: false,
                kind: AppDialogActionKind.text,
              ),
            ],
          ),
          onResult: (value) => result = value,
        ),
        layout: layout,
      );

      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      final colors = _colorsOf(layout);
      expect(find.text('Delete your account?'), findsOneWidget);
      expect(find.textContaining('This deletes'), findsOneWidget);
      expect(
        find.widgetWithText(PrimaryButton, 'Delete account'),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(TextActionButton, 'Keep account'),
        findsOneWidget,
      );
      final dialog = tester.widget<Dialog>(find.byType(Dialog));
      expect(dialog.backgroundColor, colors.surface);
      expect(
        tester.getTopLeft(find.text('Delete account')).dy,
        lessThan(tester.getTopLeft(find.text('Keep account')).dy),
      );

      await tester.tap(find.text('Keep account'));
      await tester.pumpAndSettle();

      expect(result, isFalse);
      expect(find.byType(Dialog), findsNothing);
    });
  });
}
