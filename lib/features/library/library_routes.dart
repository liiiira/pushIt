import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/app/router/route_paths.dart';
import 'package:pushit/core/design_system/widgets/placeholder_page.dart';

/// F1–F2 (the Library tab), then F3–F7 full screen.
List<RouteBase> libraryRoutes({
  required GlobalKey<NavigatorState> rootNavigatorKey,
}) => [
  GoRoute(
    path: RoutePaths.library,
    builder: (_, _) => const PlaceholderPage(screenId: 'F1'),
    routes: [
      GoRoute(
        path: RouteSegments.libraryPost,
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const PlaceholderPage(screenId: 'F3'),
        routes: [
          GoRoute(
            path: RouteSegments.edit,
            parentNavigatorKey: rootNavigatorKey,
            builder: (_, _) => const PlaceholderPage(screenId: 'F5'),
          ),
          GoRoute(
            path: RouteSegments.delete,
            parentNavigatorKey: rootNavigatorKey,
            builder: (_, _) => const PlaceholderPage(screenId: 'F6'),
            routes: [
              GoRoute(
                path: RouteSegments.result,
                parentNavigatorKey: rootNavigatorKey,
                builder: (_, _) => const PlaceholderPage(screenId: 'F7'),
              ),
            ],
          ),
        ],
      ),
    ],
  ),
];
