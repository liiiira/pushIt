import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/theme/app_theme.dart';
import 'package:pushit/core/design_system/tokens/app_radii.dart';
import 'package:pushit/core/design_system/tokens/app_spacing.dart';
import 'package:pushit/core/design_system/widgets/primary_button.dart';
import 'package:pushit/core/design_system/widgets/secondary_button.dart';
import 'package:pushit/core/design_system/widgets/text_action_button.dart';

/// How an [AppDialogAction] looks.
enum AppDialogActionKind { primary, secondary, text }

/// One button of an app dialog; tapping it closes the dialog with [value].
@immutable
final class AppDialogAction<T> {
  const new({
    required this.label,
    required this.value,
    this.kind = AppDialogActionKind.primary,
  });

  final String label;
  final T value;
  final AppDialogActionKind kind;
}

/// Opens a centred dialog in the pushIt style: `surface`, radius 28, a
/// `title`, an optional `message` in `sub`, and [actions] stacked full
/// width (e.g. H7: "Delete account" over "Keep account").
///
/// Resolves to the tapped action's value, or null when dismissed. Dialogs
/// are not routes (docs/ARCHITECTURE.md).
Future<T?> showAppDialog<T>({
  required BuildContext context,
  required String title,
  required List<AppDialogAction<T>> actions,
  String? message,
}) {
  return showDialog<T>(
    context: context,
    barrierColor: context.colors.scrim,
    builder: (context) =>
        _AppDialog<T>(title: title, message: message, actions: actions),
  );
}

class _AppDialog<T> extends StatelessWidget {
  const new({required this.title, required this.actions, this.message});

  final String title;
  final String? message;
  final List<AppDialogAction<T>> actions;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;
    final message = this.message;
    return Dialog(
      backgroundColor: colors.surface,
      surfaceTintColor: colors.surface,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xxl,
        vertical: AppSpacing.xl,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadii.sheet)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              header: true,
              child: Text(
                title,
                style: styles.title.copyWith(color: colors.text),
              ),
            ),
            if (message != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(message, style: styles.body.copyWith(color: colors.sub)),
            ],
            const SizedBox(height: AppSpacing.lg),
            for (final (index, action) in actions.indexed) ...[
              if (index > 0) const SizedBox(height: AppSpacing.xxs),
              _ActionButton(action: action),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActionButton<T> extends StatelessWidget {
  const new({required this.action});

  final AppDialogAction<T> action;

  @override
  Widget build(BuildContext context) {
    void close() => Navigator.pop(context, action.value);
    return switch (action.kind) {
      AppDialogActionKind.primary => PrimaryButton(
        label: action.label,
        onPressed: close,
      ),
      AppDialogActionKind.secondary => SecondaryButton(
        label: action.label,
        onPressed: close,
      ),
      AppDialogActionKind.text => TextActionButton(
        label: action.label,
        onPressed: close,
      ),
    };
  }
}
