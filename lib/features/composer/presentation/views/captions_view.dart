import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/theme/app_theme.dart';
import 'package:pushit/core/design_system/tokens/app_sizes.dart';
import 'package:pushit/core/design_system/tokens/app_spacing.dart';
import 'package:pushit/core/design_system/widgets/app_button_size.dart';
import 'package:pushit/core/design_system/widgets/app_card.dart';
import 'package:pushit/core/design_system/widgets/app_text_field.dart';
import 'package:pushit/core/design_system/widgets/app_top_bar.dart';
import 'package:pushit/core/design_system/widgets/platform_logo.dart';
import 'package:pushit/core/design_system/widgets/primary_button.dart';
import 'package:pushit/core/design_system/widgets/secondary_button.dart';
import 'package:pushit/core/design_system/widgets/text_action_button.dart';
import 'package:pushit/core/l10n/l10n.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/composer/presentation/cubit/composer_cubit.dart';
import 'package:pushit/features/composer/presentation/widgets/caption_variants_sheet.dart';

/// D5: Text per platform (and YouTube's title).
///
/// The selected platform tab is view state; the texts live in the
/// composer. Text controllers are kept per platform so Reset can put the
/// main caption back.
class CaptionsView extends StatefulWidget {
  const new({super.key});

  @override
  State<CaptionsView> createState() => _CaptionsViewState();
}

class _CaptionsViewState extends State<CaptionsView> {
  PlatformId? _selected;
  final Map<PlatformId, TextEditingController> _texts = {};
  final Map<PlatformId, TextEditingController> _titles = {};

  @override
  void dispose() {
    for (final controller in [..._texts.values, ..._titles.values]) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _textOf(PostDraft draft, PlatformId platform) =>
      _texts.putIfAbsent(
        platform,
        () => TextEditingController(
          text: _copyOf(draft, platform)?.text ?? draft.caption,
        ),
      );

  TextEditingController _titleOf(PostDraft draft, PlatformId platform) =>
      _titles.putIfAbsent(
        platform,
        () => TextEditingController(text: _copyOf(draft, platform)?.title),
      );

  PlatformCopy? _copyOf(PostDraft draft, PlatformId platform) =>
      draft.copies.where((c) => c.platform == platform).firstOrNull;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<ComposerCubit>();
    final draft = context.watch<ComposerCubit>().state.draft;
    final platforms = PlatformId.values.where(draft.platforms.contains);
    final selected = platforms.contains(_selected)
        ? _selected!
        : platforms.firstOrNull;

    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppTopBar(title: l10n.composerRowCaptions),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenMargin,
                AppSpacing.xs,
                AppSpacing.screenMargin,
                AppSpacing.xl,
              ),
              children: [
                Wrap(
                  spacing: AppSpacing.xs,
                  children: [
                    for (final platform in platforms)
                      Tooltip(
                        message: l10n.platformName(platform),
                        child: PlatformLogo(
                          platform: platform,
                          isSelected: platform == selected,
                          onTap: () => setState(() => _selected = platform),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                if (selected != null) ...[
                  if (selected == PlatformId.youtube) ...[
                    AppTextField(
                      key: const ValueKey('youtube-title'),
                      label: l10n.composerYouTubeTitle,
                      controller: _titleOf(draft, selected),
                      onChanged: (title) =>
                          cubit.copyChanged(selected, title: title),
                      textInputAction: TextInputAction.next,
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  AppTextField(
                    key: ValueKey('${selected.name}-text'),
                    label: selected == PlatformId.youtube
                        ? l10n.composerYouTubeDescription
                        : l10n.composerPlatformCaption(
                            l10n.platformName(selected),
                          ),
                    controller: _textOf(draft, selected),
                    onChanged: (text) =>
                        cubit.copyChanged(selected, text: text),
                    isMultiline: true,
                  ),
                  if (_copyOf(draft, selected) != null) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            l10n.composerChangedFromMain,
                            style: context.textStyles.small.copyWith(
                              color: context.colors.sub,
                            ),
                          ),
                        ),
                        TextActionButton(
                          label: l10n.composerReset,
                          size: AppButtonSize.small,
                          isUnderlined: true,
                          onPressed: () {
                            cubit.copyReset(selected);
                            _textOf(draft, selected).text = draft.caption;
                            _titleOf(draft, selected).clear();
                          },
                        ),
                      ],
                    ),
                  ],
                ],
                const SizedBox(height: AppSpacing.lg),
                const _SuggestCard(),
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

class _SuggestCard extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.sparkles,
                size: AppSizes.iconSmall,
                color: colors.text,
              ),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  l10n.composerSuggestTitle,
                  style: context.textStyles.bodyStrong.copyWith(
                    color: colors.text,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            l10n.composerSuggestBody,
            style: context.textStyles.small.copyWith(color: colors.sub),
          ),
          const SizedBox(height: AppSpacing.sm),
          SecondaryButton(
            label: l10n.composerSuggestAction,
            size: AppButtonSize.small,
            onPressed: () => unawaited(showCaptionVariantsSheet(context)),
          ),
        ],
      ),
    );
  }
}
