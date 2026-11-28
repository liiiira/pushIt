import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/app/router/route_paths.dart';
import 'package:pushit/core/design_system/tokens/app_spacing.dart';
import 'package:pushit/core/design_system/widgets/app_text_field.dart';
import 'package:pushit/core/design_system/widgets/inline_error.dart';
import 'package:pushit/core/design_system/widgets/primary_button.dart';
import 'package:pushit/core/design_system/widgets/text_action_button.dart';
import 'package:pushit/core/l10n/l10n.dart';
import 'package:pushit/features/auth/presentation/cubit/reset_password_cubit.dart';
import 'package:pushit/features/auth/presentation/widgets/auth_form_layout.dart';
import 'package:pushit/features/auth/presentation/widgets/auth_labels.dart';
import 'package:pushit/features/auth/presentation/widgets/open_email_app.dart';

/// A8: the email to send a reset link to, then where it went.
class ResetPasswordView extends StatelessWidget {
  const new({super.key});

  /// Back to sign-in (A5), which opened this screen on top of itself.
  static void _leave(BuildContext context) =>
      context.canPop() ? context.pop() : context.go(RoutePaths.signIn);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<ResetPasswordCubit>();
    return BlocBuilder<ResetPasswordCubit, ResetPasswordState>(
      builder: (context, state) {
        final sentTo = state.sentTo;
        if (sentTo != null) {
          return AuthFormLayout(
            hasBack: true,
            onBack: () => _leave(context),
            icon: LucideIcons.mail,
            title: l10n.authCheckEmailTitle,
            subtitle: l10n.authResetSentBody(sentTo),
            fields: const [],
            actions: [
              PrimaryButton(
                label: l10n.authOpenEmailApp,
                onPressed: () => unawaited(openEmailApp()),
              ),
              TextActionButton(
                label: l10n.authResetBackToSignIn,
                onPressed: () => _leave(context),
              ),
            ],
          );
        }
        final emailError = state.emailError;
        final failure = state.failure;
        return AuthFormLayout(
          hasBack: true,
          onBack: () => _leave(context),
          title: l10n.authResetTitle,
          subtitle: l10n.authResetSubtitle,
          fields: [
            AppTextField(
              label: l10n.authEmailLabel,
              onChanged: cubit.emailChanged,
              onSubmitted: (_) => cubit.submitted(),
              errorText: emailError == null
                  ? null
                  : l10n.emailErrorText(emailError),
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.send,
              autofillHints: const [AutofillHints.email],
            ),
            if (failure != null) ...[
              const SizedBox(height: AppSpacing.md),
              InlineError(
                l10n.authFailureText(failure, rejected: l10n.authResetRejected),
              ),
            ],
          ],
          actions: [
            PrimaryButton(
              label: l10n.authResetButton,
              onPressed: state.isSubmitting ? null : cubit.submitted,
            ),
          ],
        );
      },
    );
  }
}
