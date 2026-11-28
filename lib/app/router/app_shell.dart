import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/app/connectivity/connectivity_cubit.dart';
import 'package:pushit/app/router/route_paths.dart';
import 'package:pushit/core/design_system/theme/app_theme.dart';
import 'package:pushit/core/design_system/widgets/app_bottom_nav.dart';
import 'package:pushit/core/design_system/widgets/offline_banner.dart';
import 'package:pushit/core/l10n/l10n.dart';
import 'package:pushit/domain/domain.dart';

/// The frame around the four tabs: the offline banner (I1) on top while
/// offline, the current tab, and the bottom nav with the centre create
/// button, which opens the composer full screen.
class AppShell extends StatelessWidget {
  const new({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocProvider(
      create: (context) =>
          ConnectivityCubit(context.read<ConnectivityRepository>()),
      child: Scaffold(
        backgroundColor: context.colors.bg,
        body: BlocBuilder<ConnectivityCubit, bool>(
          builder: (context, isOnline) => Column(
            children: [
              if (!isOnline)
                const SafeArea(bottom: false, child: OfflineBanner()),
              Expanded(
                // The banner already took the top inset. go_router keys the
                // tab stack globally, so the tabs keep their state when the
                // banner comes and goes.
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: !isOnline,
                  child: navigationShell,
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: AppBottomNav(
          currentIndex: navigationShell.currentIndex,
          createLabel: l10n.commonNavCreate,
          onItemSelected: (index) => navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          ),
          onCreatePressed: () => context.push(RoutePaths.compose),
          items: [
            AppBottomNavItem(
              icon: LucideIcons.house,
              label: l10n.commonNavHome,
            ),
            AppBottomNavItem(
              icon: LucideIcons.calendar,
              label: l10n.commonNavCalendar,
            ),
            AppBottomNavItem(
              icon: LucideIcons.galleryVerticalEnd,
              label: l10n.commonNavLibrary,
            ),
            AppBottomNavItem(
              icon: LucideIcons.user,
              label: l10n.commonNavAccounts,
            ),
          ],
        ),
      ),
    );
  }
}
