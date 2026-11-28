import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/theme/app_theme.dart';
import 'package:pushit/core/design_system/tokens/app_colors.dart';
import 'package:pushit/core/design_system/tokens/app_spacing.dart';
import 'package:pushit/core/design_system/widgets/app_button_label.dart';
import 'package:pushit/core/design_system/widgets/app_button_size.dart';
import 'package:pushit/core/design_system/widgets/app_button_style.dart';

/// A label-only action in `text` colour, e.g. "Disconnect" (full) or an
/// underlined "Fix" / "Forgot password?" (small).
///
/// Small text actions have no side padding, so they line up with the text
/// around them; the tap target still grows to 48 dp.
class TextActionButton extends StatelessWidget {
  const new({
    required this.label,
    required this.onPressed,
    this.size = AppButtonSize.full,
    this.isUnderlined = false,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonSize size;
  final bool isUnderlined;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return TextButton(
      onPressed: onPressed,
      style: appButtonStyle(
        size: size,
        styles: context.textStyles,
        background: AppColors.transparent,
        foreground: colors.text,
        disabledBackground: AppColors.transparent,
        disabledForeground: colors.sub,
        horizontalPadding: switch (size) {
          AppButtonSize.full => AppSpacing.lg,
          AppButtonSize.small => 0,
        },
        decoration: isUnderlined
            ? TextDecoration.underline
            : TextDecoration.none,
      ),
      child: AppButtonLabel(label: label, icon: icon),
    );
  }
}
