import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/theme/app_theme.dart';
import 'package:pushit/core/design_system/tokens/app_spacing.dart';
import 'package:pushit/core/design_system/widgets/app_bottom_sheet.dart';
import 'package:pushit/core/design_system/widgets/primary_button.dart';
import 'package:pushit/core/design_system/widgets/text_action_button.dart';
import 'package:pushit/core/l10n/l10n.dart';
import 'package:pushit/core/l10n/price_labels.dart';
import 'package:pushit/domain/domain.dart';

/// What the user chose on the limit-reached sheet (H3).
enum LimitReachedChoice {
  /// Open the plans (H2).
  seePlans,

  /// Keep the post as a draft.
  saveDraft,

  /// Closed without choosing.
  dismissed,
}

/// H3: the monthly video limit of [plan] is reached ([usage]). Offers Pro
/// and saving the post as a draft. Opened by the composer on
/// `LimitReachedFailure`; the caller navigates or saves the draft from the
/// returned choice.
Future<LimitReachedChoice> showLimitReachedSheet({
  required BuildContext context,
  required Plan plan,
  required Usage usage,
}) async {
  final choice = await showAppBottomSheet<LimitReachedChoice>(
    context: context,
    builder: (context) => _LimitReachedContent(plan: plan, usage: usage),
  );
  return choice ?? LimitReachedChoice.dismissed;
}

/// The plan that removes the monthly limit.
const Plan _upgrade = proPlan;

class _LimitReachedContent extends StatelessWidget {
  const new({required this.plan, required this.usage});

  final Plan plan;
  final Usage usage;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final styles = context.textStyles;
    final limit = plan.monthlyPostLimit ?? usage.postsThisMonth;
    final locale = Localizations.localeOf(context).toString();
    final upgrade = l10n.planName(_upgrade.tier);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(
            l10n.plansLimitReachedTitle(usage.postsThisMonth, limit),
            style: styles.title.copyWith(color: colors.text),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          l10n.plansLimitReachedBody(
            l10n.planName(plan.tier),
            limit,
            DateFormat('d MMMM', locale).format(usage.resetsOn),
            upgrade,
          ),
          style: styles.body.copyWith(color: colors.sub),
        ),
        const SizedBox(height: AppSpacing.xl),
        PrimaryButton(
          label: l10n.plansLimitReachedSeePlan(
            upgrade,
            context.usdLabel(_upgrade.monthlyPriceUsd),
          ),
          onPressed: () => Navigator.pop(context, LimitReachedChoice.seePlans),
        ),
        const SizedBox(height: AppSpacing.xxs),
        TextActionButton(
          label: l10n.plansLimitReachedSaveDraft,
          onPressed: () => Navigator.pop(context, LimitReachedChoice.saveDraft),
        ),
      ],
    );
  }
}
