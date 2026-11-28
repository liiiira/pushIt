import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/tokens/app_typography.dart';

void _expectStyle(
  TextStyle style, {
  required int weight,
  required double size,
  required double height,
  required double letterSpacing,
}) {
  expect(style.fontFamily, AppTypography.fontFamily);
  expect(style.fontSize, size);
  expect(style.height, height);
  expect(style.letterSpacing, closeTo(letterSpacing, 0.0001));
  expect(style.fontWeight?.value, weight);
  // Hanken Grotesk ships as a variable font only, so the weight must also
  // be set on the `wght` axis.
  expect(style.fontVariations, [FontVariation.weight(weight.toDouble())]);
  expect(style.color, isNull, reason: 'the colour comes from the context');
}

void main() {
  const styles = AppTypography.standard;

  test('uses the bundled Hanken Grotesk', () {
    expect(AppTypography.fontFamily, 'HankenGrotesk');
  });

  test('h1: 700, 26 / 1.20, -1%', () {
    _expectStyle(
      styles.h1,
      weight: 700,
      size: 26,
      height: 1.2,
      letterSpacing: -0.26,
    );
  });

  test('time: 600, 64 / 1.00, -2%', () {
    _expectStyle(
      styles.time,
      weight: 600,
      size: 64,
      height: 1,
      letterSpacing: -1.28,
    );
  });

  test('title: 600, 20 / 1.25, -1%', () {
    _expectStyle(
      styles.title,
      weight: 600,
      size: 20,
      height: 1.25,
      letterSpacing: -0.2,
    );
  });

  test('body: 400, 15 / 1.45', () {
    _expectStyle(
      styles.body,
      weight: 400,
      size: 15,
      height: 1.45,
      letterSpacing: 0,
    );
  });

  test('bodyStrong: 600, 15 / 1.45', () {
    _expectStyle(
      styles.bodyStrong,
      weight: 600,
      size: 15,
      height: 1.45,
      letterSpacing: 0,
    );
  });

  test('small: 500, 12 / 1.35', () {
    _expectStyle(
      styles.small,
      weight: 500,
      size: 12,
      height: 1.35,
      letterSpacing: 0,
    );
  });

  test('tiny: 700, 10 / 1.20, +2%', () {
    _expectStyle(
      styles.tiny,
      weight: 700,
      size: 10,
      height: 1.2,
      letterSpacing: 0.2,
    );
  });

  test('button: 600, 16 / 1.20', () {
    _expectStyle(
      styles.button,
      weight: 600,
      size: 16,
      height: 1.2,
      letterSpacing: 0,
    );
  });

  test('copyWith replaces only the given styles', () {
    final copy = styles.copyWith(h1: styles.time);

    expect(copy.h1, styles.time);
    expect(copy.body, styles.body);
    expect(copy.copyWith(h1: styles.h1), styles);
  });

  group('lerp', () {
    final big = styles.copyWith(body: styles.body.copyWith(fontSize: 25));

    test('returns the ends at 0 and 1', () {
      expect(styles.lerp(big, 0), styles);
      expect(styles.lerp(big, 1), big);
    });

    test('blends the styles in between', () {
      expect(styles.lerp(big, 0.5).body.fontSize, 20);
    });

    test('keeps itself when the other end is not AppTypography', () {
      expect(styles.lerp(null, 0.5), styles);
    });
  });
}
