import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/theme/app_theme.dart';
import 'package:pushit/core/design_system/tokens/app_sizes.dart';
import 'package:pushit/core/design_system/tokens/app_spacing.dart';
import 'package:pushit/core/design_system/widgets/app_top_bar.dart';
import 'package:pushit/core/design_system/widgets/primary_button.dart';
import 'package:pushit/core/design_system/widgets/video_thumbnail.dart';
import 'package:pushit/core/formatters.dart';
import 'package:pushit/core/l10n/l10n.dart';
import 'package:pushit/features/composer/domain/composer_rules.dart';
import 'package:pushit/features/composer/presentation/cubit/composer_cubit.dart';

/// D6: pick the cover frame. The choice applies on "Use this frame".
class CoverView extends StatefulWidget {
  const new({super.key});

  @override
  State<CoverView> createState() => _CoverViewState();
}

class _CoverViewState extends State<CoverView> {
  static const double _previewWidth = 190;

  /// Wide enough to tap (48 dp); six fit at 412 dp, and they scroll on
  /// narrower screens.
  static const double _frameWidth = 52;

  // Set from the composer's cover in initState.
  late Duration _chosen;

  @override
  void initState() {
    super.initState();
    _chosen = context.read<ComposerCubit>().state.draft.coverAt;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final duration =
        context.select<ComposerCubit, Duration?>(
          (cubit) => cubit.state.draft.video?.duration,
        ) ??
        Duration.zero;
    final frames = coverFrames(duration);
    return Scaffold(
      backgroundColor: context.colors.bg,
      appBar: AppTopBar(title: l10n.composerCoverTitle),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenMargin,
                AppSpacing.md,
                AppSpacing.screenMargin,
                AppSpacing.xl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Center(child: VideoThumbnail(width: _previewWidth)),
                  const SizedBox(height: AppSpacing.md),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final (i, frame) in frames.indexed) ...[
                          if (i > 0) const SizedBox(width: AppSizes.galleryGap),
                          VideoThumbnail(
                            width: _frameWidth,
                            isSmall: true,
                            isSelected: frame == _chosen,
                            semanticLabel: l10n.composerCoverFrame(
                              formatClipDuration(frame),
                            ),
                            onTap: () => setState(() => _chosen = frame),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    l10n.composerCoverHint(formatClipDuration(_chosen)),
                    style: context.textStyles.small.copyWith(
                      color: context.colors.sub,
                    ),
                  ),
                ],
              ),
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
                label: l10n.composerCoverUse,
                onPressed: () {
                  context.read<ComposerCubit>().coverChanged(_chosen);
                  context.pop();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
