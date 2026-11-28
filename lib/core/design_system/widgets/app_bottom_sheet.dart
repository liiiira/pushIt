import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/theme/app_theme.dart';
import 'package:pushit/core/design_system/tokens/app_radii.dart';
import 'package:pushit/core/design_system/tokens/app_sizes.dart';
import 'package:pushit/core/design_system/tokens/app_spacing.dart';

/// Opens a modal bottom sheet in the pushIt style: `surface`, top corners
/// 28, a drag handle, an optional `title`, over the `scrim`.
///
/// Close it with `Navigator.pop(context, value)` from [builder]'s context;
/// tapping the scrim or dragging it down resolves to null. Sheets are not
/// routes (docs/ARCHITECTURE.md).
Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  String? title,
}) {
  final colors = context.colors;
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: colors.surface,
    barrierColor: colors.scrim,
    elevation: 0,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.sheet)),
    ),
    builder: (context) =>
        AppBottomSheetFrame(title: title, child: builder(context)),
  );
}

/// The inside of an app bottom sheet: handle, title, then [child], with
/// the screen margin, scrolling when it is taller than the screen and
/// lifted above the keyboard.
class AppBottomSheetFrame extends StatelessWidget {
  const new({required this.child, this.title, super.key});

  static const ValueKey<String> handleKey = ValueKey('app-sheet-handle');

  final Widget child;
  final String? title;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final title = this.title;
    final insets = MediaQuery.viewInsetsOf(context);
    final padding = MediaQuery.paddingOf(context);
    return Padding(
      padding: EdgeInsets.only(bottom: insets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Center(
              child: Container(
                key: handleKey,
                width: AppSizes.sheetHandle.width,
                height: AppSizes.sheetHandle.height,
                decoration: BoxDecoration(
                  color: colors.line,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(AppRadii.pill),
                  ),
                ),
              ),
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.screenMargin,
                AppSpacing.md,
                AppSpacing.screenMargin,
                AppSpacing.xl + padding.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (title != null) ...[
                    Semantics(
                      header: true,
                      child: Text(
                        title,
                        style: context.textStyles.title.copyWith(
                          color: colors.text,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  child,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
