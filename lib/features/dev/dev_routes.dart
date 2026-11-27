import 'package:go_router/go_router.dart';
import 'package:pushit/app/router/route_paths.dart';
import 'package:pushit/core/design_system/widgets/placeholder_page.dart';

/// The Developer menu, nested under `/settings`. Debug builds only.
List<RouteBase> developerRoutes() => [
  GoRoute(
    path: RouteSegments.developer,
    builder: (_, _) => const PlaceholderPage(screenId: 'developer'),
  ),
];

/// The design-system gallery. Debug builds only.
List<RouteBase> devRoutes() => [
  GoRoute(
    path: RoutePaths.devComponents,
    builder: (_, _) => const PlaceholderPage(screenId: 'components'),
  ),
];
