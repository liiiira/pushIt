import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/theme/app_theme.dart';
import 'package:pushit/core/design_system/tokens/app_radii.dart';
import 'package:pushit/core/design_system/tokens/app_sizes.dart';
import 'package:pushit/core/design_system/tokens/app_spacing.dart';

/// One tab of the [AppBottomNav].
@immutable
final class AppBottomNavItem {
  const new({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

/// The bottom nav of the four tab roots: two tabs, the centre create
/// button (56 × 40, `accent`), two tabs. On `bg`, 64 dp plus the gesture
/// inset; the current tab is in `text`, the others in `sub`.
class AppBottomNav extends StatelessWidget {
  const new({
    required this.items,
    required this.currentIndex,
    required this.createLabel,
    required this.onItemSelected,
    required this.onCreatePressed,
    super.key,
  }) : assert(items.length == 4, 'The design has four tabs.');

  static const ValueKey<String> barKey = ValueKey('bottom-nav-bar');
  static const ValueKey<String> createKey = ValueKey('bottom-nav-create');

  final List<AppBottomNavItem> items;
  final int currentIndex;

  /// The screen-reader label of the create button.
  final String createLabel;
  final ValueChanged<int> onItemSelected;
  final VoidCallback onCreatePressed;

  @override
  Widget build(BuildContext context) {
    Widget tab(int index) => Expanded(
      child: _Tab(
        item: items[index],
        isSelected: index == currentIndex,
        onTap: () => onItemSelected(index),
      ),
    );
    return ColoredBox(
      key: barKey,
      color: context.colors.bg,
      child: SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: AppSizes.bottomNavHeight,
          ),
          child: Row(
            children: [
              tab(0),
              tab(1),
              Expanded(
                child: _CreateButton(
                  label: createLabel,
                  onPressed: onCreatePressed,
                ),
              ),
              tab(2),
              tab(3),
            ],
          ),
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const new({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final AppBottomNavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final color = isSelected ? colors.text : colors.sub;
    return Semantics(
      container: true,
      button: true,
      selected: isSelected,
      child: InkResponse(
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: AppSizes.bottomNavHeight,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(item.icon, size: AppSizes.icon, color: color),
              const SizedBox(height: AppSpacing.xxs),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  item.label,
                  maxLines: 1,
                  style: context.textStyles.tiny.copyWith(color: color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateButton extends StatelessWidget {
  const new({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    const radius = BorderRadius.all(Radius.circular(AppRadii.createButton));
    return Semantics(
      container: true,
      button: true,
      label: label,
      child: InkResponse(
        onTap: onPressed,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: AppSizes.minTapTarget,
            minHeight: AppSizes.minTapTarget,
          ),
          child: Center(
            heightFactor: 1,
            child: Container(
              key: AppBottomNav.createKey,
              width: AppSizes.createButton.width,
              height: AppSizes.createButton.height,
              decoration: BoxDecoration(
                color: colors.accent,
                borderRadius: radius,
              ),
              child: Icon(
                LucideIcons.plus,
                size: AppSizes.icon,
                color: colors.onAccent,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
