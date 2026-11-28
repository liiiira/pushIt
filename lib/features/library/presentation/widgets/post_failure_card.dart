import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/theme/app_theme.dart';
import 'package:pushit/core/design_system/tokens/app_sizes.dart';
import 'package:pushit/core/design_system/tokens/app_spacing.dart';
import 'package:pushit/core/design_system/widgets/app_button_size.dart';
import 'package:pushit/core/design_system/widgets/app_card.dart';
import 'package:pushit/core/design_system/widgets/primary_button.dart';
import 'package:pushit/core/l10n/l10n.dart';
import 'package:pushit/domain/domain.dart';

/// Why a platform failed, with reconnect-and-retry or retry (F4).
class PostFailureCard extends StatelessWidget {
  const new({
    required this.target,
    required this.isBusy,
    required this.onRetry,
    required this.onReconnectAndRetry,
    super.key,
  });

  final PostTarget target;
  final bool isBusy;
  final VoidCallback onRetry;
  final VoidCallback onReconnectAndRetry;

  bool get _isSignedOut =>
      target.failureReason == TargetFailureReason.signInExpired;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final styles = context.textStyles;
    final platform = l10n.platformName(target.platform);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.circleAlert,
                size: AppSizes.iconSmall,
                color: colors.text,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  l10n.libraryDetailFailedTitle(platform),
                  style: styles.bodyStrong.copyWith(color: colors.text),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _isSignedOut
                ? l10n.libraryDetailFailedSignedOut(platform)
                : l10n.libraryDetailFailedOther(platform),
            style: styles.small.copyWith(color: colors.text),
          ),
          const SizedBox(height: AppSpacing.md),
          PrimaryButton(
            label: _isSignedOut
                ? l10n.libraryDetailReconnectAndRetry
                : l10n.libraryDetailRetry,
            size: AppButtonSize.small,
            onPressed: isBusy
                ? null
                : (_isSignedOut ? onReconnectAndRetry : onRetry),
          ),
        ],
      ),
    );
  }
}
