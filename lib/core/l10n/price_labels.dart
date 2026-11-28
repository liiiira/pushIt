import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

/// Prices as the designs write them. Import this file where needed; it is
/// not exported from `l10n.dart`.
extension PriceLabels on BuildContext {
  /// Whole US dollars, without cents: `$6`, `$120` (H2, H3).
  String usdLabel(int amount) => NumberFormat.simpleCurrency(
    locale: Localizations.localeOf(this).toString(),
    name: 'USD',
    decimalDigits: 0,
  ).format(amount);
}
