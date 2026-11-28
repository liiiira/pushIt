import 'package:pushit/core/l10n/generated/app_localizations.dart';
import 'package:pushit/domain/domain.dart';

extension PlanNames on AppLocalizations {
  /// The display name of [tier], e.g. `Pro`.
  String planName(PlanTier tier) => switch (tier) {
    PlanTier.free => commonPlanFree,
    PlanTier.pro => commonPlanPro,
    PlanTier.studio => commonPlanStudio,
  };
}
