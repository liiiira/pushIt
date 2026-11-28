import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/app/router/route_paths.dart';

/// Leaves the composer: back to where it was opened from, or home when
/// it was the first screen.
void closeComposer(BuildContext context) {
  final root = Navigator.of(context, rootNavigator: true);
  if (root.canPop()) {
    root.pop();
  } else {
    context.go(RoutePaths.home);
  }
}
