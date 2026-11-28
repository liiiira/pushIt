import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/theme/app_theme.dart';
import 'package:pushit/core/design_system/tokens/app_spacing.dart';
import 'package:pushit/core/l10n/l10n.dart';

/// A1: the wordmark and the promise, while the app learns whether the user
/// is signed in. The router leaves it on its own (`appRedirect`), so it
/// holds no state.
class SplashPage extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = context.colors;
    final styles = context.textStyles;
    return Scaffold(
      backgroundColor: colors.bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.screenMargin,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.commonAppName,
                  textAlign: TextAlign.center,
                  style: styles.time.copyWith(color: colors.text),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  l10n.onboardingSplashTagline,
                  textAlign: TextAlign.center,
                  style: styles.body.copyWith(color: colors.sub),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
