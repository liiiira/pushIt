import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/tokens/app_colors.dart';

void main() {
  group('AppColors.light (Fog)', () {
    const colors = AppColors.light;

    test('matches the Figma variables', () {
      expect(colors.bg, const Color(0xFFEDEDED));
      expect(colors.surface, const Color(0xFFFFFFFF));
      expect(colors.block, const Color(0xFFC6C6C6));
      expect(colors.text, const Color(0xFF141414));
      expect(colors.sub, const Color(0xFF585858));
      expect(colors.accent, const Color(0xFF141414));
      expect(colors.onAccent, const Color(0xFFFFFFFF));
      expect(colors.line, const Color(0xFFD2D2D2));
    });

    test('scrim is #141414 at 45%', () {
      expect(colors.scrim.toARGB32() & 0x00FFFFFF, 0x141414);
      expect(colors.scrim.a, closeTo(0.45, 0.005));
    });

    test('dark brand glyphs are black', () {
      expect(colors.brandTikTok, const Color(0xFF000000));
      expect(colors.brandThreads, const Color(0xFF000000));
      expect(colors.brandX, const Color(0xFF000000));
    });
  });

  group('AppColors.dark', () {
    const colors = AppColors.dark;

    test('matches the Figma variables', () {
      expect(colors.bg, const Color(0xFF0B0B0B));
      expect(colors.surface, const Color(0xFF1E1E1E));
      expect(colors.block, const Color(0xFF3A3A3A));
      expect(colors.text, const Color(0xFFFFFFFF));
      expect(colors.sub, const Color(0xFFA3A3A3));
      expect(colors.accent, const Color(0xFFFFFFFF));
      expect(colors.onAccent, const Color(0xFF0B0B0B));
      expect(colors.line, const Color(0xFF333333));
    });

    test('scrim is black at 60%', () {
      expect(colors.scrim.toARGB32() & 0x00FFFFFF, 0x000000);
      expect(colors.scrim.a, closeTo(0.60, 0.005));
    });

    test('dark brand glyphs turn white', () {
      expect(colors.brandTikTok, const Color(0xFFFFFFFF));
      expect(colors.brandThreads, const Color(0xFFFFFFFF));
      expect(colors.brandX, const Color(0xFFFFFFFF));
    });
  });

  test('coloured brand glyphs are the same in both modes', () {
    for (final colors in [AppColors.light, AppColors.dark]) {
      expect(colors.brandYouTube, const Color(0xFFFF0000));
      expect(colors.brandInstagram, const Color(0xFFE4405F));
      expect(colors.brandFacebook, const Color(0xFF0866FF));
      expect(colors.brandLinkedIn, const Color(0xFF0A66C2));
      expect(colors.brandBluesky, const Color(0xFF0285FF));
    }
  });

  test('transparent has no alpha', () {
    expect(AppColors.transparent.a, 0);
  });

  test('copyWith replaces only the given colours', () {
    final copy = AppColors.light.copyWith(bg: AppColors.dark.bg);

    expect(copy.bg, AppColors.dark.bg);
    expect(copy.copyWith(bg: AppColors.light.bg), AppColors.light);
  });

  group('lerp', () {
    test('returns the ends at 0 and 1', () {
      expect(AppColors.light.lerp(AppColors.dark, 0), AppColors.light);
      expect(AppColors.light.lerp(AppColors.dark, 1), AppColors.dark);
    });

    test('blends every colour in between', () {
      final middle = AppColors.light.lerp(AppColors.dark, 0.5);

      expect(middle.bg, Color.lerp(AppColors.light.bg, AppColors.dark.bg, 0.5));
      expect(
        middle.brandX,
        Color.lerp(AppColors.light.brandX, AppColors.dark.brandX, 0.5),
      );
    });

    test('keeps itself when the other end is not AppColors', () {
      expect(AppColors.light.lerp(null, 0.5), AppColors.light);
    });
  });
}
