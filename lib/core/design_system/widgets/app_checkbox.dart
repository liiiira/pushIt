import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/theme/app_theme.dart';
import 'package:pushit/core/design_system/tokens/app_colors.dart';
import 'package:pushit/core/design_system/tokens/app_durations.dart';
import 'package:pushit/core/design_system/tokens/app_radii.dart';
import 'package:pushit/core/design_system/tokens/app_sizes.dart';
import 'package:pushit/core/design_system/widgets/app_control_tile.dart';

/// A 24 dp checkbox: an `accent` box with a check when ticked, an outline
/// in `text` when not. With a [label], the whole line is tappable.
class AppCheckbox extends StatelessWidget {
  const new({
    required this.value,
    required this.onChanged,
    this.label,
    super.key,
  });

  static const ValueKey<String> boxKey = ValueKey('app-checkbox-box');

  final bool value;

  /// Null disables the checkbox.
  final ValueChanged<bool>? onChanged;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final onChanged = this.onChanged;
    final isEnabled = onChanged != null;
    return MergeSemantics(
      child: Semantics(
        checked: value,
        enabled: isEnabled,
        child: AppControlTile(
          label: label,
          onTap: isEnabled ? () => onChanged(!value) : null,
          control: AnimatedContainer(
            key: boxKey,
            duration: AppDurations.fast,
            width: AppSizes.checkbox,
            height: AppSizes.checkbox,
            decoration: BoxDecoration(
              color: value
                  ? (isEnabled ? colors.accent : colors.sub)
                  : AppColors.transparent,
              border: value
                  ? null
                  : Border.all(
                      color: isEnabled ? colors.text : colors.line,
                      width: AppSizes.ringWidth,
                    ),
              borderRadius: const BorderRadius.all(
                Radius.circular(AppRadii.checkbox),
              ),
            ),
            child: value
                ? Icon(
                    LucideIcons.check,
                    size: AppSizes.iconTiny,
                    color: colors.onAccent,
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
