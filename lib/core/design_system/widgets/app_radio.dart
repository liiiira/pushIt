import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/theme/app_theme.dart';
import 'package:pushit/core/design_system/tokens/app_sizes.dart';
import 'package:pushit/core/design_system/widgets/app_control_tile.dart';

/// A 24 dp radio: a ring in `text`, with an `accent` dot when [value] is
/// the [groupValue]. With a [label], the whole line is tappable.
///
/// A null [groupValue] means nothing is chosen yet (e.g. TikTok privacy).
class AppRadio<T> extends StatelessWidget {
  const new({
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.label,
    super.key,
  });

  static const ValueKey<String> ringKey = ValueKey('app-radio-ring');
  static const ValueKey<String> dotKey = ValueKey('app-radio-dot');

  final T value;
  final T? groupValue;

  /// Null disables the radio.
  final ValueChanged<T>? onChanged;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final onChanged = this.onChanged;
    final isEnabled = onChanged != null;
    final isSelected = value == groupValue;
    return MergeSemantics(
      child: Semantics(
        checked: isSelected,
        inMutuallyExclusiveGroup: true,
        enabled: isEnabled,
        child: AppControlTile(
          label: label,
          onTap: isEnabled ? () => onChanged(value) : null,
          control: Container(
            key: ringKey,
            width: AppSizes.radio,
            height: AppSizes.radio,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isEnabled ? colors.text : colors.line,
                width: AppSizes.ringWidth,
              ),
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      key: dotKey,
                      width: AppSizes.radioDot,
                      height: AppSizes.radioDot,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isEnabled ? colors.accent : colors.sub,
                      ),
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }
}
