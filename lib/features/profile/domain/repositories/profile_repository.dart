import '../entities/user_profile.dart';

abstract class ProfileRepository {
  /// Live updates of a user's public profile.
  Stream<UserProfile?> watchProfile(String uid);

  /// Saves the editable profile fields.
  Future<void> updateProfile({
    required String uid,
    required String displayName,
    required String bio,
    required String generalLocation,
  });

  /// Saves the verification badge (simulated verification).
  Future<void> setVerificationBadge({required String uid, required String badge});
}