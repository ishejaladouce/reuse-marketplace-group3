import 'package:flutter_test/flutter_test.dart';
import 'package:reuse_marketplace/core/utils/validators.dart';

void main() {
  group('Validators.fullName', () {
    test('rejects an empty name', () {
      expect(Validators.fullName(''), 'Please enter your full name');
      expect(Validators.fullName('   '), 'Please enter your full name');
      expect(Validators.fullName(null), 'Please enter your full name');
    });

    test('rejects a name that is too short or too long', () {
      expect(Validators.fullName('A'), 'Name must be at least 2 characters');
      expect(Validators.fullName('A' * 51), 'Name must be 50 characters or fewer');
    });

    test('rejects numbers and symbols', () {
      const message = 'Name can only contain letters, spaces, hyphens and apostrophes';
      expect(Validators.fullName('Ladouce123'), message);
      expect(Validators.fullName('@@@'), message);
      expect(Validators.fullName('Ladouce  Isheja'), message); // double space
    });

    test('accepts real names, including accents, hyphens and apostrophes', () {
      expect(Validators.fullName('Ladouce Isheja'), isNull);
      expect(Validators.fullName('Marie-Claire'), isNull);
      expect(Validators.fullName("O'Brien"), isNull);
      expect(Validators.fullName('Aimée Uwase'), isNull);
    });
  });

  group('Validators.email', () {
    test('rejects an empty email', () {
      expect(Validators.email(''), 'Please enter your email');
      expect(Validators.email(null), 'Please enter your email');
    });

    test('rejects badly formatted emails', () {
      const message = 'Please enter a valid email address';
      expect(Validators.email('ladouce@'), message);
      expect(Validators.email('ladouce.gmail.com'), message);
      expect(Validators.email('ladouce@gmail'), message);
      expect(Validators.email('lad..ouce@gmail.com'), message);
      expect(Validators.email('a@b.c'), message);
      expect(Validators.email('ladouce @gmail.com'), message);
    });

    test('rejects an email that is too long', () {
      expect(Validators.email('${'a' * 250}@gmail.com'), 'Email is too long');
    });

    test('accepts valid emails, even with spaces around them', () {
      expect(Validators.email(' ishejaladouce@gmail.com '), isNull);
      expect(Validators.email('l.isheja@alustudent.com'), isNull);
      expect(Validators.email('ladouce+shop@mail.co.rw'), isNull);
    });
  });

  group('Validators.password', () {
    test('rejects an empty password', () {
      expect(Validators.password(''), 'Please enter a password');
      expect(Validators.password(null), 'Please enter a password');
    });

    test('rejects spaces', () {
      expect(Validators.password('secret 123'), 'Password cannot contain spaces');
    });

    test('rejects a password that is too short or too long', () {
      expect(Validators.password('abc123'), 'Password must be at least 8 characters');
      expect(Validators.password('a1' * 33), 'Password must be 64 characters or fewer');
    });

    test('requires at least one letter and one number', () {
      const message = 'Password must contain at least one letter and one number';
      expect(Validators.password('abcdefgh'), message);
      expect(Validators.password('12345678'), message);
    });

    test('accepts a strong password', () {
      expect(Validators.password('secret123'), isNull);
    });
  });

  group('Validators.loginPassword', () {
    test('only checks that a password was typed', () {
      expect(Validators.loginPassword(''), 'Please enter your password');
      expect(Validators.loginPassword(null), 'Please enter your password');
      expect(Validators.loginPassword('abcdefgh'), isNull);
    });
  });

  group('Validators.confirmPassword', () {
    test('rejects an empty confirmation', () {
      expect(Validators.confirmPassword('', 'secret123'), 'Please confirm your password');
    });

    test('rejects passwords that do not match', () {
      expect(Validators.confirmPassword('secret124', 'secret123'), 'Passwords do not match');
    });

    test('accepts matching passwords', () {
      expect(Validators.confirmPassword('secret123', 'secret123'), isNull);
    });
  });

  group('Validators.phone', () {
    test('is optional', () {
      expect(Validators.phone(''), isNull);
      expect(Validators.phone('   '), isNull);
      expect(Validators.phone(null), isNull);
    });

    test('rejects letters and symbols', () {
      expect(Validators.phone('078abc4567'), 'Phone number can only contain digits');
      expect(Validators.phone('0785#247599'), 'Phone number can only contain digits');
    });

    test('rejects a number that is too short or too long', () {
      expect(Validators.phone('12345'), 'Please enter a valid phone number');
      expect(Validators.phone('+1234 5678 9012 3456'), 'Please enter a valid phone number');
    });

    test('rejects a country code starting with 0', () {
      expect(Validators.phone('+0785247599'), 'Country code cannot start with 0');
    });

    test('accepts local and international numbers', () {
      expect(Validators.phone('0785247599'), isNull); // Rwanda, local
      expect(Validators.phone('+250 785 247 599'), isNull); // Rwanda
      expect(Validators.phone('+1 (415) 555-2671'), isNull); // USA
      expect(Validators.phone('+44 20 7946 0958'), isNull); // UK
      expect(Validators.phone('+234 803 123 4567'), isNull); // Nigeria
      expect(Validators.phone('+254 712 345 678'), isNull); // Kenya
      expect(Validators.phone('+33 6 12 34 56 78'), isNull); // France
    });
  });
}