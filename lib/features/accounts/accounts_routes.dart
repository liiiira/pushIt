import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/app/router/route_paths.dart';
import 'package:pushit/core/design_system/widgets/placeholder_page.dart';

/// C1 accounts (the Accounts tab), C2 add account and C4 account detail.
/// C3, C5 and C6 are sheets and dialogs, not routes.
List<RouteBase> accountsRoutes({
  required GlobalKey<NavigatorState> rootNavigatorKey,
}) => [
  GoRoute(
    path: RoutePaths.accounts,
    builder: (_, _) => const PlaceholderPage(screenId: 'C1'),
    routes: [
      GoRoute(
        path: RouteSegments.addAccount,
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const PlaceholderPage(screenId: 'C2'),
      ),
      GoRoute(
        path: RouteSegments.accountDetail,
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const PlaceholderPage(screenId: 'C4'),
      ),
    ],
  ),
];
