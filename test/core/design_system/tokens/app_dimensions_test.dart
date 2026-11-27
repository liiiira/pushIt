import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/tokens/app_durations.dart';
import 'package:pushit/core/design_system/tokens/app_radii.dart';
import 'package:pushit/core/design_system/tokens/app_sizes.dart';
import 'package:pushit/core/design_system/tokens/app_spacing.dart';

void main() {
  test('spacing scale', () {
    expect(
      [
        AppSpacing.xxs,
        AppSpacing.xs,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.xxl,
        AppSpacing.xxxl,
      ],
      [4, 8, 12, 16, 20, 24, 32, 40],
    );
    expect(AppSpacing.screenMargin, 24);
    expect(AppSpacing.cardPadding, 16);
  });

  test('radii', () {
    expect(AppRadii.card, 20);
    expect(AppRadii.input, 14);
    expect(AppRadii.sheet, 28);
    expect(AppRadii.thumbnail, 12);
    expect(AppRadii.thumbnailSmall, 8);
    expect(AppRadii.pill, 999);
    expect(AppRadii.createButton, 14);
  });

  test('sizes', () {
    expect(AppSizes.buttonHeight, 56);
    expect(AppSizes.buttonHeightSmall, 40);
    expect(AppSizes.topBarHeight, 56);
    expect(AppSizes.bottomNavHeight, 64);
    expect(AppSizes.createButton, const Size(56, 40));
    expect(AppSizes.icon, 24);
    expect(AppSizes.iconSmall, 20);
    expect(AppSizes.iconTiny, 16);
    expect(AppSizes.minTapTarget, 48);
    expect(AppSizes.platformLogoLarge, 48);
    expect(AppSizes.platformLogoSmall, 28);
    expect(AppSizes.platformGlyphLarge, 24);
    expect(AppSizes.platformGlyphSmall, 14);
    expect(AppSizes.ringWidth, 1.5);
    expect(AppSizes.avatar, 36);
    expect(AppSizes.avatarLarge, 56);
    expect(AppSizes.switchTrack, const Size(52, 32));
    expect(AppSizes.switchThumb, 24);
    expect(AppSizes.checkbox, 24);
    expect(AppSizes.radio, 24);
    expect(AppSizes.videoAspectRatio, 9 / 16);
    expect(AppSizes.composerPreview, const Size(126, 224));
    expect(AppSizes.galleryColumns, 3);
    expect(AppSizes.galleryGap, 8);
    expect(AppSizes.progressBar, 6);
  });

  test('durations', () {
    expect(AppDurations.fast, const Duration(milliseconds: 150));
    expect(AppDurations.normal, const Duration(milliseconds: 250));
    expect(AppDurations.slow, const Duration(milliseconds: 400));
    expect(AppDurations.fakeLatency, const Duration(milliseconds: 400));
    expect(AppDurations.fakeLatencySlow, const Duration(seconds: 2));
  });
}
