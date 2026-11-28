import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// What the app remembers on the device: the theme mode and whether the
/// onboarding was done. Values are read once at launch and kept in memory.
abstract interface class AppPreferences {
  /// Light (Fog) until the user picks another mode.
  ThemeMode get themeMode;

  bool get isOnboarded;

  Future<void> setThemeMode(ThemeMode mode);

  Future<void> setOnboarded();
}

/// [AppPreferences] on `shared_preferences`.
final class SharedAppPreferences implements AppPreferences {
  new _(this._store);

  static const themeModeKey = 'themeMode';
  static const onboardedKey = 'isOnboarded';

  /// Reads the stored values. Call after
  /// `WidgetsFlutterBinding.ensureInitialized()`.
  static Future<SharedAppPreferences> load() async =>
      SharedAppPreferences._(await SharedPreferences.getInstance());

  final SharedPreferences _store;

  @override
  ThemeMode get themeMode {
    final name = _store.getString(themeModeKey);
    return ThemeMode.values.where((mode) => mode.name == name).firstOrNull ??
        ThemeMode.light;
  }

  @override
  bool get isOnboarded => _store.getBool(onboardedKey) ?? false;

  @override
  Future<void> setThemeMode(ThemeMode mode) =>
      _store.setString(themeModeKey, mode.name);

  @override
  Future<void> setOnboarded() => _store.setBool(onboardedKey, true);
}
