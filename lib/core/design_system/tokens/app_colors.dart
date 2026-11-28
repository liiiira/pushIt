import 'package:equatable/equatable.dart';
import 'package:material_ui/material_ui.dart';

/// The colour tokens (docs/DESIGN_TOKENS.md), one set per theme mode.
///
/// Read them with `context.colors`. Greys only, plus the brand colours,
/// which are for platform logo glyphs and nothing else.
@immutable
final class AppColors extends ThemeExtension<AppColors> with Equatable {
  const new({
    required this.bg,
    required this.surface,
    required this.block,
    required this.text,
    required this.sub,
    required this.accent,
    required this.onAccent,
    required this.line,
    required this.scrim,
    required this.brandYouTube,
    required this.brandInstagram,
    required this.brandFacebook,
    required this.brandLinkedIn,
    required this.brandBluesky,
    required this.brandTikTok,
    required this.brandThreads,
    required this.brandX,
  });

  /// Light (Fog), the default.
  static const light = AppColors(
    bg: Color(0xFFEDEDED),
    surface: Color(0xFFFFFFFF),
    block: Color(0xFFC6C6C6),
    text: Color(0xFF141414),
    sub: Color(0xFF585858),
    accent: Color(0xFF141414),
    onAccent: Color(0xFFFFFFFF),
    line: Color(0xFFD2D2D2),
    // #141414 at 45%.
    scrim: Color(0x73141414),
    brandYouTube: _youTube,
    brandInstagram: _instagram,
    brandFacebook: _facebook,
    brandLinkedIn: _linkedIn,
    brandBluesky: _bluesky,
    brandTikTok: Color(0xFF000000),
    brandThreads: Color(0xFF000000),
    brandX: Color(0xFF000000),
  );

  static const dark = AppColors(
    bg: Color(0xFF0B0B0B),
    surface: Color(0xFF1E1E1E),
    block: Color(0xFF3A3A3A),
    text: Color(0xFFFFFFFF),
    sub: Color(0xFFA3A3A3),
    accent: Color(0xFFFFFFFF),
    onAccent: Color(0xFF0B0B0B),
    line: Color(0xFF333333),
    // #000000 at 60%.
    scrim: Color(0x99000000),
    brandYouTube: _youTube,
    brandInstagram: _instagram,
    brandFacebook: _facebook,
    brandLinkedIn: _linkedIn,
    brandBluesky: _bluesky,
    brandTikTok: Color(0xFFFFFFFF),
    brandThreads: Color(0xFFFFFFFF),
    brandX: Color(0xFFFFFFFF),
  );

  /// No colour at all: for Material slots that must stay invisible
  /// (surface tint, shadows).
  static const transparent = Color(0x00000000);

  static const _youTube = Color(0xFFFF0000);
  static const _instagram = Color(0xFFE4405F);
  static const _facebook = Color(0xFF0866FF);
  static const _linkedIn = Color(0xFF0A66C2);
  static const _bluesky = Color(0xFF0285FF);

  /// Screen background.
  final Color bg;

  /// Cards, inputs, sheets, dialogs, bottom nav.
  final Color surface;

  /// Video placeholders, switch off track, skeletons.
  final Color block;

  /// Primary text and icons.
  final Color text;

  /// Secondary text and icons, unselected logos.
  final Color sub;

  /// Primary buttons, selected states, active nav indicator, create button.
  final Color accent;

  /// Text and icons on [accent].
  final Color onAccent;

  /// Dividers, progress track, unselected logo ring.
  final Color line;

  /// Behind bottom sheets and dialogs.
  final Color scrim;

  final Color brandYouTube;
  final Color brandInstagram;
  final Color brandFacebook;
  final Color brandLinkedIn;
  final Color brandBluesky;
  final Color brandTikTok;
  final Color brandThreads;
  final Color brandX;

  @override
  AppColors copyWith({
    Color? bg,
    Color? surface,
    Color? block,
    Color? text,
    Color? sub,
    Color? accent,
    Color? onAccent,
    Color? line,
    Color? scrim,
    Color? brandYouTube,
    Color? brandInstagram,
    Color? brandFacebook,
    Color? brandLinkedIn,
    Color? brandBluesky,
    Color? brandTikTok,
    Color? brandThreads,
    Color? brandX,
  }) {
    return AppColors(
      bg: bg ?? this.bg,
      surface: surface ?? this.surface,
      block: block ?? this.block,
      text: text ?? this.text,
      sub: sub ?? this.sub,
      accent: accent ?? this.accent,
      onAccent: onAccent ?? this.onAccent,
      line: line ?? this.line,
      scrim: scrim ?? this.scrim,
      brandYouTube: brandYouTube ?? this.brandYouTube,
      brandInstagram: brandInstagram ?? this.brandInstagram,
      brandFacebook: brandFacebook ?? this.brandFacebook,
      brandLinkedIn: brandLinkedIn ?? this.brandLinkedIn,
      brandBluesky: brandBluesky ?? this.brandBluesky,
      brandTikTok: brandTikTok ?? this.brandTikTok,
      brandThreads: brandThreads ?? this.brandThreads,
      brandX: brandX ?? this.brandX,
    );
  }

  @override
  AppColors lerp(covariant ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    Color mix(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppColors(
      bg: mix(bg, other.bg),
      surface: mix(surface, other.surface),
      block: mix(block, other.block),
      text: mix(text, other.text),
      sub: mix(sub, other.sub),
      accent: mix(accent, other.accent),
      onAccent: mix(onAccent, other.onAccent),
      line: mix(line, other.line),
      scrim: mix(scrim, other.scrim),
      brandYouTube: mix(brandYouTube, other.brandYouTube),
      brandInstagram: mix(brandInstagram, other.brandInstagram),
      brandFacebook: mix(brandFacebook, other.brandFacebook),
      brandLinkedIn: mix(brandLinkedIn, other.brandLinkedIn),
      brandBluesky: mix(brandBluesky, other.brandBluesky),
      brandTikTok: mix(brandTikTok, other.brandTikTok),
      brandThreads: mix(brandThreads, other.brandThreads),
      brandX: mix(brandX, other.brandX),
    );
  }

  @override
  List<Object?> get props => [
    bg,
    surface,
    block,
    text,
    sub,
    accent,
    onAccent,
    line,
    scrim,
    brandYouTube,
    brandInstagram,
    brandFacebook,
    brandLinkedIn,
    brandBluesky,
    brandTikTok,
    brandThreads,
    brandX,
  ];
}
