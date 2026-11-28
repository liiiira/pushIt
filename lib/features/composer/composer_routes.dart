import 'package:go_router/go_router.dart';
import 'package:pushit/app/router/route_paths.dart';
import 'package:pushit/core/design_system/widgets/placeholder_page.dart';
import 'package:pushit/features/composer/presentation/pages/composer_shell.dart';
import 'package:pushit/features/composer/presentation/pages/drafts_page.dart';
import 'package:pushit/features/composer/presentation/pages/pick_video_page.dart';
import 'package:pushit/features/composer/presentation/views/captions_view.dart';
import 'package:pushit/features/composer/presentation/views/composer_view.dart';
import 'package:pushit/features/composer/presentation/views/cover_view.dart';
import 'package:pushit/features/composer/presentation/views/tiktok_settings_view.dart';
import 'package:pushit/features/composer/presentation/views/upload_view.dart';

/// D1–D13, full screen on the root navigator. D9–D11 are sheets.
///
/// A shell route shares one `ComposerCubit` between the screens.
List<RouteBase> composerRoutes() => [
  ShellRoute(
    builder: (_, _, child) => ComposerShell(child: child),
    routes: [
      GoRoute(
        path: RoutePaths.compose,
        builder: (_, _) => const PickVideoPage(),
        routes: [
          GoRoute(
            path: RouteSegments.upload,
            builder: (_, _) => const UploadView(),
          ),
          GoRoute(
            path: RouteSegments.post,
            builder: (_, _) => const ComposerView(),
            routes: [
              GoRoute(
                path: RouteSegments.captions,
                builder: (_, _) => const CaptionsView(),
              ),
              GoRoute(
                path: RouteSegments.cover,
                builder: (_, _) => const CoverView(),
              ),
              GoRoute(
                path: RouteSegments.tiktok,
                builder: (_, _) => const TikTokSettingsView(),
              ),
              GoRoute(
                path: RouteSegments.check,
                builder: (_, _) => const PlaceholderPage(screenId: 'D8'),
              ),
            ],
          ),
          GoRoute(
            path: RouteSegments.drafts,
            builder: (_, _) => const DraftsPage(),
          ),
          GoRoute(
            path: RouteSegments.scheduled,
            builder: (_, _) => const PlaceholderPage(screenId: 'D13'),
          ),
        ],
      ),
    ],
  ),
];
