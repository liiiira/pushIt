import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/theme/app_theme.dart';
import 'package:pushit/core/design_system/tokens/app_colors.dart';
import 'package:pushit/core/design_system/tokens/app_durations.dart';
import 'package:pushit/core/design_system/tokens/app_radii.dart';
import 'package:pushit/core/design_system/tokens/app_sizes.dart';
import 'package:pushit/core/design_system/tokens/app_spacing.dart';

/// One choice of an [AppSegmentedControl].
@immutable
final class AppSegment<T> {
  const new({required this.value, required this.label});

  final T value;
  final String label;
}

/// A `surface` pill split into segments; the selected one is an `accent`
/// pill with an `onAccent` label (Monthly / Yearly, Problem / Idea / Other,
/// the Library filters). Each segment is 48 dp high to tap.
///
/// The split is even when every label fits; labels are never cut (see
/// [segmentWidths]).
class AppSegmentedControl<T> extends StatelessWidget {
  const new({
    required this.segments,
    required this.selected,
    required this.onChanged,
    super.key,
  });

  static const ValueKey<String> trackKey = ValueKey('app-segmented-track');

  final List<AppSegment<T>> segments;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final labelStyle = DefaultTextStyle.of(context).style
        .merge(context.textStyles.bodyStrong);
    final textScaler = MediaQuery.textScalerOf(context);
    final textDirection = Directionality.of(context);
    double naturalWidth(String label) {
      final painter = TextPainter(
        text: TextSpan(text: label, style: labelStyle),
        textDirection: textDirection,
        textScaler: textScaler,
        maxLines: 1,
      )..layout();
      final width = painter.width.ceilToDouble();
      painter.dispose();
      return width + 2 * (_outerPadding + _labelPadding);
    }

    return Container(
      key: trackKey,
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: const BorderRadius.all(Radius.circular(AppRadii.pill)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final widths = segmentWidths(
            available: constraints.maxWidth,
            minimum: AppSizes.minTapTarget,
            natural: [
              for (final segment in segments) naturalWidth(segment.label),
            ],
          );
          return Row(
            children: [
              for (final (i, segment) in segments.indexed)
                SizedBox(
                  key: ValueKey(segment.value),
                  width: widths[i],
                  child: _Segment(
                    label: segment.label,
                    isSelected: segment.value == selected,
                    onTap: () => onChanged(segment.value),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Between the track and the selected pill.
const double _outerPadding = AppSpacing.xxs;

/// Between the selected pill and its label, on each side. Small, so the
/// four Library filters fit whole at 412 dp (F1).
const double _labelPadding = AppSpacing.xxs;

class _Segment extends StatelessWidget {
  const new({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    const pill = BorderRadius.all(Radius.circular(AppRadii.pill));
    return Semantics(
      container: true,
      button: true,
      selected: isSelected,
      inMutuallyExclusiveGroup: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: pill,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSizes.minTapTarget),
          child: Padding(
            padding: const EdgeInsets.all(_outerPadding),
            child: AnimatedContainer(
              duration: AppDurations.fast,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(
                horizontal: _labelPadding,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: isSelected ? colors.accent : AppColors.transparent,
                borderRadius: pill,
              ),
              // Only scales down when the track cannot fit every label.
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: context.textStyles.bodyStrong.copyWith(
                    color: isSelected ? colors.onAccent : colors.sub,
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

/// How wide each segment of an [AppSegmentedControl] is, given the
/// [available] width and each label's [natural] width (padding included).
/// No segment is narrower than [minimum] (the tap target).
///
/// - Every label fits an even share: an even split, as in the designs.
/// - Otherwise, if they fit together: the long labels get their natural
///   width and the others share the rest evenly.
/// - Otherwise: what each label needs above [minimum] is scaled down by the
///   same ratio (the labels then scale down too).
@visibleForTesting
List<double> segmentWidths({
  required double available,
  required List<double> natural,
  double minimum = 0,
}) {
  if (natural.isEmpty || !available.isFinite) return natural;
  final needed = [for (final width in natural) math.max(width, minimum)];
  final total = needed.fold<double>(0, (sum, width) => sum + width);
  if (total > available) {
    final floor = math.min(minimum, available / needed.length);
    final ratio =
        (available - floor * needed.length) / (total - floor * needed.length);
    return [for (final width in needed) floor + (width - floor) * ratio];
  }
  final widest = List<int>.generate(needed.length, (i) => i)
    ..sort((a, b) => needed[b].compareTo(needed[a]));
  final fixed = <int>{};
  var remaining = available;
  for (final i in widest) {
    if (needed[i] <= remaining / (needed.length - fixed.length)) break;
    fixed.add(i);
    remaining -= needed[i];
  }
  final share = remaining / (needed.length - fixed.length);
  return [
    for (var i = 0; i < needed.length; i++)
      if (fixed.contains(i)) needed[i] else share,
  ];
}
