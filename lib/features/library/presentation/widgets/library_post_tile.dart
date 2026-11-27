import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/theme/app_theme.dart';
import 'package:pushit/core/design_system/tokens/app_sizes.dart';
import 'package:pushit/core/design_system/tokens/app_spacing.dart';
import 'package:pushit/core/design_system/widgets/platform_logo.dart';
import 'package:pushit/core/design_system/widgets/video_thumbnail.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/library/domain/post_summary.dart';
import 'package:pushit/features/library/presentation/widgets/post_labels.dart';

/// One post in the Library (F1): thumbnail, title, status line and the
/// platforms it goes to. Failed platforms show unselected.
class LibraryPostTile extends StatelessWidget {
  const new({
    required this.post,
    required this.now,
    required this.onTap,
    super.key,
  });

  /// The thumbnail width in the list; its height follows the 9:16 ratio.
  static const double thumbnailWidth = 52;

  final Post post;
  final DateTime now;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenMargin,
          vertical: AppSpacing.xs,
        ),
        child: Row(
          children: [
            const VideoThumbnail(width: thumbnailWidth, isSmall: true),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.title,
                    style: styles.bodyStrong.copyWith(color: colors.text),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    context.summaryLabel(summarizePost(post), now: now),
                    style: styles.small.copyWith(color: colors.sub),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(
                    spacing: AppSpacing.xs,
                    runSpacing: AppSpacing.xs,
                    children: [
                      for (final target in post.targets)
                        PlatformLogo(
                          platform: target.platform,
                          size: PlatformLogoSize.small,
                          isSelected: target.status != TargetStatus.failed,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.xs),
            Icon(
              LucideIcons.chevronRight,
              size: AppSizes.iconSmall,
              color: colors.sub,
            ),
          ],
        ),
      ),
    );
  }
}
