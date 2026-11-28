import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/widgets/empty_state_view.dart';
import 'package:pushit/core/l10n/l10n.dart';

/// I3: "Something went wrong", the page's [message] (or a generic one) and
/// "Try again". Shown when a page's state is `ViewStatus.failure`.
class ErrorStateView extends StatelessWidget {
  const new({required this.onRetry, this.message, super.key});

  final VoidCallback onRetry;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return EmptyStateView(
      icon: LucideIcons.circleAlert,
      title: l10n.commonErrorTitle,
      message: message ?? l10n.commonErrorBody,
      actionLabel: l10n.commonRetry,
      onAction: onRetry,
    );
  }
}
