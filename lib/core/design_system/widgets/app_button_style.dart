import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/tokens/app_colors.dart';
import 'package:pushit/core/design_system/tokens/app_spacing.dart';
import 'package:pushit/core/design_system/tokens/app_typography.dart';
import 'package:pushit/core/design_system/widgets/app_button_size.dart';

/// The pill style shared by the app buttons: flat, no tint, a 48 dp tap
/// target, full width or hugging its label.
ButtonStyle appButtonStyle({
  required AppButtonSize size,
  required AppTypography styles,
  required Color background,
  required Color foreground,
  required Color disabledBackground,
  required Color disabledForeground,
  BorderSide side = BorderSide.none,
  BorderSide disabledSide = BorderSide.none,
  double horizontalPadding = AppSpacing.lg,
  TextDecoration decoration = TextDecoration.none,
}) {
  Color pick(Set<WidgetState> states, Color enabled, Color disabled) =>
      states.contains(WidgetState.disabled) ? disabled : enabled;
  return ButtonStyle(
    backgroundColor: WidgetStateProperty.resolveWith(
      (states) => pick(states, background, disabledBackground),
    ),
    foregroundColor: WidgetStateProperty.resolveWith(
      (states) => pick(states, foreground, disabledForeground),
    ),
    iconColor: WidgetStateProperty.resolveWith(
      (states) => pick(states, foreground, disabledForeground),
    ),
    side: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.disabled) ? disabledSide : side,
    ),
    textStyle: WidgetStatePropertyAll(
      size.labelStyle(styles).copyWith(decoration: decoration),
    ),
    elevation: const WidgetStatePropertyAll(0),
    shadowColor: const WidgetStatePropertyAll(AppColors.transparent),
    surfaceTintColor: const WidgetStatePropertyAll(AppColors.transparent),
    shape: const WidgetStatePropertyAll(StadiumBorder()),
    minimumSize: WidgetStatePropertyAll(switch (size) {
      AppButtonSize.full => Size.fromHeight(size.height),
      AppButtonSize.small => Size(0, size.height),
    }),
    padding: WidgetStatePropertyAll(
      EdgeInsets.symmetric(horizontal: horizontalPadding),
    ),
    tapTargetSize: MaterialTapTargetSize.padded,
    visualDensity: VisualDensity.standard,
  );
}
