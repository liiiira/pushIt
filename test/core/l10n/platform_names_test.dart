import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:pushit/core/l10n/l10n.dart';
import 'package:pushit/domain/domain.dart';

void main() {
  test('names every platform', () {
    final l10n = lookupAppLocalizations(const Locale('en'));

    expect(
      {for (final p in PlatformId.values) p: l10n.platformName(p)},
      {
        PlatformId.youtube: 'YouTube',
        PlatformId.instagram: 'Instagram',
        PlatformId.tiktok: 'TikTok',
        PlatformId.facebook: 'Facebook',
        PlatformId.threads: 'Threads',
        PlatformId.linkedin: 'LinkedIn',
        PlatformId.bluesky: 'Bluesky',
        PlatformId.x: 'X',
      },
    );
  });
}
