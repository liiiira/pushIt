import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:pushit/core/preferences/app_preferences.dart';

/// Pass to `pumpApp(router: …)` to verify navigation calls.
class MockGoRouter extends Mock implements GoRouter;

/// [AppPreferences] in memory, for widget and cubit tests.
final class InMemoryAppPreferences implements AppPreferences {
  new({this._themeMode = ThemeMode.light, this._isOnboarded = false});

  ThemeMode _themeMode;
  bool _isOnboarded;

  @override
  ThemeMode get themeMode => _themeMode;

  @override
  bool get isOnboarded => _isOnboarded;

  @override
  Future<void> setThemeMode(ThemeMode mode) async => _themeMode = mode;

  @override
  Future<void> setOnboarded() async => _isOnboarded = true;
}
