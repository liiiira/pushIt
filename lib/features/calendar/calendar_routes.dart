import 'package:go_router/go_router.dart';
import 'package:pushit/app/router/route_paths.dart';
import 'package:pushit/core/design_system/widgets/placeholder_page.dart';

/// E1–E3 (the Calendar tab). E4 is a sheet.
List<RouteBase> calendarRoutes() => [
  GoRoute(
    path: RoutePaths.calendar,
    builder: (_, _) => const PlaceholderPage(screenId: 'E1'),
  ),
];
