import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/app/router/route_paths.dart';
import 'package:pushit/core/design_system/tokens/app_spacing.dart';
import 'package:pushit/core/design_system/widgets/app_checkbox.dart';
import 'package:pushit/core/design_system/widgets/app_text_field.dart';
import 'package:pushit/core/design_system/widgets/inline_error.dart';
import 'package:pushit/core/design_system/widgets/primary_button.dart';
import 'package:pushit/core/design_system/widgets/secondary_button.dart';
import 'package:pushit/core/design_system/widgets/text_action_button.dart';
import 'package:pushit/core/l10n/l10n.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/auth/domain/auth_validators.dart';
import 'package:pushit/features/auth/presentation/cubit/register_cubit.dart';
import 'package:pushit/features/auth/presentation/widgets/auth_form_layout.dart';
import 'package:pushit/features/auth/presentation/widgets/auth_labels.dart';

/// A6: name, email, password and the terms, Google, and sign in instead.
/// Once created, the router opens verify email.
class RegisterView extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<RegisterCubit>();
    return BlocBuilder<RegisterCubit, RegisterState>(
      builder: (context, state) {
        final nameError = state.nameError;
        final emailError = state.emailError;
        final passwordError = state.passwordError;
        final failure = state.failure;
        final isIdle = !state.isSubmitting;
        return AuthFormLayout(
          title: l10n.authRegisterTitle,
          subtitle: l10n.authRegisterSubtitle(
            freePlan.accountLimit,
            freePlan.monthlyPostLimit ?? 0,
          ),
          fields: [
            AutofillGroup(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppTextField(
                    label: l10n.authNameLabel,
                    onChanged: cubit.nameChanged,
                    errorText: nameError == null
                        ? null
                        : l10n.nameErrorText(nameError),
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.name],
                  ),
                  const SizedBox(height: AppSpacing.lg),
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
                    hint: l10n.authPasswordHint(minPasswordLength),
                    onChanged: cubit.passwordChanged,
                    errorText: passwordError == null
                        ? null
                        : l10n.passwordErrorText(passwordError, isNew: true),
                    isObscured: true,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.newPassword],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            AppCheckbox(
              value: state.hasAcceptedTerms,
              label: l10n.authRegisterTerms,
              onChanged: (isAccepted) =>
                  cubit.termsChanged(isAccepted: isAccepted),
            ),
            if (state.needsTerms) InlineError(l10n.authRegisterTermsNeeded),
            if (failure != null) ...[
              const SizedBox(height: AppSpacing.md),
              InlineError(
                l10n.authFailureText(
                  failure,
                  rejected: l10n.authRegisterRejected,
                ),
              ),
            ],
          ],
          actions: [
            PrimaryButton(
              label: l10n.authRegisterButton,
              onPressed: isIdle ? cubit.submitted : null,
            ),
            SecondaryButton(
              label: l10n.authGoogle,
              onPressed: isIdle ? cubit.googleTapped : null,
            ),
            TextActionButton(
              label: l10n.authRegisterSignIn,
              onPressed: () => context.go(RoutePaths.signIn),
            ),
          ],
        );
      },
    );
  }
}
