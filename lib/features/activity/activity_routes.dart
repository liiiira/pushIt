import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/app/router/route_paths.dart';
import 'package:pushit/features/activity/presentation/pages/activity_page.dart';

/// B3 activity, nested under `/home`, full screen.
List<RouteBase> activityRoutes({
  required GlobalKey<NavigatorState> rootNavigatorKey,
}) => [
  GoRoute(
    path: RouteSegments.activity,
    parentNavigatorKey: rootNavigatorKey,
    builder: (_, _) => const ActivityPage(),
  ),
];
