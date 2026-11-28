import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/theme/app_theme.dart';
import 'package:pushit/core/design_system/tokens/app_radii.dart';
import 'package:pushit/core/design_system/tokens/app_spacing.dart';
import 'package:pushit/core/l10n/l10n.dart';

/// I2: `block` placeholder rows (a small thumbnail and two text bars),
/// shown while a list page is loading. Reads out as "Loading".
class SkeletonList extends StatelessWidget {
  const new({this.rowCount = 4, super.key});

  final int rowCount;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      label: context.l10n.commonLoading,
      child: ExcludeSemantics(
        child: ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenMargin,
            vertical: AppSpacing.md,
          ),
          itemCount: rowCount,
          separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (_, _) => const _SkeletonRow(),
        ),
      ),
    );
  }
}

class _SkeletonRow extends StatelessWidget {
  const new();

  // The row's proportions on I2.
  static const _thumbnail = Size(46, 80);
  static const _barHeight = 10.0;
  static const _longBar = 0.7;
  static const _shortBar = 0.45;

  @override
  Widget build(BuildContext context) {
    final block = context.colors.block;
    Widget bar(double widthFactor) => FractionallySizedBox(
      alignment: AlignmentDirectional.centerStart,
      widthFactor: widthFactor,
      child: Container(
        height: _barHeight,
        decoration: BoxDecoration(
          color: block,
          borderRadius: const BorderRadius.all(Radius.circular(AppRadii.pill)),
        ),
      ),
    );
    return Row(
      children: [
        Container(
          width: _thumbnail.width,
          height: _thumbnail.height,
          decoration: BoxDecoration(
            color: block,
            borderRadius: const BorderRadius.all(
              Radius.circular(AppRadii.thumbnailSmall),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              bar(_longBar),
              const SizedBox(height: AppSpacing.sm),
              bar(_shortBar),
            ],
          ),
        ),
      ],
    );
  }
}
