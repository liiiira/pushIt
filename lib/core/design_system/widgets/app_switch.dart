import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/theme/app_theme.dart';
import 'package:pushit/core/design_system/tokens/app_durations.dart';
import 'package:pushit/core/design_system/tokens/app_radii.dart';
import 'package:pushit/core/design_system/tokens/app_sizes.dart';

/// The 52 × 32 switch: `accent` track and `onAccent` thumb when on, `block`
/// track and `surface` thumb when off. 48 dp high to tap.
///
/// Inside an `AppListRow`, also toggle from the row's `onTap`.
class AppSwitch extends StatelessWidget {
  const new({required this.value, required this.onChanged, super.key});

  static const ValueKey<String> trackKey = ValueKey('app-switch-track');
  static const ValueKey<String> thumbKey = ValueKey('app-switch-thumb');

  final bool value;

  /// Null disables the switch.
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final onChanged = this.onChanged;
    final isEnabled = onChanged != null;
    final toggle = isEnabled ? () => onChanged(!value) : null;
    final inset = (AppSizes.switchTrack.height - AppSizes.switchThumb) / 2;
    final track = switch ((value, isEnabled)) {
      (true, true) => colors.accent,
      (true, false) => colors.sub,
      (false, true) => colors.block,
      (false, false) => colors.line,
    };
    return Semantics(
      container: true,
      toggled: value,
      enabled: isEnabled,
      onTap: toggle,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        excludeFromSemantics: true,
        onTap: toggle,
        child: SizedBox(
          width: AppSizes.switchTrack.width,
          height: AppSizes.minTapTarget,
          child: Center(
            child: AnimatedContainer(
              key: trackKey,
              duration: AppDurations.fast,
              width: AppSizes.switchTrack.width,
              height: AppSizes.switchTrack.height,
              padding: EdgeInsets.all(inset),
              decoration: BoxDecoration(
                color: track,
                borderRadius: const BorderRadius.all(
                  Radius.circular(AppRadii.pill),
                ),
              ),
              child: AnimatedAlign(
                duration: AppDurations.fast,
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: AnimatedContainer(
                  key: thumbKey,
                  duration: AppDurations.fast,
                  width: AppSizes.switchThumb,
                  height: AppSizes.switchThumb,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: value && isEnabled
                        ? colors.onAccent
                        : colors.surface,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
