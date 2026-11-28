import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/theme/app_theme.dart';
import 'package:pushit/core/design_system/tokens/app_spacing.dart';
import 'package:pushit/core/design_system/widgets/app_list_row.dart';
import 'package:pushit/core/design_system/widgets/app_radio.dart';
import 'package:pushit/core/design_system/widgets/app_switch.dart';
import 'package:pushit/core/design_system/widgets/app_top_bar.dart';
import 'package:pushit/core/design_system/widgets/primary_button.dart';
import 'package:pushit/core/l10n/l10n.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/composer/presentation/cubit/composer_cubit.dart';

/// D7: TikTok's posting options. Changes apply as they are made.
class TikTokSettingsView extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<ComposerCubit>();
    final settings = context.select<ComposerCubit, TikTokSettings>(
      (cubit) => cubit.state.draft.tiktok,
    );
    void update(TikTokSettings next) => cubit.tiktokChanged(next);

    Widget heading(String text) => Padding(
      padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.xs),
      child: Text(
        text,
        style: context.textStyles.bodyStrong.copyWith(
          color: context.colors.text,
        ),
      ),
    );

    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppTopBar(title: l10n.composerRowTikTok),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenMargin,
                0,
                AppSpacing.screenMargin,
                AppSpacing.xl,
              ),
              children: [
                heading(l10n.composerTikTokWho),
                Text(
                  l10n.composerTikTokWhoHint,
                  style: context.textStyles.small.copyWith(
                    color: context.colors.sub,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                for (final (privacy, label) in [
                  (TikTokPrivacy.everyone, l10n.composerTikTokEveryone),
                  (TikTokPrivacy.friends, l10n.composerTikTokFriends),
                  (TikTokPrivacy.onlyMe, l10n.composerTikTokOnlyMe),
                ])
                  AppRadio<TikTokPrivacy>(
                    value: privacy,
                    groupValue: settings.privacy,
                    label: label,
                    onChanged: (value) =>
                        update(settings.copyWith(privacy: () => value)),
                  ),
                heading(l10n.composerTikTokAllow),
                _Toggle(
                  title: l10n.composerTikTokComments,
                  value: settings.allowComments,
                  onChanged: (value) =>
                      update(settings.copyWith(allowComments: value)),
                ),
                _Toggle(
                  title: l10n.composerTikTokDuet,
                  value: settings.allowDuet,
                  onChanged: (value) =>
                      update(settings.copyWith(allowDuet: value)),
                ),
                _Toggle(
                  title: l10n.composerTikTokStitch,
                  value: settings.allowStitch,
                  onChanged: (value) =>
                      update(settings.copyWith(allowStitch: value)),
                ),
                heading(l10n.composerTikTokCommercial),
                _Toggle(
                  title: l10n.composerTikTokPromotes,
                  subtitle: l10n.composerTikTokPromotesHint,
                  value: settings.isCommercial,
                  onChanged: (value) =>
                      update(settings.copyWith(isCommercial: value)),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenMargin,
                AppSpacing.xs,
                AppSpacing.screenMargin,
                AppSpacing.md,
              ),
              child: PrimaryButton(
                label: l10n.composerDone,
                onPressed: () => context.pop(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  const new({
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => AppListRow(
    title: title,
    subtitle: subtitle,
    padding: EdgeInsets.zero,
    trailing: AppSwitch(value: value, onChanged: onChanged),
    onTap: () => onChanged(!value),
  );
}
