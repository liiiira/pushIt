import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/widgets/inline_error.dart';
import 'package:pushit/core/design_system/widgets/primary_button.dart';
import 'package:pushit/core/design_system/widgets/text_action_button.dart';
import 'package:pushit/core/formatters.dart';
import 'package:pushit/core/l10n/l10n.dart';
import 'package:pushit/features/auth/presentation/cubit/verify_email_cubit.dart';
import 'package:pushit/features/auth/presentation/widgets/auth_form_layout.dart';
import 'package:pushit/features/auth/presentation/widgets/auth_labels.dart';
import 'package:pushit/features/auth/presentation/widgets/open_email_app.dart';

/// A7: where the link went, Open email app, and Send again after a
/// countdown. The back arrow signs out (the router then opens sign-in).
class VerifyEmailView extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<VerifyEmailCubit>();
    return BlocBuilder<VerifyEmailCubit, VerifyEmailState>(
      builder: (context, state) {
        final email = state.email;
        final failure = state.failure;
        return AuthFormLayout(
          hasBack: true,
          onBack: cubit.backTapped,
          icon: LucideIcons.mail,
          title: l10n.authCheckEmailTitle,
          subtitle: email == null
              ? l10n.authVerifyBodyNoEmail
              : l10n.authVerifyBody(email),
          fields: [
            if (failure != null)
              InlineError(
                l10n.authFailureText(failure, rejected: l10n.authErrorUnknown),
              ),
          ],
          actions: [
            PrimaryButton(
              label: l10n.authOpenEmailApp,
              onPressed: () => unawaited(openEmailApp()),
            ),
            TextActionButton(
              label: state.secondsLeft > 0
                  ? l10n.authVerifySendAgainIn(
                      formatClipDuration(Duration(seconds: state.secondsLeft)),
                    )
                  : l10n.authVerifySendAgain,
              onPressed: state.canResend ? cubit.resendTapped : null,
            ),
          ],
        );
      },
    );
  }
}
