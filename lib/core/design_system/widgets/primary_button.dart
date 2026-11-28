import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/theme/app_theme.dart';
import 'package:pushit/core/design_system/widgets/app_button_label.dart';
import 'package:pushit/core/design_system/widgets/app_button_size.dart';
import 'package:pushit/core/design_system/widgets/app_button_style.dart';

/// The main action: an `accent` pill with an `onAccent` label.
///
/// Disabled when [onPressed] is null.
class PrimaryButton extends StatelessWidget {
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
    return FilledButton(
      onPressed: onPressed,
      style: appButtonStyle(
        size: size,
        styles: context.textStyles,
        background: colors.accent,
        foreground: colors.onAccent,
        disabledBackground: colors.block,
        disabledForeground: colors.sub,
      ),
      child: AppButtonLabel(label: label, icon: icon),
    );
  }
}
