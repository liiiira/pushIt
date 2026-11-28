import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/theme/app_theme.dart';
import 'package:pushit/core/design_system/tokens/app_radii.dart';
import 'package:pushit/core/design_system/tokens/app_sizes.dart';
import 'package:pushit/core/design_system/tokens/app_spacing.dart';
import 'package:pushit/core/formatters.dart';

/// A 9:16 video placeholder in `block`, with an optional duration, play
/// icon and selection ring. The MVP has no real frames.
///
/// Fills the width it is given, or [width] when set. [isSmall] uses the
/// small corner radius of list and calendar rows.
class VideoThumbnail extends StatelessWidget {
  const new({
    this.width,
    this.duration,
    this.hasPlayIcon = false,
    this.isSelected = false,
    this.isSmall = false,
    this.semanticLabel,
    this.onTap,
    super.key,
  });

  static const ValueKey<String> frameKey = ValueKey('video-thumbnail-frame');
  static const ValueKey<String> playKey = ValueKey('video-thumbnail-play');

  final double? width;
  final Duration? duration;
  final bool hasPlayIcon;
  final bool isSelected;
  final bool isSmall;
  final String? semanticLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final duration = this.duration;
    final radius = BorderRadius.all(
      Radius.circular(isSmall ? AppRadii.thumbnailSmall : AppRadii.thumbnail),
    );
    final frame = Container(
      key: frameKey,
      decoration: BoxDecoration(
        color: colors.block,
        borderRadius: radius,
        border: isSelected
            ? Border.all(color: colors.text, width: AppSizes.selectionRingWidth)
            : null,
      ),
      child: Stack(
        children: [
          if (hasPlayIcon)
            Center(
              child: CustomPaint(
                key: playKey,
                size: const Size.square(AppSizes.icon),
                painter: _PlayTriangle(colors.text),
              ),
            ),
          if (duration != null)
            Positioned(
              left: AppSpacing.sm,
              bottom: AppSpacing.sm,
              right: AppSpacing.xxs,
              child: Text(
                formatClipDuration(duration),
                maxLines: 1,
                overflow: TextOverflow.clip,
                style: context.textStyles.small.copyWith(color: colors.text),
              ),
            ),
        ],
      ),
    );
    final onTap = this.onTap;
    final content = AspectRatio(
      aspectRatio: AppSizes.videoAspectRatio,
      child: onTap == null
          ? frame
          : Material(
              type: MaterialType.transparency,
              child: InkWell(onTap: onTap, borderRadius: radius, child: frame),
            ),
    );
    return Semantics(
      container: true,
      label: semanticLabel,
      button: onTap != null,
      selected: onTap == null ? null : isSelected,
      child: width == null ? content : SizedBox(width: width, child: content),
    );
  }
}

/// The solid play triangle of the designs (Lucide has an outline only).
class _PlayTriangle extends CustomPainter {
  const new(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.25, size.height * 0.15)
      ..lineTo(size.width * 0.85, size.height * 0.5)
      ..lineTo(size.width * 0.25, size.height * 0.85)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_PlayTriangle oldDelegate) => oldDelegate.color != color;
}
