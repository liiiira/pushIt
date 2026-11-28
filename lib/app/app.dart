import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/app/app_repositories.dart';
import 'package:pushit/core/design_system/theme/app_theme.dart';
import 'package:pushit/core/l10n/l10n.dart';
import 'package:pushit/core/preferences/app_preferences.dart';
import 'package:pushit/core/theme_mode/theme_mode_cubit.dart';
import 'package:pushit/data/dependencies.dart';

/// The root widget, above the router:
/// - every repository of [dependencies] and the clock
///   (`MultiRepositoryProvider`);
/// - [preferences] and the [ThemeModeCubit] built from them, which picks
///   light (Fog, the default), dark or the system mode.
class PushItApp extends StatelessWidget {
  const new({
    required this.dependencies,
    required this.preferences,
    required this.router,
    super.key,
  });

  final Dependencies dependencies;
  final AppPreferences preferences;
  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        ...repositoryProvidersOf(dependencies),
        RepositoryProvider<AppPreferences>.value(value: preferences),
      ],
      child: BlocProvider(
        create: (_) => ThemeModeCubit(preferences),
        child: BlocBuilder<ThemeModeCubit, ThemeMode>(
          builder: (context, themeMode) => MaterialApp.router(
            routerConfig: router,
            onGenerateTitle: (context) => context.l10n.commonAppName,
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeMode,
            localizationsDelegates: appLocalizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          ),
        ),
      ),
    );
  }
}
