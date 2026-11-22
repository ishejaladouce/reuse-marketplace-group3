
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../data/models/listing_model.dart';
import '../../data/services/listing_image_service.dart';
import '../providers/listing_providers.dart';

class CreateEditListingScreen extends ConsumerStatefulWidget {
  final ListingModel? listing;

  const CreateEditListingScreen({
    super.key,
    this.listing,
  });

  @override
  ConsumerState<CreateEditListingScreen> createState() =>
      _CreateEditListingScreenState();
}

class _CreateEditListingScreenState
    extends ConsumerState<CreateEditListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _imageService = ListingImageService();

  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _locationController;

  final List<XFile> _selectedImages = [];
  late List<String> _existingImageUrls;

  late String _category;
  late String _condition;
  late String _status;
  late bool _pickupAvailable;
  late bool _deliveryAvailable;

  bool _saving = false;
  bool _pickingImages = false;

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
    'New',
    'Like New',
    'Good',
    'Fair',
    'Used',
  ];

  final _statuses = [
    'available',
    'reserved',
    'sold',
  ];

  bool get _isEditing => widget.listing != null;

  int get _imageCount =>
      _existingImageUrls.length + _selectedImages.length;

  @override
  void initState() {
    super.initState();

    final listing = widget.listing;

    _titleController =
        TextEditingController(text: listing?.title ?? '');
    _descriptionController =
        TextEditingController(text: listing?.description ?? '');
    _priceController = TextEditingController(
      text: listing?.price.toString() ?? '',
    );
    _locationController =
        TextEditingController(text: listing?.location ?? '');

    _existingImageUrls = List<String>.from(
      listing?.imageUrls ?? [],
    );

    _category = _categories.contains(listing?.category)
        ? listing!.category
        : 'Other';

    _condition = _conditions.contains(listing?.condition)
        ? listing!.condition
        : 'Good';

    _status = _statuses.contains(listing?.status)
        ? listing!.status
        : 'available';

    _pickupAvailable = listing?.pickupAvailable ?? true;
    _deliveryAvailable = listing?.deliveryAvailable ?? false;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'This field is required';
    }
    return null;
  }

  Future<void> _pickImages() async {
    if (_imageCount >= ListingImageService.maxImages) {
      _showMessage('Maximum of 5 images allowed.');
      return;
    }

    setState(() => _pickingImages = true);

    try {
      final images = await _imageService.pickImages(
        remainingSlots:
            ListingImageService.maxImages - _imageCount,
      );

      if (!mounted) return;

      setState(() {
        _selectedImages.addAll(images);
      });
    } catch (error) {
      if (mounted) _showMessage(error.toString());
    } finally {
      if (mounted) {
        setState(() => _pickingImages = false);
      }
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _saveListing() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage('Please sign in first.');
      return;
    }

    if (_isEditing && widget.listing!.sellerId != user.uid) {
      _showMessage('You cannot edit this listing.');
      return;
    }

    final price = double.tryParse(
      _priceController.text.trim(),
    );

    if (price == null || price <= 0) {
      _showMessage('Enter a valid price.');
      return;
    }

    setState(() => _saving = true);

    final repository = ref.read(listingRepositoryProvider);
    final now = DateTime.now();

    // Generate a stable document ID for image folder naming.
    // The repository still creates the Firestore document ID
    // when publishing a new listing.
    final storageFolderId = widget.listing?.id ??
        'draft_${now.microsecondsSinceEpoch}';

    final uploadedUrls = <String>[];

    try {
      for (final image in _selectedImages) {
        final url = await _imageService.uploadImage(
          image: image,
          listingId: storageFolderId,
        );
        uploadedUrls.add(url);
      }

      final allImageUrls = [
        ..._existingImageUrls,
        ...uploadedUrls,
      ];

      final listing = ListingModel(
        id: widget.listing?.id ?? '',
        sellerId: user.uid,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        price: price,
        currency: 'RWF',
        category: _category,
        condition: _condition,
        imageUrls: allImageUrls,
        location: _locationController.text.trim(),
        status: _status,
        pickupAvailable: _pickupAvailable,
        deliveryAvailable: _deliveryAvailable,
        createdAt: widget.listing?.createdAt ?? now,
        updatedAt: now,
      );

      if (_isEditing) {
        await repository.updateListing(listing);
      } else {
        await repository.createListing(listing);
      }

      // Remove previously uploaded images that the user
      // removed from this listing while editing.
      if (_isEditing) {
        final removedUrls = widget.listing!.imageUrls
            .where((url) => !_existingImageUrls.contains(url));

        for (final url in removedUrls) {
          try {
            await _imageService.deleteImage(url);
          } catch (_) {
            // Keep the successful Firestore update.
            // Storage cleanup can be retried separately.
          }
        }
      }

      if (!mounted) return;

      ref.invalidate(availableListingsProvider);
      ref.invalidate(userListingsProvider(user.uid));

      _showMessage(
        _isEditing
            ? 'Listing updated successfully!'
            : 'Listing published successfully!',
      );

      Navigator.pop(context, true);
    } catch (error) {
      // If Firestore fails, clean up newly uploaded images.
      for (final url in uploadedUrls) {
        try {
          await _imageService.deleteImage(url);
        } catch (_) {
          // Cleanup failure must not hide the original error.
        }
      }

      if (mounted) {
        _showMessage('Could not save listing: $error');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Item photos ($_imageCount/5)',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 10),
        OutlinedButton.icon(
          onPressed: _saving || _pickingImages
              ? null
              : _pickImages,
          icon: const Icon(Icons.add_photo_alternate_outlined),
          label: Text(
            _pickingImages
                ? 'Opening gallery...'
                : 'Choose Photos',
          ),
        ),
        const SizedBox(height: 12),
        if (_imageCount > 0)
          SizedBox(
            height: 115,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (int i = 0;
                    i < _existingImageUrls.length;
                    i++)
                  _imageTile(
                    image: Image.network(
                      _existingImageUrls[i],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.broken_image),
                    ),
                    onRemove: () {
                      setState(() {
                        _existingImageUrls.removeAt(i);
                      });
                    },
                  ),
                for (int i = 0;
                    i < _selectedImages.length;
                    i++)
                  FutureBuilder(
                    future: _selectedImages[i].readAsBytes(),
                    builder: (context, snapshot) {
                      return _imageTile(
                        image: snapshot.hasData
                            ? Image.memory(
                                snapshot.data!,
                                fit: BoxFit.cover,
                              )
                            : const Center(
                                child: CircularProgressIndicator(),
                              ),
                        onRemove: () {
                          setState(() {
                            _selectedImages.removeAt(i);
                          });
                        },
                      );
                    },
                  ),
              ],
            ),
          ),
        const Text(
          'Up to 5 photos. JPG, PNG or WebP. Maximum 5 MB each.',
        ),
      ],
    );
  }

  Widget _imageTile({
    required Widget image,
    required VoidCallback onRemove,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: SizedBox(
        width: 110,
        height: 110,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: image,
            ),
            Positioned(
              top: 2,
              right: 2,
              child: IconButton.filledTonal(
                onPressed: _saving ? null : onRemove,
                icon: const Icon(Icons.close, size: 17),
                tooltip: 'Remove photo',
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Listing' : 'Sell an Item',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              _isEditing
                  ? 'Update your item'
                  : 'Give your item a second life',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildImagePicker(),
            const SizedBox(height: 20),
            TextFormField(
              controller: _titleController,
              maxLength: 100,
              validator: _required,
              decoration: const InputDecoration(
                labelText: 'Item title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              maxLength: 1000,
              validator: _required,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _priceController,
              keyboardType:
                  const TextInputType.numberWithOptions(
                decimal: true,
              ),
              validator: (value) {
                final amount = double.tryParse(
                  value?.trim() ?? '',
                );
                return amount == null || amount <= 0
                    ? 'Enter a valid price'
                    : null;
              },
              decoration: const InputDecoration(
                labelText: 'Price (RWF)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: _categories
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text(value),
                    ),
                  )
                  .toList(),
              onChanged: _saving
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() => _category = value);
                      }
                    },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _condition,
              decoration: const InputDecoration(
                labelText: 'Condition',
                border: OutlineInputBorder(),
              ),
              items: _conditions
                  .map(
                    (value) => DropdownMenuItem(
                      value: value,
                      child: Text(value),
                    ),
                  )
                  .toList(),
              onChanged: _saving
                  ? null
                  : (value) {
                      if (value != null) {
                        setState(() => _condition = value);
                      }
                    },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationController,
              validator: _required,
              decoration: const InputDecoration(
                labelText: 'Location',
                prefixIcon: Icon(Icons.location_on_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            if (_isEditing) ...[
              DropdownButtonFormField<String>(
                value: _status,
                decoration: const InputDecoration(
                  labelText: 'Listing status',
                  border: OutlineInputBorder(),
                ),
                items: _statuses
                    .map(
                      (value) => DropdownMenuItem(
                        value: value,
                        child: Text(value.toUpperCase()),
                      ),
                    )
                    .toList(),
                onChanged: _saving
                    ? null
                    : (value) {
                        if (value != null) {
                          setState(() => _status = value);
                        }
                      },
              ),
              const SizedBox(height: 16),
            ],
            SwitchListTile(
              title: const Text('Pickup available'),
              value: _pickupAvailable,
              onChanged: _saving
                  ? null
                  : (value) {
                      setState(() => _pickupAvailable = value);
                    },
            ),
            SwitchListTile(
              title: const Text('Delivery available'),
              value: _deliveryAvailable,
              onChanged: _saving
                  ? null
                  : (value) {
                      setState(() => _deliveryAvailable = value);
                    },
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: _saving ? null : _saveListing,
                icon: _saving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: Text(
                  _saving
                      ? 'Uploading and saving...'
                      : _isEditing
                          ? 'Save Changes'
                          : 'Publish Listing',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
