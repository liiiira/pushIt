import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/theme/app_theme.dart';
import 'package:pushit/core/design_system/tokens/app_spacing.dart';
import 'package:pushit/core/design_system/widgets/video_thumbnail.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/library/presentation/widgets/post_labels.dart';

/// Thumbnail, title, status and date, and caption (F3, F4).
class PostDetailHeader extends StatelessWidget {
  const new({required this.post, super.key});

  static const double thumbnailWidth = 70;
  static const int captionLines = 3;

  final Post post;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        VideoThumbnail(width: thumbnailWidth, duration: post.video.duration),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: styles.title.copyWith(color: colors.text),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  context.postHeaderLabel(post),
                  style: styles.small.copyWith(color: colors.sub),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  post.caption,
                  style: styles.body.copyWith(color: colors.sub),
                  maxLines: captionLines,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
