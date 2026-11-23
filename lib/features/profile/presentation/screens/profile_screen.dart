
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/user_profile.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My profile'),
      ),
      body: profile.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Could not load your profile. Please try again.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  ref.invalidate(currentProfileProvider);
                },
                child: const Text('Try again'),
              ),
            ],
          ),
        ),
       data: (user) => user == null
    ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Profile not found.'),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () async {
                await ref
                    .read(authControllerProvider.notifier)
                    .signOut();
              },
              icon: const Icon(Icons.logout),
              label: const Text('Log out and sign in again'),
            ),
          ],
        ),
      )
    : _ProfileBody(profile: user),
      ),
    );
  }
}

class _ProfileBody extends ConsumerWidget {
  const _ProfileBody({
    required this.profile,
  });

  final UserProfile profile;

  String get _initials {
    final parts = profile.displayName
        .trim()
        .split(' ')
        .where((part) => part.isNotEmpty);

    final initials = parts
        .take(2)
        .map((part) => part[0].toUpperCase())
        .join();

    return initials.isEmpty ? '?' : initials;
  }

  String get _badgeLabel {
    switch (profile.verificationBadge) {
      case 'id_verified':
        return 'ID badge (demo)';
      case 'phone_verified':
        return 'Phone badge (demo)';
      default:
        return 'Not verified yet';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // Profile picture
        Center(
          child: CircleAvatar(
            radius: 44,
            backgroundColor: AppColors.primary,
            backgroundImage: profile.photoUrl != null &&
                    profile.photoUrl!.isNotEmpty
                ? NetworkImage(profile.photoUrl!)
                : null,
            child: profile.photoUrl == null ||
                    profile.photoUrl!.isEmpty
                ? Text(
                    _initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
        ),

        const SizedBox(height: 16),

        // Display name
        Text(
          profile.displayName,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        // Verification status
        Center(
          child: Chip(
            avatar: Icon(
              profile.isVerified
                  ? Icons.verified
                  : Icons.shield_outlined,
              size: 18,
              color: profile.isVerified
                  ? AppColors.primary
                  : AppColors.textMuted,
            ),
            label: Text(_badgeLabel),
          ),
        ),

        const SizedBox(height: 24),

        // User information
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
          value: profile.bio.isEmpty
              ? 'Not added yet'
              : profile.bio,
        ),

        const SizedBox(height: 24),

        // Marketplace navigation
        const Text(
          'Marketplace',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        _MenuTile(
          icon: Icons.receipt_long_outlined,
          title: 'Purchases & Sales',
          subtitle: 'Track your marketplace orders',
          onTap: () => context.push('/orders'),
        ),

        _MenuTile(
          icon: Icons.inventory_2_outlined,
          title: 'My Listings',
          subtitle: 'Manage items you are selling',
          onTap: () => context.push('/my-listings'),
        ),

        _MenuTile(
          icon: Icons.campaign_outlined,
          title: 'My Requests',
          subtitle: 'Manage your Looking For posts',
          onTap: () => context.push('/my-requests'),
        ),

        const SizedBox(height: 24),

        // Account management
        const Text(
          'Account',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        if (!profile.isVerified) ...[
          FilledButton.icon(
            onPressed: () {
              context.push('/profile/verify');
            },
            icon: const Icon(Icons.verified_outlined),
            label: const Text('Try demo verification'),
          ),
          const SizedBox(height: 12),
        ],

        OutlinedButton.icon(
          onPressed: () {
            context.push('/profile/edit');
          },
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Edit profile'),
        ),

        const SizedBox(height: 12),

        TextButton.icon(
          onPressed: () async {
            await ref
                .read(authControllerProvider.notifier)
                .signOut();
          },
          icon: const Icon(Icons.logout),
          label: const Text('Log out'),
        ),

        const SizedBox(height: 16),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        color: AppColors.primary,
      ),
      title: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(value),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 6,
        ),
        leading: Icon(
          icon,
          color: AppColors.primary,
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(
          Icons.chevron_right,
        ),
        onTap: onTap,
      ),
    );
  }
}
