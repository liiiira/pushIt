import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/theme/app_theme.dart';

/// A headline number over its `small` label (Home: "12 480 / Views").
/// Format the number in the view (intl) and pass it as [value].
class StatTile extends StatelessWidget {
  const new({required this.value, required this.label, super.key});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;
    return MergeSemantics(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(value, style: styles.h1.copyWith(color: colors.text)),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: styles.small.copyWith(color: colors.sub),
          ),
        ],
      ),
    );
  }
}
