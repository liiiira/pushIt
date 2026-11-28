import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

/// Numbers as the app writes them. Import this file where needed; it is not
/// exported from `l10n.dart`.
extension NumberLabels on BuildContext {
  /// A count with the locale's grouping, e.g. "12,480" (B1).
  String groupedNumber(int value) =>
      NumberFormat.decimalPattern(Localizations.localeOf(this).toString())
          .format(value);
}
