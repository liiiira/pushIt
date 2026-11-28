import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/theme/app_theme.dart';
import 'package:pushit/core/design_system/tokens/app_spacing.dart';
import 'package:pushit/core/design_system/widgets/app_card.dart';
import 'package:pushit/core/design_system/widgets/app_list_row.dart';
import 'package:pushit/core/design_system/widgets/platform_logo.dart';
import 'package:pushit/core/l10n/l10n.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/library/presentation/widgets/post_labels.dart';

/// Every platform of a post with its status, a link once published and a
/// retry once failed (F3, F4).
class PostTargetsCard extends StatelessWidget {
  const new({
    required this.post,
    required this.showsStatistics,
    required this.now,
    required this.busyPlatform,
    required this.onOpen,
    required this.onRetry,
    super.key,
  });

  final Post post;
  final bool showsStatistics;
  final DateTime now;
  final PlatformId? busyPlatform;
  final ValueChanged<Uri> onOpen;
  final ValueChanged<PlatformId> onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Column(
        children: [
          for (final target in post.targets)
            AppListRow(
              leading: PlatformLogo(
                platform: target.platform,
                size: PlatformLogoSize.small,
                isSelected: target.status != TargetStatus.failed,
              ),
              title: l10n.platformName(target.platform),
              subtitle: context.targetLabel(
                target,
                showsStatistics: showsStatistics,
                now: now,
              ),
              trailing: switch (target) {
                PostTarget(status: TargetStatus.failed) => IconButton(
                  icon: const Icon(LucideIcons.rotateCw),
                  color: colors.text,
                  tooltip: l10n.libraryDetailRetryOn(
                    l10n.platformName(target.platform),
                  ),
                  onPressed: busyPlatform == null
                      ? () => onRetry(target.platform)
                      : null,
                ),
                PostTarget(status: TargetStatus.published, :final url?) =>
                  IconButton(
                    icon: const Icon(LucideIcons.link),
                    color: colors.text,
                    tooltip: l10n.libraryDetailOpenOn(
                      l10n.platformName(target.platform),
                    ),
                    onPressed: () => onOpen(url),
                  ),
                _ => null,
              },
            ),
        ],
      ),
    );
  }
}
