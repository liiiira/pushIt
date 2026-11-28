import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/theme/app_theme.dart';
import 'package:pushit/core/design_system/tokens/app_radii.dart';
import 'package:pushit/core/design_system/tokens/app_sizes.dart';
import 'package:pushit/core/design_system/tokens/app_spacing.dart';
import 'package:pushit/core/design_system/widgets/page_indicator.dart';

/// One onboarding page: a line icon on a `surface` card, the page dots, a
/// title and a text. Scrolls when the text is large.
class OnboardingSlide extends StatelessWidget {
  const new({
    required this.icon,
    required this.title,
    required this.body,
    required this.index,
    required this.count,
    super.key,
  });

  final IconData icon;
  final String title;
  final String body;

  /// Zero-based, for the page dots.
  final int index;
  final int count;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screenMargin),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: AppSizes.illustrationAspectRatio,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.surface,
                borderRadius: const BorderRadius.all(
                  Radius.circular(AppRadii.sheet),
                ),
              ),
              child: Center(
                child: Icon(
                  icon,
                  size: AppSizes.illustrationIcon,
                  color: colors.text,
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          PageIndicator(count: count, index: index),
          const SizedBox(height: AppSpacing.md),
          Semantics(
            header: true,
            child: Text(title, style: styles.h1.copyWith(color: colors.text)),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(body, style: styles.body.copyWith(color: colors.sub)),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}
