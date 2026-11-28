import 'package:go_router/go_router.dart';
import 'package:pushit/app/router/route_paths.dart';
import 'package:pushit/features/home/presentation/pages/home_page.dart';

/// B1 home and B2 first use (the Home tab). [children] are other features'
/// routes nested under `/home`, composed by the app router.
List<RouteBase> homeRoutes({List<RouteBase> children = const []}) => [
  GoRoute(
    path: RoutePaths.home,
    builder: (_, _) => const HomePage(),
    routes: children,
  ),
];
