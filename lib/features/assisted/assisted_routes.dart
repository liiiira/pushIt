import 'package:go_router/go_router.dart';
import 'package:pushit/app/router/route_paths.dart';
import 'package:pushit/features/assisted/presentation/cubit/assisted_cubit.dart';
import 'package:pushit/features/assisted/presentation/pages/assisted_page.dart';

AssistedPage _page(GoRouterState state, AssistedMode mode) => AssistedPage(
  postId: state.pathParameters[RouteSegments.postId] ?? '',
  platformName: state.pathParameters[RouteSegments.platform] ?? '',
  mode: mode,
);

/// G2 assisted posting and G3 assisted delete, full screen. G1 is a
/// notification.
List<RouteBase> assistedRoutes() => [
  GoRoute(
    path: RoutePaths.assisted,
    builder: (_, state) => _page(state, AssistedMode.post),
    routes: [
      GoRoute(
        path: RouteSegments.delete,
        builder: (_, state) => _page(state, AssistedMode.delete),
      ),
    ],
  ),
];
