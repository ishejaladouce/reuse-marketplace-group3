
import 'dart:typed_data';

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

  int _currentStep = 0;
  bool _saving = false;
  bool _pickingImages = false;
  bool _published = false;

  static const _stepTitles = [
    'Product information',
    'Add photos',
    'Price and location',
    'Review listing',
  ];

  static const _categories = [
    'Electronics',
    'Fashion',
    'Furniture',
    'Books',
    'Home',
    'Sports',
    'Other',
  ];

  static const _conditions = [
    'New',
    'Like New',
    'Good',
    'Fair',
    'Used',
  ];

  static const _statuses = [
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

    _titleController = TextEditingController(
      text: listing?.title ?? '',
    );
    _descriptionController = TextEditingController(
      text: listing?.description ?? '',
    );
    _priceController = TextEditingController(
      text: listing?.price.toString() ?? '',
    );
    _locationController = TextEditingController(
      text: listing?.location ?? '',
    );

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

  void _showMessage(String message) {
    debugPrint('LISTING: $message');

    if (!mounted) return;

    final messenger = ScaffoldMessenger.maybeOf(context);

    if (messenger != null && messenger.mounted) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 5),
        ),
      );
    }
  }

  bool _validateProduct() {
    if (_titleController.text.trim().isEmpty) {
      _showMessage('Please enter a product title.');
      return false;
    }

    if (_descriptionController.text.trim().isEmpty) {
      _showMessage('Please enter a description.');
      return false;
    }

    return true;
  }

  bool _validatePhotos() {
    if (_imageCount == 0) {
      _showMessage('Please add at least one photo.');
      return false;
    }

    if (_imageCount > ListingImageService.maxImages) {
      _showMessage('Too many photos selected.');
      return false;
    }

    return true;
  }

  bool _validatePriceAndLocation() {
    final price = double.tryParse(
      _priceController.text.trim(),
    );

    if (price == null || !price.isFinite || price <= 0) {
      _showMessage('Enter a valid price greater than zero.');
      return false;
    }

    if (_locationController.text.trim().isEmpty) {
      _showMessage('Please enter your location.');
      return false;
    }

    if (!_pickupAvailable && !_deliveryAvailable) {
      _showMessage(
        'Choose pickup, delivery, or both.',
      );
      return false;
    }

    return true;
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _validateProduct();
      case 1:
        return _validatePhotos();
      case 2:
        return _validatePriceAndLocation();
      default:
        return true;
    }
  }

  bool _validateAll() {
    if (!_validateProduct()) {
      setState(() => _currentStep = 0);
      return false;
    }

    if (!_validatePhotos()) {
      setState(() => _currentStep = 1);
      return false;
    }

    if (!_validatePriceAndLocation()) {
      setState(() => _currentStep = 2);
      return false;
    }

    return true;
  }

  void _nextStep() {
    if (!_validateCurrentStep()) return;

    if (_currentStep < 3) {
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  Future<void> _pickImages() async {
    if (_saving || _pickingImages) return;

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
      _showMessage('Could not select photos: $error');
    } finally {
      if (mounted) {
        setState(() => _pickingImages = false);
      }
    }
  }

  Future<void> _saveListing() async {
    if (_saving || !_validateAll()) return;

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      _showMessage('Please sign in first.');
      return;
    }

    if (_isEditing && widget.listing!.sellerId != user.uid) {
      _showMessage('You cannot edit this listing.');
      return;
    }

    setState(() => _saving = true);

    final repository = ref.read(listingRepositoryProvider);
    final now = DateTime.now();

    final storageFolderId = widget.listing?.id ??
        'draft_${now.microsecondsSinceEpoch}';

    final uploadedUrls = <String>[];
    bool firestoreSaved = false;

    try {
      debugPrint('LISTING: Starting image uploads');

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
        price: double.parse(_priceController.text.trim()),
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

      debugPrint('LISTING: Starting Firestore save');

      if (_isEditing) {
        await repository.updateListing(listing);
      } else {
        await repository.createListing(listing);
      }

      firestoreSaved = true;

      debugPrint('LISTING: Firestore save completed');

      // Clean up removed images after a successful update.
      if (_isEditing) {
        final removedUrls = widget.listing!.imageUrls.where(
          (url) => !_existingImageUrls.contains(url),
        );

        for (final url in removedUrls) {
          try {
            await _imageService.deleteImage(url);
          } catch (error) {
            debugPrint(
              'LISTING: Image cleanup warning: $error',
            );
          }
        }
      }

      if (!mounted) return;

      ref.invalidate(availableListingsProvider);
      ref.invalidate(userListingsProvider(user.uid));

      if (_isEditing && Navigator.of(context).canPop()) {
        Navigator.of(context).pop(true);
        return;
      }

      _resetForm();

_showMessage('Listing published successfully!');
    } catch (error, stackTrace) {
      debugPrint('LISTING SAVE ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);

      // Only roll back uploads if Firestore did not save.
      if (!firestoreSaved) {
        for (final url in uploadedUrls) {
          try {
            await _imageService.deleteImage(url);
          } catch (cleanupError) {
            debugPrint(
              'LISTING: Rollback warning: $cleanupError',
            );
          }
        }
      }

      _showMessage('Could not save listing: $error');
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  void _resetForm() {
    _titleController.clear();
    _descriptionController.clear();
    _priceController.clear();
    _locationController.clear();

    setState(() {
      _selectedImages.clear();
      _existingImageUrls = [];
      _category = 'Other';
      _condition = 'Good';
      _status = 'available';
      _pickupAvailable = true;
      _deliveryAvailable = false;
      _currentStep = 0;
      _published = false;
    });
  }

  Widget _heading(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildProductInformation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading(
          'Tell us about your item',
          'Help buyers understand what you are selling.',
        ),
        const SizedBox(height: 24),

        TextFormField(
          controller: _titleController,
          enabled: !_saving,
          maxLength: 100,
          decoration: const InputDecoration(
            labelText: 'Product title',
            hintText: 'e.g. Samsung Galaxy S22',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),

        TextFormField(
          controller: _descriptionController,
          enabled: !_saving,
          maxLines: 5,
          maxLength: 1000,
          decoration: const InputDecoration(
            labelText: 'Description',
            hintText: 'Describe the item and its condition',
            alignLabelWithHint: true,
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),

        DropdownButtonFormField<String>(
          key: ValueKey('category-$_category'),
          initialValue: _category,
          decoration: const InputDecoration(
            labelText: 'Category',
            border: OutlineInputBorder(),
          ),
          items: _categories.map((category) {
            return DropdownMenuItem(
              value: category,
              child: Text(category),
            );
          }).toList(),
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
          key: ValueKey('condition-$_condition'),
          initialValue: _condition,
          decoration: const InputDecoration(
            labelText: 'Item condition',
            border: OutlineInputBorder(),
          ),
          items: _conditions.map((condition) {
            return DropdownMenuItem(
              value: condition,
              child: Text(condition),
            );
          }).toList(),
          onChanged: _saving
              ? null
              : (value) {
                  if (value != null) {
                    setState(() => _condition = value);
                  }
                },
        ),
      ],
    );
  }

  Widget _buildPhotos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading(
          'Show off your item',
          'Add up to ${ListingImageService.maxImages} clear photos.',
        ),
        const SizedBox(height: 20),

        Text(
          '$_imageCount / ${ListingImageService.maxImages} photos',
        ),
        const SizedBox(height: 12),

        OutlinedButton.icon(
          onPressed: _saving || _pickingImages
              ? null
              : _pickImages,
          icon: _pickingImages
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                )
              : const Icon(Icons.add_photo_alternate_outlined),
          label: Text(
            _pickingImages
                ? 'Opening gallery...'
                : 'Add Photos',
          ),
        ),
        const SizedBox(height: 20),

        if (_imageCount == 0)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 30),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.photo_library_outlined,
                    size: 64,
                  ),
                  SizedBox(height: 12),
                  Text('No photos selected yet'),
                ],
              ),
            ),
          ),

        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _imageCount,
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1,
          ),
          itemBuilder: (context, index) {
            final existingCount = _existingImageUrls.length;
            final isExisting = index < existingCount;

            final image = isExisting
                ? Image.network(
                    _existingImageUrls[index],
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.broken_image_outlined),
                  )
                : FutureBuilder<Uint8List>(
                    future: _selectedImages[
                            index - existingCount]
                        .readAsBytes(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      return Image.memory(
                        snapshot.data!,
                        fit: BoxFit.cover,
                      );
                    },
                  );

            return ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  image,
                  Positioned(
                    top: 4,
                    right: 4,
                    child: IconButton.filledTonal(
                      tooltip: 'Remove photo',
                      onPressed: _saving
                          ? null
                          : () {
                              setState(() {
                                if (isExisting) {
                                  _existingImageUrls.removeAt(index);
                                } else {
                                  _selectedImages.removeAt(
                                    index - existingCount,
                                  );
                                }
                              });
                            },
                      icon: const Icon(
                        Icons.close,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPriceAndLocation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading(
          'Set your price',
          'Let buyers know the price and how to receive it.',
        ),
        const SizedBox(height: 24),

        TextFormField(
          controller: _priceController,
          enabled: !_saving,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
          ),
          decoration: const InputDecoration(
            labelText: 'Price (RWF)',
            prefixIcon: Icon(Icons.payments_outlined),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),

        TextFormField(
          controller: _locationController,
          enabled: !_saving,
          decoration: const InputDecoration(
            labelText: 'Location',
            hintText: 'e.g. Kigali, Rwanda',
            prefixIcon: Icon(Icons.location_on_outlined),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),

        SwitchListTile(
          title: const Text('Pickup available'),
          subtitle: const Text(
            'Buyers can collect the item',
          ),
          value: _pickupAvailable,
          onChanged: _saving
              ? null
              : (value) {
                  setState(() => _pickupAvailable = value);
                },
        ),

        SwitchListTile(
          title: const Text('Delivery available'),
          subtitle: const Text(
            'You can arrange delivery',
          ),
          value: _deliveryAvailable,
          onChanged: _saving
              ? null
              : (value) {
                  setState(() => _deliveryAvailable = value);
                },
        ),

        if (_isEditing) ...[
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(
            key: ValueKey('status-$_status'),
            initialValue: _status,
            decoration: const InputDecoration(
              labelText: 'Listing status',
              border: OutlineInputBorder(),
            ),
            items: _statuses.map((status) {
              return DropdownMenuItem(
                value: status,
                child: Text(
                  status[0].toUpperCase() +
                      status.substring(1),
                ),
              );
            }).toList(),
            onChanged: _saving
                ? null
                : (value) {
                    if (value != null) {
                      setState(() => _status = value);
                    }
                  },
          ),
        ],
      ],
    );
  }

  Widget _reviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 9),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 115,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildReview() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _heading(
          'Almost there!',
          'Review your details before publishing.',
        ),
        const SizedBox(height: 24),

        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _reviewRow(
                  'Title',
                  _titleController.text.trim(),
                ),
                _reviewRow(
                  'Description',
                  _descriptionController.text.trim(),
                ),
                _reviewRow('Category', _category),
                _reviewRow('Condition', _condition),
                _reviewRow(
                  'Price',
                  '${_priceController.text.trim()} RWF',
                ),
                _reviewRow(
                  'Location',
                  _locationController.text.trim(),
                ),
                _reviewRow(
                  'Photos',
                  '$_imageCount selected',
                ),
                _reviewRow(
                  'Pickup',
                  _pickupAvailable ? 'Yes' : 'No',
                ),
                _reviewRow(
                  'Delivery',
                  _deliveryAvailable ? 'Yes' : 'No',
                ),
                if (_isEditing)
                  _reviewRow('Status', _status),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        const Text(
          'Your listing will be visible to other users '
          'after it has been successfully saved.',
        ),
      ],
    );
  }

  Widget _buildPublished() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              size: 90,
              color: Colors.green,
            ),
            const SizedBox(height: 20),
            Text(
              'Listing Published!',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Your item has been successfully listed.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),

            FilledButton.icon(
              onPressed: _resetForm,
              icon: const Icon(Icons.add),
              label: const Text('Sell Another Item'),
            ),
            const SizedBox(height: 12),

            OutlinedButton(
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop(true);
                } else {
                  _resetForm();
                }
              },
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildProductInformation();
      case 1:
        return _buildPhotos();
      case 2:
        return _buildPriceAndLocation();
      case 3:
        return _buildReview();
      default:
        return _buildProductInformation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Listing' : 'Sell an Item',
        ),
      ),
      body: _published
          ? _buildPublished()
          : SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Step ${_currentStep + 1} of 4',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge,
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: (_currentStep + 1) / 4,
                          minHeight: 6,
                          borderRadius:
                              BorderRadius.circular(10),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _stepTitles[_currentStep],
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium,
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        20, 0, 20, 24,
                      ),
                      child: _buildStepContent(),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        if (_currentStep > 0) ...[
                          OutlinedButton(
                            onPressed:
                                _saving ? null : _previousStep,
                            child: const Text('Back'),
                          ),
                          const SizedBox(width: 12),
                        ],

                        Expanded(
                          child: FilledButton(
                            onPressed: _saving
                                ? null
                                : _currentStep == 3
                                    ? _saveListing
                                    : _nextStep,
                            child: _saving
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child:
                                        CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    _currentStep == 3
                                        ? _isEditing
                                            ? 'Save Changes'
                                            : 'Publish Listing'
                                        : 'Continue',
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
