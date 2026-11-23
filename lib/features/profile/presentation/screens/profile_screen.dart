import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../reviews/data/models/review_model.dart';
import '../../../reviews/presentation/providers/review_provider.dart';
import '../../domain/entities/user_profile.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My profile')),
      body: profile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => const Center(
          child: Text('Could not load your profile. Please try again.'),
        ),
        data: (user) => user == null
            ? const Center(child: Text('Profile not found.'))
            : _ProfileBody(profile: user),
      ),
    );
  }
}

class _ProfileBody extends ConsumerWidget {
  const _ProfileBody({required this.profile});

  final UserProfile profile;

  String get _initials {
    final parts = profile.displayName.trim().split(' ').where((p) => p.isNotEmpty);
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  String get _badgeLabel {
    switch (profile.verificationBadge) {
      case 'id_verified':
        return 'ID verified';
      case 'phone_verified':
        return 'Phone verified';
      default:
        return 'Not verified yet';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Center(
          child: CircleAvatar(
            radius: 44,
            backgroundColor: AppColors.primary,
            backgroundImage:
                profile.photoUrl != null ? NetworkImage(profile.photoUrl!) : null,
            child: profile.photoUrl == null
                ? Text(_initials,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold))
                : null,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          profile.displayName,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Center(
          child: Chip(
            avatar: Icon(
              profile.isVerified ? Icons.verified : Icons.shield_outlined,
              size: 18,
              color: profile.isVerified ? AppColors.primary : AppColors.textMuted,
            ),
            label: Text(_badgeLabel),
          ),
        ),
        const SizedBox(height: 24),
        _RatingTile(uid: profile.uid),
        _InfoTile(
          icon: Icons.location_on_outlined,
          label: 'Location',
          value: profile.generalLocation.isEmpty
              ? 'Not added yet'
              : profile.generalLocation,
        ),
        _InfoTile(
          icon: Icons.info_outline,
          label: 'Bio',
          value: profile.bio.isEmpty ? 'Not added yet' : profile.bio,
        ),
        const SizedBox(height: 24),
        if (!profile.isVerified) ...[
          FilledButton.icon(
            onPressed: () => context.push('/profile/verify'),
            icon: const Icon(Icons.verified_outlined),
            label: const Text('Get verified'),
          ),
          const SizedBox(height: 12),
        ],
        OutlinedButton.icon(
          onPressed: () => context.push('/profile/edit'),
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Edit profile'),
        ),
        const SizedBox(height: 12),
        TextButton.icon(
          onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
          icon: const Icon(Icons.logout),
          label: const Text('Log out'),
        ),
      ],
    );
  }
}

/// Shows the seller's average rating and opens their reviews.
class _RatingTile extends ConsumerWidget {
  const _RatingTile({required this.uid});

  final String uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviews = ref.watch(sellerReviewsProvider(uid)).asData?.value ?? const <Review>[];
    final hasReviews = reviews.isNotEmpty;
    final summary = hasReviews
        ? '${averageRating(reviews).toStringAsFixed(1)} out of 5 '
            '(${reviews.length} review${reviews.length == 1 ? '' : 's'})'
        : 'No reviews yet';

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.star_rounded, color: Colors.amber),
      title: const Text('Rating', style: TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(summary),
      trailing: hasReviews ? const Icon(Icons.chevron_right) : null,
      onTap: hasReviews ? () => context.push('/users/$uid/reviews') : null,
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppColors.primary),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(value),
    );
  }
}