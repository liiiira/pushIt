import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/tokens/app_sizes.dart';
import 'package:pushit/core/design_system/tokens/app_typography.dart';

/// The two button sizes of the design.
enum AppButtonSize {
  /// Full width, 56 high, `button` label.
  full(AppSizes.buttonHeight),

  /// Hugs its label, 40 high (48 to tap), `bodyStrong` label.
  small(AppSizes.buttonHeightSmall);

  new(this.height);

  /// The visible height; the tap target is at least 48 either way.
  final double height;

  TextStyle labelStyle(AppTypography styles) => switch (this) {
    AppButtonSize.full => styles.button,
    AppButtonSize.small => styles.bodyStrong,
  };
}
