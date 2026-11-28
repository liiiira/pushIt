import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/tokens/app_sizes.dart';
import 'package:pushit/core/design_system/tokens/app_spacing.dart';

/// A button label on one line, with an optional leading icon.
class AppButtonLabel extends StatelessWidget {
  const new({required this.label, this.icon, super.key});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final text = Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
    );
    final icon = this.icon;
    if (icon == null) return text;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppSizes.iconSmall),
        const SizedBox(width: AppSpacing.xs),
        Flexible(child: text),
      ],
    );
  }
}
