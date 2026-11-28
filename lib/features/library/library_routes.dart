import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/app/router/route_paths.dart';
import 'package:pushit/features/library/presentation/pages/delete_confirm_page.dart';
import 'package:pushit/features/library/presentation/pages/delete_result_page.dart';
import 'package:pushit/features/library/presentation/pages/edit_everywhere_page.dart';
import 'package:pushit/features/library/presentation/pages/library_page.dart';
import 'package:pushit/features/library/presentation/pages/post_detail_page.dart';

String _postIdOf(GoRouterState state) =>
    state.pathParameters[RouteSegments.postId] ?? '';

/// F1–F2 (the Library tab), then F3–F7 full screen.
List<RouteBase> libraryRoutes({
  required GlobalKey<NavigatorState> rootNavigatorKey,
}) => [
  GoRoute(
    path: RoutePaths.library,
    builder: (_, _) => const LibraryPage(),
    routes: [
      GoRoute(
        path: RouteSegments.libraryPost,
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, state) => PostDetailPage(postId: _postIdOf(state)),
        routes: [
          GoRoute(
            path: RouteSegments.edit,
            parentNavigatorKey: rootNavigatorKey,
            builder: (_, state) => EditEverywherePage(postId: _postIdOf(state)),
          ),
          GoRoute(
            path: RouteSegments.delete,
            parentNavigatorKey: rootNavigatorKey,
            builder: (_, state) => DeleteConfirmPage(postId: _postIdOf(state)),
            routes: [
              GoRoute(
                path: RouteSegments.result,
                parentNavigatorKey: rootNavigatorKey,
                builder: (_, state) =>
                    DeleteResultPage(postId: _postIdOf(state)),
              ),
            ],
          ),
        ],
      ),
    ],
  ),
];
