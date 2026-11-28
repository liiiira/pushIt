import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/app/router/route_paths.dart';
import 'package:pushit/core/design_system/theme/app_theme.dart';
import 'package:pushit/core/design_system/tokens/app_spacing.dart';
import 'package:pushit/core/design_system/widgets/app_bottom_sheet.dart';
import 'package:pushit/core/design_system/widgets/app_button_size.dart';
import 'package:pushit/core/design_system/widgets/app_card.dart';
import 'package:pushit/core/design_system/widgets/empty_state_view.dart';
import 'package:pushit/core/design_system/widgets/error_state_view.dart';
import 'package:pushit/core/design_system/widgets/platform_logo.dart';
import 'package:pushit/core/design_system/widgets/secondary_button.dart';
import 'package:pushit/core/design_system/widgets/skeleton_list.dart';
import 'package:pushit/core/failures.dart';
import 'package:pushit/core/l10n/l10n.dart';
import 'package:pushit/core/view_status.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/composer/presentation/cubit/caption_variants_cubit.dart';
import 'package:pushit/features/composer/presentation/cubit/composer_cubit.dart';

/// Opens D11 for the composer's caption and platforms.
Future<void> showCaptionVariantsSheet(BuildContext context) {
  final composer = context.read<ComposerCubit>();
  final draft = composer.state.draft;
  final suggestions = context.read<CaptionSuggestionsRepository>();
  return showAppBottomSheet<void>(
    context: context,
    title: context.l10n.composerVariantsTitle,
    builder: (_) => MultiBlocProvider(
      providers: [
        BlocProvider.value(value: composer),
        BlocProvider(
          create: (_) => CaptionVariantsCubit(
            suggestions: suggestions,
            caption: draft.caption,
            platforms: draft.platforms,
          )..started(),
        ),
      ],
      child: const CaptionVariantsSheet(),
    ),
  );
}

/// D11: one suggested caption per platform, each with "Use".
class CaptionVariantsSheet extends StatelessWidget {
  const new({super.key});

  /// Room for two skeleton rows while the suggestions load.
  static const double _loadingHeight = 192;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final state = context.watch<CaptionVariantsCubit>().state;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.composerVariantsIntro,
          style: context.textStyles.small.copyWith(color: context.colors.sub),
        ),
        const SizedBox(height: AppSpacing.md),
        switch (state.status) {
          ViewStatus.failure when state.failure is LimitReachedFailure =>
            EmptyStateView(
              icon: LucideIcons.sparkles,
              title: l10n.composerVariantsProOnly,
              actionLabel: l10n.composerVariantsSeePlans,
              onAction: () {
                Navigator.pop(context);
                unawaited(context.push(RoutePaths.plans));
              },
            ),
          ViewStatus.failure => ErrorStateView(
            onRetry: context.read<CaptionVariantsCubit>().started,
          ),
          ViewStatus.ready => Column(
            children: [
              for (final suggestion in state.suggestions) ...[
                _SuggestionCard(
                  suggestion: suggestion,
                  isUsed: state.used.contains(suggestion.platform),
                ),
                const SizedBox(height: AppSpacing.sm),
              ],
            ],
          ),
          _ => const SizedBox(
            height: _loadingHeight,
            child: SkeletonList(rowCount: 2),
          ),
        },
        const SizedBox(height: AppSpacing.xs),
        SecondaryButton(
          label: l10n.composerVariantsClose,
          onPressed: () => Navigator.maybePop(context),
        ),
      ],
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  const new({required this.suggestion, required this.isUsed});

  final CaptionSuggestion suggestion;
  final bool isUsed;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PlatformLogo(
            platform: suggestion.platform,
            size: PlatformLogoSize.small,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              suggestion.text,
              style: context.textStyles.body.copyWith(
                color: context.colors.text,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          SecondaryButton(
            label: isUsed
                ? l10n.composerVariantsUsed
                : l10n.composerVariantsUse,
            size: AppButtonSize.small,
            onPressed: isUsed
                ? null
                : () {
                    context.read<ComposerCubit>().suggestionUsed(suggestion);
                    context.read<CaptionVariantsCubit>().used(
                      suggestion.platform,
                    );
                  },
          ),
        ],
      ),
    );
  }
}
