import 'package:flutter_svg/flutter_svg.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/design_system/theme/app_theme.dart';
import 'package:pushit/core/design_system/tokens/app_colors.dart';
import 'package:pushit/core/design_system/tokens/app_sizes.dart';
import 'package:pushit/core/l10n/l10n.dart';
import 'package:pushit/domain/domain.dart';

/// The two logo sizes: 48 (glyph 24) and 28 (glyph 14).
enum PlatformLogoSize {
  large(AppSizes.platformLogoLarge, AppSizes.platformGlyphLarge),
  small(AppSizes.platformLogoSmall, AppSizes.platformGlyphSmall);

  new(this.diameter, this.glyph);

  final double diameter;
  final double glyph;
}

/// A platform's logo in a ring.
///
/// - Selected or connected: `surface` fill, `text` ring, brand-coloured
///   glyph.
/// - Unselected or unavailable: no fill, `line` ring, `sub` glyph.
///
/// Labelled with the platform name. With [onTap] it becomes a 48 dp
/// toggle that reports [isSelected].
class PlatformLogo extends StatelessWidget {
  const new({
    required this.platform,
    this.isSelected = true,
    this.size = PlatformLogoSize.large,
    this.onTap,
    super.key,
  });

  static const ValueKey<String> ringKey = ValueKey('platform-logo-ring');

  final PlatformId platform;
  final bool isSelected;
  final PlatformLogoSize size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final logo = Container(
      key: ringKey,
      width: size.diameter,
      height: size.diameter,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected ? colors.surface : null,
        border: Border.all(
          color: isSelected ? colors.text : colors.line,
          width: AppSizes.ringWidth,
        ),
      ),
      child: SvgPicture.asset(
        'assets/logos/${platform.name}.svg',
        width: size.glyph,
        height: size.glyph,
        excludeFromSemantics: true,
        colorFilter: ColorFilter.mode(
          isSelected ? _brandOf(colors) : colors.sub,
          BlendMode.srcIn,
        ),
      ),
    );
    final onTap = this.onTap;
    return Semantics(
      container: true,
      label: context.l10n.platformName(platform),
      selected: onTap == null ? null : isSelected,
      button: onTap != null,
      child: onTap == null
          ? logo
          : InkResponse(
              onTap: onTap,
              radius: AppSizes.minTapTarget / 2,
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: AppSizes.minTapTarget,
                  minHeight: AppSizes.minTapTarget,
                ),
                child: Center(widthFactor: 1, heightFactor: 1, child: logo),
              ),
            ),
    );
  }

  Color _brandOf(AppColors colors) => switch (platform) {
    PlatformId.youtube => colors.brandYouTube,
    PlatformId.instagram => colors.brandInstagram,
    PlatformId.tiktok => colors.brandTikTok,
    PlatformId.facebook => colors.brandFacebook,
    PlatformId.threads => colors.brandThreads,
    PlatformId.linkedin => colors.brandLinkedIn,
    PlatformId.bluesky => colors.brandBluesky,
    PlatformId.x => colors.brandX,
  };
}
