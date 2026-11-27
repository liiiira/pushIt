import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/theme/app_theme.dart';
import 'package:pushit/core/design_system/tokens/app_radii.dart';
import 'package:pushit/core/design_system/tokens/app_sizes.dart';
import 'package:pushit/core/design_system/tokens/app_spacing.dart';
import 'package:pushit/features/library/presentation/widgets/library_post_tile.dart';

/// Placeholder rows while the Library loads (I2).
///
/// Local until the shared `SkeletonList` lands (issue #9).
class LibrarySkeleton extends StatelessWidget {
  const new({super.key});

  static const int _rows = 4;
  static const double _titleShare = 0.75;
  static const double _subtitleShare = 0.5;
  static const double _barHeight = AppSpacing.sm;

  @override
  Widget build(BuildContext context) {
    final block = context.colors.block;
    Widget bar(double share) => FractionallySizedBox(
      widthFactor: share,
      child: Container(
        height: _barHeight,
        decoration: BoxDecoration(
          color: block,
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
      ),
    );

    return ListView(
      key: const ValueKey('library-skeleton'),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (var i = 0; i < _rows; i++)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenMargin,
              vertical: AppSpacing.xs,
            ),
            child: Row(
              children: [
                Container(
                  width: LibraryPostTile.thumbnailWidth,
                  height:
                      LibraryPostTile.thumbnailWidth /
                      AppSizes.videoAspectRatio,
                  decoration: BoxDecoration(
                    color: block,
                    borderRadius: BorderRadius.circular(AppRadii.thumbnail),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      bar(_titleShare),
                      const SizedBox(height: AppSpacing.xs),
                      bar(_subtitleShare),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
