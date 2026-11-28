import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/clock.dart';
import 'package:pushit/core/design_system/widgets/app_dialog.dart';
import 'package:pushit/core/l10n/date_labels.dart';
import 'package:pushit/core/l10n/l10n.dart';
import 'package:pushit/domain/domain.dart';
import 'package:pushit/features/accounts/domain/reconnect_risk.dart';

/// C5: asks to reconnect [account], saying why and, from [risk]
/// (`reconnectRiskOf`), which scheduled posts fail otherwise.
///
/// Resolves to `true` when the user taps Reconnect, `false` on Later or a
/// dismissal. The caller's cubit then calls `AccountsRepository.reconnect`.
/// Used by C1, B1 and F4. Reads the [Clock] to phrase times ("today,
/// 19:00").
Future<bool> showReconnectDialog({
  required BuildContext context,
  required ConnectedAccount account,
  ReconnectRisk risk = const ReconnectRisk(),
}) async {
  final l10n = context.l10n;
  final now = context.read<Clock>().now();
  final platform = l10n.platformName(account.platform);
  final expiresAt = account.signInExpiresAt;
  final reason = switch (account.health) {
    AccountHealth.expiringSoon when expiresAt != null =>
      l10n.accountsReconnectExpiresAt(
        platform,
        context.dayAndTimeLabel(expiresAt, now: now),
      ),
    AccountHealth.expiringSoon ||
    AccountHealth.connected => l10n.accountsReconnectExpiresSoon(platform),
    AccountHealth.expired => l10n.accountsReconnectSignedOut(platform),
  };
  final firstPostAt = risk.firstPostAt;
  final message = risk.hasPostsAtRisk && firstPostAt != null
      ? l10n.accountsReconnectAtRisk(
          reason,
          risk.postCount,
          context.dayAndTimeLabel(firstPostAt, now: now),
        )
      : reason;

  final reconnect = await showAppDialog<bool>(
    context: context,
    title: l10n.accountsReconnectTitle(platform),
    message: message,
    actions: [
      AppDialogAction(label: l10n.accountsReconnectPrimary, value: true),
      AppDialogAction(
        label: l10n.accountsReconnectLater,
        value: false,
        kind: AppDialogActionKind.text,
      ),
    ],
  );
  return reconnect ?? false;
}
