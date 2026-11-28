import 'package:flutter_test/flutter_test.dart';
import 'package:pushit/core/formatters.dart';

void main() {
  group('formatClipDuration', () {
    test('shows minutes and two-digit seconds', () {
      expect(
        formatClipDuration(const Duration(minutes: 1, seconds: 42)),
        '1:42',
      );
      expect(formatClipDuration(const Duration(seconds: 38)), '0:38');
      expect(
        formatClipDuration(const Duration(minutes: 12, seconds: 5)),
        '12:05',
      );
      expect(formatClipDuration(Duration.zero), '0:00');
    });

    test('adds hours when there are any', () {
      expect(
        formatClipDuration(const Duration(hours: 1, minutes: 2, seconds: 3)),
        '1:02:03',
      );
    });

    test('drops milliseconds', () {
      expect(
        formatClipDuration(const Duration(seconds: 59, milliseconds: 999)),
        '0:59',
      );
    });
  });

  group('initialsOf', () {
    test('takes the first letter of the first two words, upper case', () {
      expect(initialsOf('Lyes B.'), 'LB');
      expect(initialsOf('ada lovelace byron'), 'AL');
    });

    test('takes one letter from a single word', () {
      expect(initialsOf('Lyes'), 'L');
    });

    test('ignores extra spaces and returns nothing for a blank name', () {
      expect(initialsOf('  Lyes   B. '), 'LB');
      expect(initialsOf('   '), '');
    });
  });
}
