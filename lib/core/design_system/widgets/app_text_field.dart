import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/theme/app_theme.dart';
import 'package:pushit/core/design_system/tokens/app_radii.dart';
import 'package:pushit/core/design_system/tokens/app_sizes.dart';
import 'package:pushit/core/design_system/tokens/app_spacing.dart';
import 'package:pushit/core/design_system/widgets/inline_error.dart';

/// A `small` label over a borderless `surface` field (radius 14), single
/// line or multiline.
///
/// - Pass a [controller], or an [initialValue] and listen with [onChanged].
/// - [errorText] adds an outline and the message with an icon (never colour
///   alone).
class AppTextField extends StatefulWidget {
  const new({
    required this.label,
    this.hint,
    this.initialValue,
    this.controller,
    this.onChanged,
    this.onSubmitted,
    this.errorText,
    this.isObscured = false,
    this.isMultiline = false,
    this.isEnabled = true,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    super.key,
  });

  /// Lines a multiline field shows before it grows.
  static const multilineMinLines = 6;

  final String label;
  final String? hint;
  final String? initialValue;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? errorText;
  final bool isObscured;
  final bool isMultiline;
  final bool isEnabled;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  // Only created when the parent passes no controller.
  TextEditingController? _ownController;

  TextEditingController get _controller =>
      widget.controller ??
      (_ownController ??= TextEditingController(text: widget.initialValue));

  @override
  void dispose() {
    _ownController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;
    final error = widget.errorText;

    OutlineInputBorder border(Color? color) => OutlineInputBorder(
      borderRadius: const BorderRadius.all(Radius.circular(AppRadii.input)),
      borderSide: color == null
          ? BorderSide.none
          : BorderSide(color: color, width: AppSizes.ringWidth),
    );
    final idle = border(error == null ? null : colors.text);

    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(widget.label, style: styles.small.copyWith(color: colors.sub)),
          const SizedBox(height: AppSpacing.xs),
          TextField(
            controller: _controller,
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
            enabled: widget.isEnabled,
            obscureText: widget.isObscured,
            keyboardType: widget.isMultiline
                ? TextInputType.multiline
                : widget.keyboardType,
            textInputAction: widget.textInputAction,
            autofillHints: widget.autofillHints,
            minLines: widget.isMultiline ? AppTextField.multilineMinLines : 1,
            maxLines: widget.isMultiline ? null : 1,
            style: styles.body.copyWith(color: colors.text),
            cursorColor: colors.text,
            decoration: InputDecoration(
              filled: true,
              fillColor: colors.surface,
              hintText: widget.hint,
              hintStyle: styles.body.copyWith(color: colors.sub),
              contentPadding: const EdgeInsets.all(AppSpacing.md),
              border: idle,
              enabledBorder: idle,
              disabledBorder: idle,
              focusedBorder: border(colors.text),
            ),
          ),
          if (error != null) ...[
            const SizedBox(height: AppSpacing.xs),
            InlineError(error),
          ],
        ],
      ),
    );
  }
}
