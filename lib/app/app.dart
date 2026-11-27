import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/l10n/l10n.dart';

/// The root widget.
///
/// Phase 1 adds the themes and theme mode; once Agent B's `Dependencies`
/// lands, it also exposes each repository through `MultiRepositoryProvider`.
class PushItApp extends StatelessWidget {
  const new({required this.router, super.key});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      onGenerateTitle: (context) => context.l10n.commonAppName,
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
