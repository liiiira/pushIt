import 'package:equatable/equatable.dart';
import 'package:material_ui/material_ui.dart';

/// The text styles (docs/DESIGN_TOKENS.md). Read them with
/// `context.textStyles`.
///
/// The styles carry no colour: it comes from the context (`text` or `sub`).
/// Hanken Grotesk is bundled as a variable font only, so every style sets
/// its weight both as `fontWeight` and on the `wght` axis.
@immutable
final class AppTypography extends ThemeExtension<AppTypography> with Equatable {
  const new({
    required this.h1,
    required this.time,
    required this.title,
    required this.body,
    required this.bodyStrong,
    required this.small,
    required this.tiny,
    required this.button,
  });

  static const fontFamily = 'HankenGrotesk';

  /// The one set of styles, shared by both theme modes.
  static const standard = AppTypography(
    h1: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w700,
      fontVariations: [FontVariation.weight(700)],
      fontSize: 26,
      height: 1.2,
      letterSpacing: -0.26,
    ),
    time: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w600,
      fontVariations: [FontVariation.weight(600)],
      fontSize: 64,
      height: 1,
      letterSpacing: -1.28,
    ),
    title: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w600,
      fontVariations: [FontVariation.weight(600)],
      fontSize: 20,
      height: 1.25,
      letterSpacing: -0.2,
    ),
    body: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w400,
      fontVariations: [FontVariation.weight(400)],
      fontSize: 15,
      height: 1.45,
      letterSpacing: 0,
    ),
    bodyStrong: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w600,
      fontVariations: [FontVariation.weight(600)],
      fontSize: 15,
      height: 1.45,
      letterSpacing: 0,
    ),
    small: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w500,
      fontVariations: [FontVariation.weight(500)],
      fontSize: 12,
      height: 1.35,
      letterSpacing: 0,
    ),
    tiny: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w700,
      fontVariations: [FontVariation.weight(700)],
      fontSize: 10,
      height: 1.2,
      letterSpacing: 0.2,
    ),
    button: TextStyle(
      fontFamily: fontFamily,
      fontWeight: FontWeight.w600,
      fontVariations: [FontVariation.weight(600)],
      fontSize: 16,
      height: 1.2,
      letterSpacing: 0,
    ),
  );

  /// Screen titles (Library, Accounts …), headline numbers.
  final TextStyle h1;

  /// Next post time, splash wordmark.
  final TextStyle time;

  /// Card, sheet and dialog titles.
  final TextStyle title;

  /// Body text, list rows.
  final TextStyle body;

  /// Row titles, top-bar titles, emphasised values, small button labels.
  final TextStyle bodyStrong;

  /// Secondary lines, labels, helper text.
  final TextStyle small;

  /// Nav labels, initials, logo-sized captions.
  final TextStyle tiny;

  /// Button labels.
  final TextStyle button;

  @override
  AppTypography copyWith({
    TextStyle? h1,
    TextStyle? time,
    TextStyle? title,
    TextStyle? body,
    TextStyle? bodyStrong,
    TextStyle? small,
    TextStyle? tiny,
    TextStyle? button,
  }) {
    return AppTypography(
      h1: h1 ?? this.h1,
      time: time ?? this.time,
      title: title ?? this.title,
      body: body ?? this.body,
      bodyStrong: bodyStrong ?? this.bodyStrong,
      small: small ?? this.small,
      tiny: tiny ?? this.tiny,
      button: button ?? this.button,
    );
  }

  @override
  AppTypography lerp(covariant ThemeExtension<AppTypography>? other, double t) {
    if (other is! AppTypography) return this;
    TextStyle mix(TextStyle a, TextStyle b) => TextStyle.lerp(a, b, t)!;
    return AppTypography(
      h1: mix(h1, other.h1),
      time: mix(time, other.time),
      title: mix(title, other.title),
      body: mix(body, other.body),
      bodyStrong: mix(bodyStrong, other.bodyStrong),
      small: mix(small, other.small),
      tiny: mix(tiny, other.tiny),
      button: mix(button, other.button),
    );
  }

  @override
  List<Object?> get props => [
    h1,
    time,
    title,
    body,
    bodyStrong,
    small,
    tiny,
    button,
  ];
}
