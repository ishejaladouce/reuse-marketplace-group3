import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../providers/profile_provider.dart';

enum VerificationMethod { nationalId, passport, phone }

class VerificationScreen extends ConsumerStatefulWidget {
  const VerificationScreen({super.key});

  @override
  ConsumerState<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends ConsumerState<VerificationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _number = TextEditingController();
  final _method = ValueNotifier<VerificationMethod>(VerificationMethod.nationalId);

  // Rwandan national ID: 16 digits = category (1-3) + birth year (4) + gender (7 or 8)
  // + 10 more digits. Example: 1 1998 8 0012345 6 78.
  static final _nationalIdPattern = RegExp(r'^[1-3](\d{4})[78]\d{10}$');

  // Passport: 1 or 2 letters followed by 6 to 9 digits. Example: PC1234567.
  static final _passportPattern = RegExp(r'^[A-Z]{1,2}\d{6,9}$');

  @override
  void dispose() {
    _number.dispose();
    _method.dispose();
    super.dispose();
  }

  String? _validateNumber(String? value) {
    final text = (value ?? '').replaceAll(' ', '').toUpperCase();

    switch (_method.value) {
      case VerificationMethod.nationalId:
        if (text.isEmpty) return 'Please enter your national ID number';
        if (!RegExp(r'^\d+$').hasMatch(text)) return 'National ID can only contain digits';
        if (text.length != 16) return 'National ID must have exactly 16 digits';
        final match = _nationalIdPattern.firstMatch(text);
        if (match == null) return 'This is not a valid national ID format';
        final birthYear = int.parse(match.group(1)!);
        final currentYear = DateTime.now().year;
        if (birthYear < 1900 || birthYear > currentYear) {
          return 'The birth year in this ID is not valid';
        }
        if (currentYear - birthYear < 16) {
          return 'You must be at least 16 to verify with a national ID';
        }
        return null;

      case VerificationMethod.passport:
        if (text.isEmpty) return 'Please enter your passport number';
        if (!_passportPattern.hasMatch(text)) {
          return 'Use 1 or 2 letters followed by 6 to 9 digits (e.g. PC1234567)';
        }
        return null;

      case VerificationMethod.phone:
        if (text.isEmpty) return 'Please enter your phone number';
        return Validators.phone(value);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final badge =
        _method.value == VerificationMethod.phone ? 'phone_verified' : 'id_verified';
    final verified =
        await ref.read(verificationControllerProvider.notifier).verify(badge);
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(verified
          ? 'You are now verified!'
          : 'Verification failed. Please try again.'),
    ));
    if (verified) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(currentProfileProvider).asData?.value;
    final isChecking = ref.watch(verificationControllerProvider).isLoading;

    if (profile != null && profile.isVerified) {
      return Scaffold(
        appBar: AppBar(title: const Text('Verification')),
        body: const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified, size: 64, color: AppColors.primary),
                SizedBox(height: 16),
                Text('You are verified',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('Your badge is shown on your profile.', textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Get verified')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Icon(Icons.shield_outlined, size: 56, color: AppColors.primary),
            const SizedBox(height: 12),
            const Text(
              'A verified badge shows buyers and sellers that they can trust you.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              'This is a demo: the format is checked, but no real documents are, '
              'and your number is never saved.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 24),
            ValueListenableBuilder<VerificationMethod>(
              valueListenable: _method,
              builder: (context, method, _) {
                final (label, hint, keyboard) = switch (method) {
                  VerificationMethod.nationalId =>
                    ('National ID number', 'e.g. 1 1998 8 0012345 6 78', TextInputType.number),
                  VerificationMethod.passport =>
                    ('Passport number', 'e.g. PC1234567', TextInputType.text),
                  VerificationMethod.phone =>
                    ('Phone number', 'e.g. +250 785 247 599', TextInputType.phone),
                };
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SegmentedButton<VerificationMethod>(
                      segments: const [
                        ButtonSegment(
                          value: VerificationMethod.nationalId,
                          label: Text('ID'),
                          icon: Icon(Icons.badge_outlined),
                        ),
                        ButtonSegment(
                          value: VerificationMethod.passport,
                          label: Text('Passport'),
                          icon: Icon(Icons.flight_outlined),
                        ),
                        ButtonSegment(
                          value: VerificationMethod.phone,
                          label: Text('Phone'),
                          icon: Icon(Icons.phone_outlined),
                        ),
                      ],
                      selected: {method},
                      onSelectionChanged: (selection) {
                        _method.value = selection.first;
                        _number.clear();
                        _formKey.currentState?.reset();
                      },
                    ),
                    const SizedBox(height: 20),
                    AppTextField(
                      label: label,
                      hint: hint,
                      controller: _number,
                      keyboardType: keyboard,
                      textCapitalization: method == VerificationMethod.passport
                          ? TextCapitalization.characters
                          : TextCapitalization.none,
                      textInputAction: TextInputAction.done,
                      validator: _validateNumber,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: isChecking ? null : _submit,
              child: isChecking
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text('Checking...'),
                      ],
                    )
                  : const Text('Verify me'),
            ),
          ],
        ),
      ),
    );
  }
}