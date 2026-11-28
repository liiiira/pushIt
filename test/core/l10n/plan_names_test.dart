import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/l10n/l10n.dart';
import 'package:pushit/domain/domain.dart';

void main() {
  test('names every plan', () {
    final l10n = lookupAppLocalizations(const Locale('en'));

    expect(
      {for (final tier in PlanTier.values) tier: l10n.planName(tier)},
      {PlanTier.free: 'Free', PlanTier.pro: 'Pro', PlanTier.studio: 'Studio'},
    );
  });
}
