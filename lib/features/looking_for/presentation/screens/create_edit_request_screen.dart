
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../listings/data/models/looking_for_request_model.dart';
import '../../../listings/presentation/providers/looking_for_providers.dart';

class CreateEditRequestScreen extends ConsumerStatefulWidget {
  final LookingForRequestModel? request;

  const CreateEditRequestScreen({
    super.key,
    this.request,
  });

  @override
  ConsumerState<CreateEditRequestScreen> createState() =>
      _CreateEditRequestScreenState();
}

class _CreateEditRequestScreenState
    extends ConsumerState<CreateEditRequestScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _locationController;
  late final TextEditingController _minBudgetController;
  late final TextEditingController _maxBudgetController;

  late String _category;
  late String _condition;
  late String _status;

  bool _saving = false;

  final _categories = [
    'Electronics',
    'Fashion',
    'Furniture',
    'Books',
    'Home',
    'Sports',
    'Other',
  ];

  final _conditions = [
    'Any',
    'New',
    'Like New',
    'Good',
    'Fair',
    'Used',
  ];

  bool get _editing => widget.request != null;

  @override
  void initState() {
    super.initState();

    final request = widget.request;

    _titleController =
        TextEditingController(text: request?.title ?? '');
    _descriptionController =
        TextEditingController(text: request?.description ?? '');
    _locationController =
        TextEditingController(text: request?.location ?? '');

    _minBudgetController = TextEditingController(
      text: request?.minBudget?.toString() ?? '',
    );
    _maxBudgetController = TextEditingController(
      text: request?.maxBudget?.toString() ?? '',
    );

    _category = _categories.contains(request?.category)
        ? request!.category
        : 'Other';

    _condition = _conditions.contains(request?.preferredCondition)
        ? request!.preferredCondition
        : 'Any';

    _status = request?.status == 'closed' ? 'closed' : 'open';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _minBudgetController.dispose();
    _maxBudgetController.dispose();
    super.dispose();
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  String? _validateBudget(String? value) {
    if (value == null || value.trim().isEmpty) return null;

    final amount = double.tryParse(value.trim());

    if (amount == null || amount < 0) {
      return 'Enter a valid non-negative amount';
    }

    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final messenger = ScaffoldMessenger.maybeOf(context);

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in first.')),
      );
      return;
    }

    final minBudget = _minBudgetController.text.trim().isEmpty
        ? null
        : double.tryParse(_minBudgetController.text.trim());

    final maxBudget = _maxBudgetController.text.trim().isEmpty
        ? null
        : double.tryParse(_maxBudgetController.text.trim());

    if (minBudget != null &&
        maxBudget != null &&
        minBudget > maxBudget) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Minimum budget cannot exceed maximum budget.',
          ),
        ),
      );
      return;
    }

    setState(() => _saving = true);

    try {
      final now = DateTime.now();

      final request = LookingForRequestModel(
        id: widget.request?.id ?? '',
        authorId: user.uid,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _category,
        preferredCondition: _condition,
        minBudget: minBudget,
        maxBudget: maxBudget,
        currency: 'RWF',
        location: _locationController.text.trim(),
        status: _status,
        createdAt: widget.request?.createdAt ?? now,
        updatedAt: now,
      );

      final repository = ref.read(lookingForRepositoryProvider);

      if (_editing) {
        await repository.updateRequest(request);
      } else {
        await repository.createRequest(request);
      }

      if (!mounted) return;

      ref.invalidate(openLookingForRequestsProvider);
      ref.invalidate(userLookingForRequestsProvider(user.uid));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _editing
                ? 'Request updated successfully!'
                : 'Request published successfully!',
          ),
        ),
      );
      _formKey.currentState?.reset();
      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save request: $error')),
      );
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_editing ? 'Edit Request' : 'Post a Request'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              _editing
                  ? 'Update what you are looking for'
                  : 'Tell the community what you need',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'What are you looking for?',
                border: OutlineInputBorder(),
              ),
              maxLength: 100,
              validator: _required,
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              maxLength: 1000,
              decoration: const InputDecoration(
                labelText: 'Description',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
              validator: _required,
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: _categories
                  .map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _category = value);
                }
              },
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _condition,
              decoration: const InputDecoration(
                labelText: 'Preferred condition',
                border: OutlineInputBorder(),
              ),
              items: _conditions
                  .map(
                    (condition) => DropdownMenuItem(
                      value: condition,
                      child: Text(condition),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _condition = value);
                }
              },
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _minBudgetController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Min budget (RWF)',
                      border: OutlineInputBorder(),
                    ),
                    validator: _validateBudget,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _maxBudgetController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Max budget (RWF)',
                      border: OutlineInputBorder(),
                    ),
                    validator: _validateBudget,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Preferred location',
                prefixIcon: Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(),
              ),
              validator: _required,
            ),
            const SizedBox(height: 16),

            if (_editing) ...[
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(
                  labelText: 'Request status',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'open',
                    child: Text('Open'),
                  ),
                  DropdownMenuItem(
                    value: 'closed',
                    child: Text('Closed'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _status = value);
                  }
                },
              ),
              const SizedBox(height: 16),
            ],

            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: Text(
                  _saving
                      ? 'Saving...'
                      : _editing
                          ? 'Save Changes'
                          : 'Publish Request',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
