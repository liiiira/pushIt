import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/theme/app_theme.dart';
import 'package:pushit/core/design_system/tokens/app_radii.dart';
import 'package:pushit/core/design_system/tokens/app_sizes.dart';

/// A 6 dp pill: an `accent` fill for [value] (0 to 1) on a `line` track.
/// Reads out as a percentage.
class AppProgressBar extends StatelessWidget {
  const new({required this.value, super.key});

  static const ValueKey<String> trackKey = ValueKey('progress-track');
  static const ValueKey<String> fillKey = ValueKey('progress-fill');

  final double value;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final share = value.clamp(0.0, 1.0);
    final locale = Localizations.localeOf(context).toLanguageTag();
    return Semantics(
      container: true,
      value: NumberFormat.percentPattern(locale).format(share),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(AppRadii.pill)),
        child: SizedBox(
          height: AppSizes.progressBar,
          child: ColoredBox(
            key: trackKey,
            color: colors.line,
            child: Align(
              alignment: AlignmentDirectional.centerStart,
              child: FractionallySizedBox(
                widthFactor: share,
                heightFactor: 1,
                child: ColoredBox(key: fillKey, color: colors.accent),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
