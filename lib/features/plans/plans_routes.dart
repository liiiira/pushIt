import 'package:go_router/go_router.dart';
import 'package:pushit/app/router/route_paths.dart';
import 'package:pushit/core/design_system/widgets/placeholder_page.dart';

/// H2 plans, nested under `/settings`. H3 is a sheet.
List<RouteBase> plansRoutes() => [
  GoRoute(
    path: RouteSegments.plans,
    builder: (_, _) => const PlaceholderPage(screenId: 'H2'),
  ),
];
