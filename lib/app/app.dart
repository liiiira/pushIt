import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/app/app_repositories.dart';
import 'package:pushit/core/design_system/theme/app_theme.dart';
import 'package:pushit/core/l10n/l10n.dart';
import 'package:pushit/data/dependencies.dart';

/// The root widget: exposes every repository of [dependencies] (and the
/// clock) through `MultiRepositoryProvider`, above the router.
///
/// Light (Fog) is the default until the theme mode cubit lands.
class PushItApp extends StatelessWidget {
  const new({required this.dependencies, required this.router, super.key});

  final Dependencies dependencies;
  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: repositoryProvidersOf(dependencies),
      child: MaterialApp.router(
        routerConfig: router,
        onGenerateTitle: (context) => context.l10n.commonAppName,
        theme: AppTheme.light(),
        darkTheme: AppTheme.dark(),
        themeMode: ThemeMode.light,
        localizationsDelegates: appLocalizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
      ),
    );
  }
}
