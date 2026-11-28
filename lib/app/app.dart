import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/theme/app_theme.dart';
import 'package:pushit/core/l10n/l10n.dart';

/// The root widget.
///
/// Light (Fog) is the default. The theme mode cubit lands next in Phase 1;
/// once Agent B's `Dependencies` lands, it also exposes each repository
/// through `MultiRepositoryProvider`.
class PushItApp extends StatelessWidget {
  const new({required this.router, super.key});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      onGenerateTitle: (context) => context.l10n.commonAppName,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.light,
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
