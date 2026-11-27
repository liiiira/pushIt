import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/theme/app_theme.dart';
import 'package:pushit/core/design_system/tokens/app_sizes.dart';
import 'package:pushit/core/design_system/tokens/app_spacing.dart';
import 'package:pushit/core/design_system/widgets/app_button_size.dart';
import 'package:pushit/core/design_system/widgets/primary_button.dart';

/// A centred icon, title, text and small action: the empty (F2) and error
/// (I3) states.
///
/// Local until the shared `EmptyStateView` / `ErrorStateView` land
/// (issue #9).
class LibraryMessage extends StatelessWidget {
  const new({
    required this.icon,
    required this.title,
    required this.body,
    required this.actionLabel,
    required this.onAction,
    super.key,
  });

  final IconData icon;
  final String title;
  final String body;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.screenMargin),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: AppSizes.icon, color: colors.text),
            const SizedBox(height: AppSpacing.md),
            Text(
              title,
              style: styles.title.copyWith(color: colors.text),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              body,
              style: styles.body.copyWith(color: colors.sub),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: actionLabel,
              onPressed: onAction,
              size: AppButtonSize.small,
            ),
          ],
        ),
      ),
    );
  }
}
