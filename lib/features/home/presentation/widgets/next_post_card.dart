import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/theme/app_theme.dart';
import 'package:pushit/core/design_system/tokens/app_sizes.dart';
import 'package:pushit/core/design_system/tokens/app_spacing.dart';
import 'package:pushit/core/design_system/widgets/app_card.dart';
import 'package:pushit/core/design_system/widgets/platform_logo.dart';
import 'package:pushit/core/design_system/widgets/video_thumbnail.dart';
import 'package:pushit/core/formatters.dart';
import 'package:pushit/core/l10n/l10n.dart';
import 'package:pushit/domain/domain.dart';

/// The next post (B1): thumbnail, title, length and platforms. Opens the
/// post (F3).
class NextPostCard extends StatelessWidget {
  const new({required this.post, required this.onTap, super.key});

  /// The thumbnail width; its height follows the 9:16 ratio (B1).
  static const double thumbnailWidth = 62;

  final Post post;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final styles = context.textStyles;
    final platforms = {for (final target in post.targets) target.platform};
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Row(
        children: [
          VideoThumbnail(
            width: thumbnailWidth,
            isSmall: true,
            duration: post.video.duration,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: styles.bodyStrong.copyWith(color: colors.text),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  l10n.homePostDetails(
                    formatClipDuration(post.video.duration),
                    platforms.length,
                  ),
                  style: styles.small.copyWith(color: colors.sub),
                ),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: AppSpacing.xxs,
                  runSpacing: AppSpacing.xxs,
                  children: [
                    for (final platform in platforms)
                      PlatformLogo(
                        platform: platform,
                        size: PlatformLogoSize.small,
                      ),
                  ],
                ),
              ],
            ),
          ),
          Icon(
            LucideIcons.chevronRight,
            size: AppSizes.iconSmall,
            color: colors.text,
          ),
        ],
      ),
    );
  }
}
