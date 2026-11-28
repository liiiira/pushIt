import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/theme/app_theme.dart';
import 'package:pushit/core/design_system/tokens/app_durations.dart';
import 'package:pushit/core/design_system/tokens/app_spacing.dart';
import 'package:pushit/core/design_system/widgets/app_button_size.dart';
import 'package:pushit/core/design_system/widgets/primary_button.dart';
import 'package:pushit/core/design_system/widgets/text_action_button.dart';
import 'package:pushit/core/l10n/l10n.dart';
import 'package:pushit/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:pushit/features/onboarding/presentation/widgets/onboarding_slide.dart';

/// A2–A4: three pages with Skip on top and Next (then "Connect an
/// account") pinned at the bottom.
class OnboardingView extends StatefulWidget {
  const new({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pages = PageController();

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<OnboardingCubit>();
    final slides = [
      (
        icon: LucideIcons.layers2,
        title: l10n.onboardingPage1Title,
        body: l10n.onboardingPage1Body,
      ),
      (
        icon: LucideIcons.power,
        title: l10n.onboardingPage2Title,
        body: l10n.onboardingPage2Body,
      ),
      (
        icon: LucideIcons.galleryVerticalEnd,
        title: l10n.onboardingPage3Title,
        body: l10n.onboardingPage3Body,
      ),
    ];
    return BlocListener<OnboardingCubit, OnboardingState>(
      listenWhen: (previous, current) => previous.page != current.page,
      listener: (context, state) {
        if (_pages.hasClients && _pages.page?.round() != state.page) {
          _pages.animateToPage(
            state.page,
            duration: AppDurations.normal,
            curve: Curves.easeOut,
          );
        }
      },
      child: Scaffold(
        backgroundColor: context.colors.bg,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Padding(
                  padding: const EdgeInsetsDirectional.only(
                    end: AppSpacing.screenMargin,
                  ),
                  child: TextActionButton(
                    label: l10n.onboardingSkip,
                    size: AppButtonSize.small,
                    onPressed: cubit.skipTapped,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Expanded(
                child: PageView(
                  controller: _pages,
                  onPageChanged: cubit.pageChanged,
                  children: [
                    for (final (index, slide) in slides.indexed)
                      OnboardingSlide(
                        icon: slide.icon,
                        title: slide.title,
                        body: slide.body,
                        index: index,
                        count: slides.length,
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenMargin,
                  AppSpacing.xs,
                  AppSpacing.screenMargin,
                  AppSpacing.xl,
                ),
                child: BlocSelector<OnboardingCubit, OnboardingState, bool>(
                  selector: (state) => state.isLastPage,
                  builder: (context, isLastPage) => PrimaryButton(
                    label: isLastPage
                        ? l10n.onboardingConnect
                        : l10n.onboardingNext,
                    onPressed: cubit.nextTapped,
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
