import 'package:go_router/go_router.dart';
import 'package:pushit/app/router/route_paths.dart';
import 'package:pushit/core/design_system/widgets/placeholder_page.dart';

/// D1–D13, full screen on the root navigator. D9–D11 are sheets.
List<RouteBase> composerRoutes() => [
  GoRoute(
    path: RoutePaths.compose,
    builder: (_, _) => const PlaceholderPage(screenId: 'D1'),
    routes: [
      GoRoute(
        path: RouteSegments.upload,
        builder: (_, _) => const PlaceholderPage(screenId: 'D2'),
      ),
      GoRoute(
        path: RouteSegments.post,
        builder: (_, _) => const PlaceholderPage(screenId: 'D4'),
        routes: [
          GoRoute(
            path: RouteSegments.captions,
            builder: (_, _) => const PlaceholderPage(screenId: 'D5'),
          ),
          GoRoute(
            path: RouteSegments.cover,
            builder: (_, _) => const PlaceholderPage(screenId: 'D6'),
          ),
          GoRoute(
            path: RouteSegments.tiktok,
            builder: (_, _) => const PlaceholderPage(screenId: 'D7'),
          ),
          GoRoute(
            path: RouteSegments.check,
            builder: (_, _) => const PlaceholderPage(screenId: 'D8'),
          ),
        ],
      ),
      GoRoute(
        path: RouteSegments.drafts,
        builder: (_, _) => const PlaceholderPage(screenId: 'D12'),
      ),
      GoRoute(
        path: RouteSegments.scheduled,
        builder: (_, _) => const PlaceholderPage(screenId: 'D13'),
      ),
    ],
  ),
];
