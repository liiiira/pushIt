import 'package:go_router/go_router.dart';
import 'package:pushit/app/router/route_paths.dart';
import 'package:pushit/core/design_system/widgets/placeholder_page.dart';

/// G2 assisted posting and G3 assisted delete, full screen. G1 is a
/// notification.
List<RouteBase> assistedRoutes() => [
  GoRoute(
    path: RoutePaths.assisted,
    builder: (_, _) => const PlaceholderPage(screenId: 'G2'),
    routes: [
      GoRoute(
        path: RouteSegments.delete,
        builder: (_, _) => const PlaceholderPage(screenId: 'G3'),
      ),
    ],
  ),
];
