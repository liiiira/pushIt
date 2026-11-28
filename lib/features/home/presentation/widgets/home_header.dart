import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/app/router/route_paths.dart';
import 'package:pushit/core/design_system/theme/app_theme.dart';
import 'package:pushit/core/design_system/tokens/app_spacing.dart';
import 'package:pushit/core/design_system/widgets/initials_avatar.dart';
import 'package:pushit/core/l10n/l10n.dart';

/// The wordmark, the bell (activity, B3) and the avatar (settings, H1).
class HomeHeader extends StatelessWidget {
  const new({required this.userName, super.key});

  /// `null` until the user is known: the avatar waits.
  final String? userName;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final userName = this.userName;
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        start: AppSpacing.screenMargin,
        end: AppSpacing.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                l10n.commonAppName,
                style: context.textStyles.h1.copyWith(color: colors.text),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(LucideIcons.bell),
            color: colors.text,
            tooltip: l10n.homeActivity,
            onPressed: () => context.push(RoutePaths.activity),
          ),
          if (userName != null)
            InitialsAvatar(
              name: userName,
              semanticLabel: l10n.homeSettings,
              onTap: () => context.push(RoutePaths.settings),
            ),
        ],
      ),
    );
  }
}
