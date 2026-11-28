import 'package:flutter_test/flutter_test.dart';
import 'package:pushit/domain/domain.dart';

void main() {
  test('every platform has an https home link', () {
    for (final platform in PlatformId.values) {
      final uri = platformHomeUri(platform);
      expect(uri.scheme, 'https', reason: '$platform');
      expect(uri.host, isNotEmpty, reason: '$platform');
    }
    expect(platformHomeUri(PlatformId.tiktok).host, 'www.tiktok.com');
  });
}
