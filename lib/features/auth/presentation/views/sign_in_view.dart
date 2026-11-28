import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/app/router/route_paths.dart';
import 'package:pushit/core/design_system/tokens/app_spacing.dart';
import 'package:pushit/core/design_system/widgets/app_button_size.dart';
import 'package:pushit/core/design_system/widgets/app_text_field.dart';
import 'package:pushit/core/design_system/widgets/inline_error.dart';
import 'package:pushit/core/design_system/widgets/primary_button.dart';
import 'package:pushit/core/design_system/widgets/secondary_button.dart';
import 'package:pushit/core/design_system/widgets/text_action_button.dart';
import 'package:pushit/core/l10n/l10n.dart';
import 'package:pushit/features/auth/presentation/cubit/sign_in_cubit.dart';
import 'package:pushit/features/auth/presentation/widgets/auth_form_layout.dart';
import 'package:pushit/features/auth/presentation/widgets/auth_labels.dart';

/// A5: email and password, Forgot password, Google, and create account.
/// Once signed in, the router opens home.
class SignInView extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<SignInCubit>();
    return BlocBuilder<SignInCubit, SignInState>(
      builder: (context, state) {
        final emailError = state.emailError;
        final passwordError = state.passwordError;
        final failure = state.failure;
        final isIdle = !state.isSubmitting;
        return AuthFormLayout(
          title: l10n.authSignInTitle,
          subtitle: l10n.authSignInSubtitle,
          fields: [
            AutofillGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTextField(
                    label: l10n.authEmailLabel,
                    onChanged: cubit.emailChanged,
                    errorText: emailError == null
                        ? null
                        : l10n.emailErrorText(emailError),
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  AppTextField(
                    label: l10n.authPasswordLabel,
                    onChanged: cubit.passwordChanged,
                    onSubmitted: (_) => cubit.submitted(),
                    errorText: passwordError == null
                        ? null
                        : l10n.passwordErrorText(passwordError),
                    isObscured: true,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.password],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextActionButton(
                label: l10n.authSignInForgot,
                size: AppButtonSize.small,
                isUnderlined: true,
                onPressed: () => context.push(RoutePaths.resetPassword),
              ),
            ),
            if (failure != null) ...[
              const SizedBox(height: AppSpacing.md),
              InlineError(
                l10n.authFailureText(
                  failure,
                  rejected: l10n.authSignInRejected,
                ),
              ),
            ],
          ],
          actions: [
            PrimaryButton(
              label: l10n.authSignInButton,
              onPressed: isIdle ? cubit.submitted : null,
            ),
            SecondaryButton(
              label: l10n.authGoogle,
              onPressed: isIdle ? cubit.googleTapped : null,
            ),
            TextActionButton(
              label: l10n.authSignInCreate,
              onPressed: () => context.go(RoutePaths.register),
            ),
          ],
        );
      },
    );
  }
}
