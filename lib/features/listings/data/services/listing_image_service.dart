
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ListingImageService {
  ListingImageService({
    SupabaseClient? client,
  }) : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static const String bucketName = 'listing-images';
  static const int maxImages = 5;
  static const int maxFileBytes = 5 * 1024 * 1024;

  final ImagePicker _picker = ImagePicker();

  Future<List<XFile>> pickImages({
    int remainingSlots = maxImages,
  }) async {
    if (remainingSlots <= 0) return [];

    final images = await _picker.pickMultiImage(
      imageQuality: 75,
      maxWidth: 1600,
    );

    if (images.length > remainingSlots) {
      throw Exception(
        'You can select only $remainingSlots more image(s).',
      );
    }

    for (final image in images) {
      await _validateImage(image);
    }

    return images;
  }

  Future<void> _validateImage(XFile image) async {
    final extension = image.name
        .split('.')
        .last
        .toLowerCase();

    if (!['jpg', 'jpeg', 'png', 'webp'].contains(extension)) {
      throw Exception(
        'Only JPG, PNG and WebP images are supported.',
      );
    }

    final size = await image.length();

    if (size > maxFileBytes) {
      throw Exception(
        '${image.name} exceeds the 5 MB limit.',
      );
    }

    if (size == 0) {
      throw Exception('The selected image is empty.');
    }
  }

  String _contentType(String extension) {
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  Future<String> uploadImage({
    required XFile image,
    required String listingId,
  }) async {
    await _validateImage(image);

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw StateError('Sign in before uploading images.');
    }

    final extension = image.name
        .split('.')
        .last
        .toLowerCase();

    final timestamp =
        DateTime.now().microsecondsSinceEpoch;

    final filePath =
        '${user.uid}/$listingId/'
        '${timestamp}_${DateTime.now().millisecond}.$extension';

    final bytes = await image.readAsBytes();

    await _client.storage
        .from(bucketName)
        .uploadBinary(
          filePath,
          bytes,
          fileOptions: FileOptions(
            contentType: _contentType(extension),
            upsert: false,
          ),
        );

    return _client.storage
        .from(bucketName)
        .getPublicUrl(filePath);
  }

  Future<List<String>> uploadImages({
    required List<XFile> images,
    required String listingId,
  }) async {
    final urls = <String>[];

    for (final image in images) {
      final url = await uploadImage(
        image: image,
        listingId: listingId,
      );
      urls.add(url);
    }

    return urls;
  }

  Future<void> deleteImage(String imageUrl) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw StateError('Sign in before deleting images.');
    }

    final uri = Uri.tryParse(imageUrl);
    if (uri == null) return;

    final marker = '/storage/v1/object/public/$bucketName/';
    final index = uri.path.indexOf(marker);

    if (index < 0) return;

    final path = Uri.decodeComponent(
      uri.path.substring(index + marker.length),
    );

    if (!path.startsWith('${user.uid}/')) {
      throw StateError('Cannot delete another user\'s image.');
    }

    await _client.storage
        .from(bucketName)
        .remove([path]);
  }
}
