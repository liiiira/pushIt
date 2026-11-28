import 'package:flutter_test/flutter_test.dart';
import 'package:pushit/features/auth/domain/auth_validators.dart';

void main() {
  group('validateEmail', () {
    test('accepts an address, ignoring spaces around it', () {
      expect(validateEmail('lyes@example.com'), isNull);
      expect(validateEmail('  lyes.b+shorts@mail.example.co  '), isNull);
    });

    test('asks for one when empty', () {
      expect(validateEmail(''), EmailError.empty);
      expect(validateEmail('   '), EmailError.empty);
    });

    test('rejects what is not an address', () {
      for (final email in [
        'lyes',
        'lyes@',
        '@example.com',
        'lyes@example',
        'lyes@@example.com',
        'ly es@example.com',
      ]) {
        expect(validateEmail(email), EmailError.invalid, reason: email);
      }
    });
  });

  group('validateNewPassword', () {
    test('needs at least $minPasswordLength characters', () {
      expect(minPasswordLength, 8);
      expect(validateNewPassword('12345678'), isNull);
      expect(validateNewPassword('1234567'), PasswordError.tooShort);
    });

    test('asks for one when empty', () {
      expect(validateNewPassword(''), PasswordError.empty);
    });
  });

  group('validatePassword (sign-in)', () {
    test('only needs one: older accounts may have shorter ones', () {
      expect(validatePassword('short'), isNull);
      expect(validatePassword(''), PasswordError.empty);
    });
  });

  group('validateName', () {
    test('needs something other than spaces', () {
      expect(validateName('Lyes B.'), isNull);
      expect(validateName('  '), NameError.empty);
    });
  });
}
