import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/theme/app_theme.dart';
import 'package:pushit/core/design_system/tokens/app_sizes.dart';
import 'package:pushit/core/design_system/tokens/app_spacing.dart';

/// One row of a list or a card: leading, title over subtitle, then a
/// strong value, a trailing widget and a chevron, all optional.
///
/// - [isTitleMuted] shows the title in `sub`, for label and value rows
///   ("Mode … Assisted").
/// - The value, trailing widget and chevron take at most
///   [_trailingShare] of the width; long text ellipsises instead of
///   overflowing.
/// - Tappable when [onTap] is given; always at least 48 dp high.
class AppListRow extends StatelessWidget {
  const new({
    required this.title,
    this.subtitle,
    this.leading,
    this.value,
    this.trailing,
    this.hasChevron = false,
    this.isTitleMuted = false,
    this.onTap,
    super.key,
  });

  static const _trailingShare = 0.6;

  final String title;
  final String? subtitle;
  final Widget? leading;
  final String? value;
  final Widget? trailing;
  final bool hasChevron;
  final bool isTitleMuted;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;
    final leading = this.leading;
    final subtitle = this.subtitle;
    final value = this.value;
    final trailing = this.trailing;
    final hasEnd = value != null || trailing != null || hasChevron;

    final row = ConstrainedBox(
      constraints: const BoxConstraints(minHeight: AppSizes.minTapTarget),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) => Row(
            children: [
              if (leading != null) ...[
                IconTheme.merge(
                  data: IconThemeData(color: colors.text, size: AppSizes.icon),
                  child: leading,
                ),
                const SizedBox(width: AppSpacing.sm),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: styles.body.copyWith(
                        color: isTitleMuted ? colors.sub : colors.text,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: styles.small.copyWith(color: colors.sub),
                      ),
                  ],
                ),
              ),
              if (hasEnd) ...[
                const SizedBox(width: AppSpacing.sm),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth * _trailingShare,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (value != null)
                        Flexible(
                          child: Text(
                            value,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                            style: styles.bodyStrong.copyWith(
                              color: colors.text,
                            ),
                          ),
                        ),
                      if (trailing != null) ...[
                        if (value != null) const SizedBox(width: AppSpacing.xs),
                        Flexible(child: trailing),
                      ],
                      if (hasChevron) ...[
                        if (value != null || trailing != null)
                          const SizedBox(width: AppSpacing.xxs),
                        Icon(
                          LucideIcons.chevronRight,
                          size: AppSizes.iconSmall,
                          color: colors.text,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
    final onTap = this.onTap;
    return MergeSemantics(
      child: onTap == null ? row : InkWell(onTap: onTap, child: row),
    );
  }
}
