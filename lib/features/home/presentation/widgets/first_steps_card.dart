import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/theme/app_theme.dart';
import 'package:pushit/core/design_system/tokens/app_radii.dart';
import 'package:pushit/core/design_system/tokens/app_sizes.dart';
import 'package:pushit/core/design_system/tokens/app_spacing.dart';
import 'package:pushit/core/design_system/widgets/app_button_size.dart';
import 'package:pushit/core/design_system/widgets/app_card.dart';
import 'package:pushit/core/design_system/widgets/primary_button.dart';
import 'package:pushit/core/l10n/l10n.dart';
import 'package:pushit/features/home/domain/build_dashboard.dart';

/// B2: three steps to the first post, and a button for the next one.
class FirstStepsCard extends StatelessWidget {
  const new({
    required this.firstUse,
    required this.onConnect,
    required this.onSchedule,
    super.key,
  });

  final FirstUse firstUse;
  final VoidCallback onConnect;
  final VoidCallback onSchedule;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              l10n.homeFirstStepsTitle,
              style: context.textStyles.title.copyWith(color: colors.text),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          _Step(label: l10n.homeStepCreateAccount, isDone: true),
          _Step(label: l10n.homeStepConnect, isDone: firstUse.hasAccount),
          _Step(label: l10n.homeStepSchedule, isDone: false),
          const SizedBox(height: AppSpacing.xs),
          PrimaryButton(
            label: firstUse.hasAccount
                ? l10n.homeStepSchedule
                : l10n.homeStepConnect,
            size: AppButtonSize.small,
            onPressed: firstUse.hasAccount ? onSchedule : onConnect,
          ),
        ],
      ),
    );
  }
}

/// One read-only step: a box, ticked when done, and its label, struck
/// through when done. Reads out as checked or not, with no tap action.
class _Step extends StatelessWidget {
  const new({required this.label, required this.isDone});

  final String label;
  final bool isDone;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return MergeSemantics(
      child: Semantics(
        checked: isDone,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppSizes.minTapTarget),
          child: Row(
            children: [
              Container(
                width: AppSizes.checkbox,
                height: AppSizes.checkbox,
                decoration: BoxDecoration(
                  color: isDone ? colors.accent : null,
                  border: isDone
                      ? null
                      : Border.all(
                          color: colors.text,
                          width: AppSizes.ringWidth,
                        ),
                  borderRadius: const BorderRadius.all(
                    Radius.circular(AppRadii.checkbox),
                  ),
                ),
                child: isDone
                    ? Icon(
                        LucideIcons.check,
                        size: AppSizes.iconTiny,
                        color: colors.onAccent,
                      )
                    : null,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  label,
                  style: context.textStyles.body.copyWith(
                    color: isDone ? colors.sub : colors.text,
                    decoration: isDone
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    decorationColor: colors.sub,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
