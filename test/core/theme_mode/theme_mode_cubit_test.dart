import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/theme_mode/theme_mode_cubit.dart';

import '../../helpers/helpers.dart';

void main() {
  test('starts from the stored theme mode', () {
    final preferences = InMemoryAppPreferences(themeMode: ThemeMode.dark);

    expect(ThemeModeCubit(preferences).state, ThemeMode.dark);
  });

  late InMemoryAppPreferences preferences;

  blocTest<ThemeModeCubit, ThemeMode>(
    'emits and stores the selected mode',
    setUp: () => preferences = InMemoryAppPreferences(),
    build: () => ThemeModeCubit(preferences),
    act: (cubit) => cubit.themeModeSelected(ThemeMode.system),
    expect: () => [ThemeMode.system],
    verify: (_) => expect(preferences.themeMode, ThemeMode.system),
  );

  blocTest<ThemeModeCubit, ThemeMode>(
    'ignores the mode it already has',
    setUp: () => preferences = InMemoryAppPreferences(),
    build: () => ThemeModeCubit(preferences),
    act: (cubit) => cubit.themeModeSelected(ThemeMode.light),
    expect: () => <ThemeMode>[],
  );
}
