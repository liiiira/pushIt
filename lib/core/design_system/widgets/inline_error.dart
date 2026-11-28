import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/theme/app_theme.dart';
import 'package:pushit/core/design_system/tokens/app_sizes.dart';
import 'package:pushit/core/design_system/tokens/app_spacing.dart';

/// A short `small` message with an alert icon, in `text` (never colour
/// alone): under a field, a checkbox or a form. Announced when it appears.
class InlineError extends StatelessWidget {
  const new(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      container: true,
      liveRegion: true,
      label: message,
      child: ExcludeSemantics(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              LucideIcons.circleAlert,
              size: AppSizes.iconTiny,
              color: colors.text,
            ),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                message,
                style: context.textStyles.small.copyWith(color: colors.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
