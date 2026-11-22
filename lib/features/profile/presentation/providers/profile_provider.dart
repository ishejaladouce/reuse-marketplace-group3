import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/firebase_providers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepositoryImpl(ref.watch(firestoreProvider)),
);

/// The logged-in user's profile, updated live from Firestore.
final currentProfileProvider = StreamProvider<UserProfile?>((ref) {
  final user = ref.watch(authStateProvider).asData?.value;
  if (user == null) return Stream.value(null);
  return ref.watch(profileRepositoryProvider).watchProfile(user.uid);
});

/// Saves profile changes and tracks loading and errors.
class EditProfileController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<bool> save({
    required String displayName,
    required String bio,
    required String generalLocation,
  }) async {
    final user = ref.read(authStateProvider).asData?.value;
    if (user == null) return false;

    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(profileRepositoryProvider).updateProfile(
            uid: user.uid,
            displayName: displayName,
            bio: bio,
            generalLocation: generalLocation,
          ),
    );
    return !state.hasError;
  }
}

final editProfileControllerProvider =
    AsyncNotifierProvider<EditProfileController, void>(EditProfileController.new);