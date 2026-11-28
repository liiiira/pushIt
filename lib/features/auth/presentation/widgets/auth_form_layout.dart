import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/theme/app_theme.dart';
import 'package:pushit/core/design_system/tokens/app_sizes.dart';
import 'package:pushit/core/design_system/tokens/app_spacing.dart';
import 'package:pushit/core/design_system/widgets/app_top_bar.dart';

/// The frame of the auth screens (A5–A8): an optional back arrow, an `h1`
/// title and a `sub` line, the [fields] scrolling, and the [actions]
/// pinned at the bottom.
class AuthFormLayout extends StatelessWidget {
  const new({
    required this.title,
    required this.subtitle,
    required this.fields,
    required this.actions,
    this.icon,
    this.hasBack = false,
    this.onBack,
    super.key,
  });

  final String title;
  final String subtitle;
  final List<Widget> fields;

  /// Stacked full width; the first is the main one.
  final List<Widget> actions;

  /// Shown in a round badge above the title (A7).
  final IconData? icon;

  /// A back arrow on top (A7, A8); it pops unless [onBack] is given.
  final bool hasBack;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;
    return Scaffold(
      backgroundColor: colors.bg,
      appBar: hasBack ? AppTopBar(title: '', onLeadingPressed: onBack) : null,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  AppSpacing.screenMargin,
                  hasBack ? AppSpacing.md : AppSizes.topBarHeight,
                  AppSpacing.screenMargin,
                  AppSpacing.xl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (icon case final icon?) ...[
                      Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Container(
                          width: AppSizes.iconCircle,
                          height: AppSizes.iconCircle,
                          decoration: BoxDecoration(
                            color: colors.surface,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            icon,
                            size: AppSizes.icon,
                            color: colors.text,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                    Semantics(
                      header: true,
                      child: Text(
                        title,
                        style: styles.h1.copyWith(color: colors.text),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      subtitle,
                      style: styles.body.copyWith(color: colors.sub),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    ...fields,
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenMargin,
                AppSpacing.xs,
                AppSpacing.screenMargin,
                AppSpacing.xl,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (index, action) in actions.indexed) ...[
                    if (index > 0) const SizedBox(height: AppSpacing.xxs),
                    action,
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
