import 'package:go_router/go_router.dart';
import 'package:pushit/app/router/route_paths.dart';
import 'package:pushit/core/design_system/widgets/placeholder_page.dart';

/// H1 settings, H4 notifications, H5 invite, H6 feedback and the Appearance
/// page, full screen. H7 is a dialog. [children] are other features' routes
/// nested under `/settings`, composed by the app router.
List<RouteBase> settingsRoutes({List<RouteBase> children = const []}) => [
  GoRoute(
    path: RoutePaths.settings,
    builder: (_, _) => const PlaceholderPage(screenId: 'H1'),
    routes: [
      GoRoute(
        path: RouteSegments.notifications,
        builder: (_, _) => const PlaceholderPage(screenId: 'H4'),
      ),
      GoRoute(
        path: RouteSegments.invite,
        builder: (_, _) => const PlaceholderPage(screenId: 'H5'),
      ),
      GoRoute(
        path: RouteSegments.feedback,
        builder: (_, _) => const PlaceholderPage(screenId: 'H6'),
      ),
      GoRoute(
        path: RouteSegments.appearance,
        builder: (_, _) => const PlaceholderPage(screenId: 'appearance'),
      ),
      ...children,
    ],
  ),
];
