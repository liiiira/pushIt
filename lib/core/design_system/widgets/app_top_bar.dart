import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/theme/app_theme.dart';
import 'package:pushit/core/design_system/tokens/app_sizes.dart';
import 'package:pushit/core/design_system/tokens/app_spacing.dart';
import 'package:pushit/core/l10n/l10n.dart';

/// What sits at the start of an [AppTopBar].
enum AppTopBarLeading { none, back, close }

/// The 56 dp bar of full-screen pages: back or close, a centred
/// `bodyStrong` title and an optional trailing action.
///
/// Use it as `Scaffold.appBar`. The leading button pops the route unless
/// [onLeadingPressed] is given.
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  const new({
    required this.title,
    this.leading = AppTopBarLeading.back,
    this.onLeadingPressed,
    this.trailing,
    super.key,
  });

  final String title;
  final AppTopBarLeading leading;
  final VoidCallback? onLeadingPressed;
  final Widget? trailing;

  @override
  Size get preferredSize => const Size.fromHeight(AppSizes.topBarHeight);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = context.l10n;
    void pop() => Navigator.maybePop(context);
    final leadingButton = switch (leading) {
      AppTopBarLeading.none => null,
      AppTopBarLeading.back => IconButton(
        icon: const Icon(LucideIcons.arrowLeft),
        color: colors.text,
        tooltip: l10n.commonBack,
        onPressed: onLeadingPressed ?? pop,
      ),
      AppTopBarLeading.close => IconButton(
        icon: const Icon(LucideIcons.x),
        color: colors.text,
        tooltip: l10n.commonClose,
        onPressed: onLeadingPressed ?? pop,
      ),
    };
    return Material(
      color: colors.bg,
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: AppSizes.topBarHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: NavigationToolbar(
              leading: leadingButton,
              middle: Semantics(
                header: true,
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: context.textStyles.bodyStrong.copyWith(
                    color: colors.text,
                  ),
                ),
              ),
              trailing: trailing,
              middleSpacing: AppSpacing.xs,
            ),
          ),
        ),
      ),
    );
  }
}
