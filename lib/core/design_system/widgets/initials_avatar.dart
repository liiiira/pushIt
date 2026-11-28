import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/theme/app_theme.dart';
import 'package:pushit/core/design_system/tokens/app_sizes.dart';
import 'package:pushit/core/formatters.dart';

/// The two avatar sizes: 36 on Home (`tiny` initials), 56 on Settings
/// (`bodyStrong` initials).
enum InitialsAvatarSize { regular, large }

/// A `surface` circle with the user's initials. With [onTap] it is a 48 dp
/// button labelled [semanticLabel] (e.g. "Settings").
class InitialsAvatar extends StatelessWidget {
  const new({
    required this.name,
    this.size = InitialsAvatarSize.regular,
    this.semanticLabel,
    this.onTap,
    super.key,
  });

  static const ValueKey<String> circleKey = ValueKey('initials-avatar-circle');

  final String name;
  final InitialsAvatarSize size;
  final String? semanticLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final styles = context.textStyles;
    final (diameter, style) = switch (size) {
      InitialsAvatarSize.regular => (AppSizes.avatar, styles.tiny),
      InitialsAvatarSize.large => (AppSizes.avatarLarge, styles.bodyStrong),
    };
    final circle = Container(
      key: circleKey,
      width: diameter,
      height: diameter,
      alignment: Alignment.center,
      decoration: BoxDecoration(shape: BoxShape.circle, color: colors.surface),
      child: ExcludeSemantics(
        excluding: semanticLabel != null,
        child: Text(
          initialsOf(name),
          maxLines: 1,
          style: style.copyWith(color: colors.text),
        ),
      ),
    );
    final onTap = this.onTap;
    return Semantics(
      container: true,
      label: semanticLabel,
      button: onTap != null,
      child: onTap == null
          ? circle
          : InkResponse(
              onTap: onTap,
              radius: AppSizes.minTapTarget / 2,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: AppSizes.minTapTarget,
                  minHeight: AppSizes.minTapTarget,
                ),
                child: Center(widthFactor: 1, heightFactor: 1, child: circle),
              ),
            ),
    );
  }
}
