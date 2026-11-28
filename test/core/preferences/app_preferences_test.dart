import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/preferences/app_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('SharedAppPreferences', () {
    test('starts in light (Fog), not onboarded', () async {
      SharedPreferences.setMockInitialValues({});

      final preferences = await SharedAppPreferences.load();

      expect(preferences.themeMode, ThemeMode.light);
      expect(preferences.isOnboarded, isFalse);
    });

    test('keeps the theme mode and onboarding across launches', () async {
      SharedPreferences.setMockInitialValues({});
      final first = await SharedAppPreferences.load();

      await first.setThemeMode(ThemeMode.dark);
      await first.setOnboarded();
      final second = await SharedAppPreferences.load();

      expect(second.themeMode, ThemeMode.dark);
      expect(second.isOnboarded, isTrue);
    });

    test('emits the onboarded flag, then its changes', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedAppPreferences.load();
      final seen = <bool>[];
      final subscription = preferences.watchOnboarded().listen(seen.add);
      addTearDown(subscription.cancel);
      await pumpEventQueue();

      await preferences.setOnboarded();
      await pumpEventQueue();

      expect(seen, [false, true]);
    });

    test('reads every theme mode back', () async {
      for (final mode in ThemeMode.values) {
        SharedPreferences.setMockInitialValues({});
        await (await SharedAppPreferences.load()).setThemeMode(mode);

        expect((await SharedAppPreferences.load()).themeMode, mode);
      }
    });

    test('falls back to light on an unknown stored value', () async {
      SharedPreferences.setMockInitialValues({
        SharedAppPreferences.themeModeKey: 'sepia',
      });

      final preferences = await SharedAppPreferences.load();

      expect(preferences.themeMode, ThemeMode.light);
    });
  });
}
