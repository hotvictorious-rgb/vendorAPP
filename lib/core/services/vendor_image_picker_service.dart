import 'dart:io';
import 'package:image_picker/image_picker.dart';

/// Sovereign Merchant Image Picker Service
/// Provides camera capture and gallery selection with automatic 1280px / 75% WebP-ready
/// compression tailored for cellular networks across Akwa Ibom and Nigeria.
class VendorImagePickerService {
  static final ImagePicker _picker = ImagePicker();

  /// Captures a live picture directly from the device camera.
  static Future<File?> pickFromCamera({int maxWidth = 1280, int maxHeight = 1280, int quality = 75}) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: quality,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
      );
      return file != null ? File(file.path) : null;
    } catch (_) {
      return null;
    }
  }

  /// Selects an image from the device gallery.
  static Future<File?> pickFromGallery({int maxWidth = 1280, int maxHeight = 1280, int quality = 75}) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: quality,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
      );
      return file != null ? File(file.path) : null;
    } catch (_) {
      return null;
    }
  }

  /// Selects multiple images from the device gallery.
  static Future<List<File>> pickMultiImage({int maxWidth = 1280, int maxHeight = 1280, int quality = 75}) async {
    try {
      final List<XFile> files = await _picker.pickMultiImage(
        imageQuality: quality,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
      );
      return files.map((f) => File(f.path)).toList();
    } catch (_) {
      return [];
    }
  }
}