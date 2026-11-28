import 'package:bloc/bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/preferences/app_preferences.dart';

/// The app's theme mode (System, Light or Dark), persisted in
/// [AppPreferences]. `PushItApp` provides it; the Appearance page changes
/// it.
class ThemeModeCubit extends Cubit<ThemeMode> {
  new(this._preferences) : super(_preferences.themeMode);

  final AppPreferences _preferences;

  Future<void> themeModeSelected(ThemeMode mode) async {
    if (mode == state) return;
    emit(mode);
    await _preferences.setThemeMode(mode);
  }
}
