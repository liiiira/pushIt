import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/theme/app_theme.dart';
import 'package:pushit/core/design_system/tokens/app_radii.dart';
import 'package:pushit/core/design_system/tokens/app_sizes.dart';
import 'package:pushit/core/design_system/tokens/app_spacing.dart';

/// Lays out a 24 dp checkbox or radio with an optional `body` label. The
/// whole tile is tappable and at least 48 × 48 dp.
class AppControlTile extends StatelessWidget {
  const new({
    required this.control,
    required this.onTap,
    this.label,
    super.key,
  });

  final Widget control;
  final VoidCallback? onTap;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final label = this.label;
    return InkWell(
      onTap: onTap,
      customBorder: label == null ? const CircleBorder() : null,
      borderRadius: label == null
          ? null
          : const BorderRadius.all(Radius.circular(AppRadii.thumbnailSmall)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: AppSizes.minTapTarget,
          minHeight: AppSizes.minTapTarget,
        ),
        child: label == null
            ? Center(widthFactor: 1, heightFactor: 1, child: control)
            : Row(
                children: [
                  control,
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      label,
                      style: context.textStyles.body.copyWith(
                        color: context.colors.text,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
