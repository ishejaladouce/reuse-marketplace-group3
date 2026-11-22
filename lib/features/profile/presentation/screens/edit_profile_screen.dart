import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../providers/profile_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _bio = TextEditingController();
  final _location = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fill the form with the current profile.
    final profile = ref.read(currentProfileProvider).asData?.value;
    if (profile != null) {
      _name.text = profile.displayName;
      _bio.text = profile.bio;
      _location.text = profile.generalLocation;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _bio.dispose();
    _location.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final saved = await ref.read(editProfileControllerProvider.notifier).save(
          displayName: _name.text,
          bio: _bio.text,
          generalLocation: _location.text,
        );
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(saved ? 'Profile updated' : 'Could not save. Please try again.'),
    ));
    if (saved) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final isSaving = ref.watch(editProfileControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextFormField(
              controller: _name,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Full name'),
              validator: (value) => (value == null || value.trim().length < 2)
                  ? 'Please enter your full name'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _location,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'General location',
                hintText: 'e.g. Kigali, Gasabo',
              ),
              validator: (value) => (value != null && value.trim().length > 60)
                  ? 'Keep it under 60 characters'
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _bio,
              maxLines: 3,
              maxLength: 160,
              decoration: const InputDecoration(
                labelText: 'Bio',
                hintText: 'Tell others a little about yourself',
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: isSaving ? null : _save,
              child: isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save changes'),
            ),
          ],
        ),
      ),
    );
  }
}