import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/theme/app_theme.dart';
import 'package:pushit/core/design_system/tokens/app_colors.dart';
import 'package:pushit/core/design_system/tokens/app_sizes.dart';
import 'package:pushit/core/design_system/widgets/app_button_label.dart';
import 'package:pushit/core/design_system/widgets/app_button_size.dart';
import 'package:pushit/core/design_system/widgets/app_button_style.dart';

/// The second action: a pill outlined in `text`, with no fill.
///
/// Disabled when [onPressed] is null.
class SecondaryButton extends StatelessWidget {
  const new({
    required this.label,
    required this.onPressed,
    this.size = AppButtonSize.full,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final AppButtonSize size;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return OutlinedButton(
      onPressed: onPressed,
      style: appButtonStyle(
        size: size,
        styles: context.textStyles,
        background: AppColors.transparent,
        foreground: colors.text,
        disabledBackground: AppColors.transparent,
        disabledForeground: colors.sub,
        side: BorderSide(color: colors.text, width: AppSizes.ringWidth),
        disabledSide: BorderSide(color: colors.line, width: AppSizes.ringWidth),
      ),
      child: AppButtonLabel(label: label, icon: icon),
    );
  }
}
