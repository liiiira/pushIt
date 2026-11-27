import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/l10n/l10n.dart';

/// The frame around the four tabs.
///
/// Phase 0: a plain `NavigationBar`. Phase 1 replaces it with
/// `AppBottomNav` (centre create button) and adds the offline banner slot.
class AppShell extends StatelessWidget {
  const new({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) => navigationShell.goBranch(
          index,
          initialLocation: index == navigationShell.currentIndex,
        ),
        destinations: [
          NavigationDestination(
            icon: const Icon(LucideIcons.house),
            label: l10n.commonNavHome,
          ),
          NavigationDestination(
            icon: const Icon(LucideIcons.calendar),
            label: l10n.commonNavCalendar,
          ),
          NavigationDestination(
            icon: const Icon(LucideIcons.clapperboard),
            label: l10n.commonNavLibrary,
          ),
          NavigationDestination(
            icon: const Icon(LucideIcons.circleUser),
            label: l10n.commonNavAccounts,
          ),
        ],
      ),
    );
  }
}
