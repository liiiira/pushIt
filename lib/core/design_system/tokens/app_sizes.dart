import 'package:flutter/widgets.dart';

/// Component sizes (docs/DESIGN_TOKENS.md), in dp.
abstract final class AppSizes {
  static const double buttonHeight = 56;
  static const double buttonHeightSmall = 40;
  static const double topBarHeight = 56;

  /// Plus the system gesture inset.
  static const double bottomNavHeight = 64;

  static const createButton = Size(56, 40);

  static const double icon = 24;
  static const double iconSmall = 20;
  static const double iconTiny = 16;

  /// Every tappable element is at least this wide and high.
  static const double minTapTarget = 48;

  static const double platformLogoLarge = 48;
  static const double platformLogoSmall = 28;
  static const double platformGlyphLarge = 24;
  static const double platformGlyphSmall = 14;

  /// Stroke of platform logo rings and other outlines.
  static const double ringWidth = 1.5;

  static const double avatar = 36;

  /// The avatar on Settings.
  static const double avatarLarge = 56;

  static const switchTrack = Size(52, 32);
  static const double switchThumb = 24;
  static const double checkbox = 24;
  static const double radio = 24;

  /// Width over height of every video preview (9:16).
  static const double videoAspectRatio = 9 / 16;

  /// The video preview on the composer.
  static const composerPreview = Size(126, 224);

  /// Gallery tile width = (available width − 2 × [galleryGap]) / 3.
  static const int galleryColumns = 3;
  static const double galleryGap = 8;

  static const double progressBar = 6;
}
