import 'package:flutter_test/flutter_test.dart';
import 'package:pushit/domain/domain.dart';

void main() {
  test('the maximum file size is 300 MB', () {
    expect(maxVideoSizeBytes, 300 * 1024 * 1024);
  });

  test('Facebook Reels allow at most 90 seconds', () {
    expect(maxDurationFor(PlatformId.facebook), const Duration(seconds: 90));
  });

  test('every platform has a positive maximum duration', () {
    for (final platform in PlatformId.values) {
      expect(maxDurationFor(platform) > Duration.zero, isTrue);
    }
  });
}
