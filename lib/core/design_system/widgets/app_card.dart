import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/theme/app_theme.dart';
import 'package:pushit/core/design_system/tokens/app_radii.dart';
import 'package:pushit/core/design_system/tokens/app_spacing.dart';

/// A flat `surface` container with card corners (20) and padding (16).
///
/// Tappable when [onTap] is given. Pass `EdgeInsets.zero` as [padding] to
/// hold a list of `AppListRow`s.
class AppCard extends StatelessWidget {
  const new({
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.cardPadding),
    this.onTap,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Padding(padding: padding, child: child);
    final onTap = this.onTap;
    return Material(
      color: context.colors.surface,
      borderRadius: const BorderRadius.all(Radius.circular(AppRadii.card)),
      clipBehavior: Clip.antiAlias,
      child: onTap == null ? content : InkWell(onTap: onTap, child: content),
    );
  }
}
