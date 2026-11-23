/// Public profile of a user, stored in users/{uid}.
class UserProfile {
  const UserProfile({
    required this.uid,
    required this.displayName,
    this.photoUrl,
    this.bio = '',
    this.generalLocation = '',
    this.verificationBadge = 'none',
  });

  final String uid;
  final String displayName;
  final String? photoUrl;
  final String bio;
  final String generalLocation;
  final String verificationBadge;

  bool get isVerified => verificationBadge != 'none';
}