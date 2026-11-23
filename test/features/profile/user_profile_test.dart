import 'package:flutter_test/flutter_test.dart';
import 'package:reuse_marketplace/features/profile/domain/entities/user_profile.dart';

void main() {
  group('UserProfile', () {
    test('a new profile starts with empty details and no badge', () {
      const profile = UserProfile(uid: 'u1', displayName: 'Ladouce');

      expect(profile.bio, isEmpty);
      expect(profile.generalLocation, isEmpty);
      expect(profile.photoUrl, isNull);
      expect(profile.verificationBadge, 'none');
      expect(profile.isVerified, isFalse);
    });

    test('a profile with a badge counts as verified', () {
      const profile = UserProfile(
        uid: 'u1',
        displayName: 'Ladouce',
        verificationBadge: 'id_verified',
      );

      expect(profile.isVerified, isTrue);
    });
  });
}