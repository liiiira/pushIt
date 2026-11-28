import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/theme/app_theme.dart';
import 'package:pushit/core/design_system/tokens/app_sizes.dart';
import 'package:pushit/core/design_system/tokens/app_spacing.dart';
import 'package:pushit/core/l10n/l10n.dart';

/// I1: a full-width `accent` band, "No connection. Scheduled posts still go
/// out." The app shell shows it while offline; it is announced when it
/// appears.
class OfflineBanner extends StatelessWidget {
  const new({super.key});

  static const ValueKey<String> bandKey = ValueKey('offline-band');

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Semantics(
      container: true,
      liveRegion: true,
      child: ColoredBox(
        key: bandKey,
        color: colors.accent,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.screenMargin,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            children: [
              Icon(
                LucideIcons.wifiOff,
                size: AppSizes.iconTiny,
                color: colors.onAccent,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  context.l10n.commonOfflineBanner,
                  style: context.textStyles.small.copyWith(
                    color: colors.onAccent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
