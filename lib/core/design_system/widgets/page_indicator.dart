import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/theme/app_theme.dart';
import 'package:pushit/core/design_system/tokens/app_durations.dart';
import 'package:pushit/core/design_system/tokens/app_radii.dart';
import 'package:pushit/core/design_system/tokens/app_sizes.dart';
import 'package:pushit/core/design_system/tokens/app_spacing.dart';
import 'package:pushit/core/l10n/l10n.dart';

/// Pager dots: the current page is an `accent` pill, the others `block`
/// dots. Reads out as "Page 1 of 3".
class PageIndicator extends StatelessWidget {
  const new({required this.count, required this.index, super.key});

  final int count;

  /// Zero-based.
  final int index;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      container: true,
      label: context.l10n.commonPageIndicator(index + 1, count),
      child: ExcludeSemantics(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var page = 0; page < count; page++) ...[
              if (page > 0) const SizedBox(width: AppSpacing.xxs),
              AnimatedContainer(
                duration: AppDurations.normal,
                width: page == index
                    ? AppSizes.pageDotActiveWidth
                    : AppSizes.pageDot,
                height: AppSizes.pageDot,
                decoration: BoxDecoration(
                  color: page == index ? colors.accent : colors.block,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(AppRadii.pill),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
