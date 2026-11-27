import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/l10n/l10n.dart';

/// Stands in for a screen that is not built yet. Remove a route's
/// placeholder when its real page lands.
class PlaceholderPage extends StatelessWidget {
  const new({required this.screenId, super.key});

  /// The screen ID from docs/SCREENS.md, e.g. `F1`.
  final String screenId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Text(
            context.l10n.commonPlaceholderBody(screenId),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
