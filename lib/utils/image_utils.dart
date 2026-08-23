import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class ImageUtils {
  ImageUtils._(); // Private constructor to prevent instantiation

  /// Picks an image from the specified [source] (defaults to Gallery).
  static Future<File?> pickImage({
    ImageSource source = ImageSource.gallery,
  }) async {
    try {
      final pickedFile = await ImagePicker().pickImage(source: source);
      if (pickedFile == null) return null;
      return File(pickedFile.path);
    } catch (e) {
      debugPrint('Error picking image: $e');
      return null;
    }
  }

  /// Resizes an image [File] to target dimensions [targetWidth] x [targetHeight]
  /// using high-quality Canvas rendering and saves it to a temp directory.
  static Future<File?> resizeImageFile({
    required File imageFile,
    required int targetWidth,
    required int targetHeight,
    String fileNamePrefix = 'resized_banner',
  }) async {
    try {
      final rawBytes = await imageFile.readAsBytes();
      final img = await decodeImageFromList(rawBytes);

      final ui.Image resizedImage =
          await _resizeImageCanvas(img, targetWidth, targetHeight);

      final byteData =
          await resizedImage.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;

      final tempDir = await getTemporaryDirectory();
      final tempFile = File(
        '${tempDir.path}/${fileNamePrefix}_${DateTime.now().millisecondsSinceEpoch}.png',
      );

      await tempFile.writeAsBytes(
        byteData.buffer.asUint8List(
          byteData.offsetInBytes,
          byteData.lengthInBytes,
        ),
      );

      return tempFile;
    } catch (e) {
      debugPrint('Error resizing image: $e');
      return null;
    }
  }

  /// Helper pipeline: Picks an image and resizes it in a single step.
  static Future<File?> pickAndResizeImage({
    ImageSource source = ImageSource.gallery,
    required int targetWidth,
    required int targetHeight,
  }) async {
    final pickedFile = await pickImage(source: source);
    if (pickedFile == null) return null;

    return await resizeImageFile(
      imageFile: pickedFile,
      targetWidth: targetWidth,
      targetHeight: targetHeight,
    );
  }

  /// Internal canvas drawing helper for hardware-accelerated image scaling.
  static Future<ui.Image> _resizeImageCanvas(
    ui.Image image,
    int targetWidth,
    int targetHeight,
  ) async {
    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Rect.fromLTWH(0, 0, targetWidth.toDouble(), targetHeight.toDouble()),
      Paint()..filterQuality = FilterQuality.high,
    );

    final picture = pictureRecorder.endRecording();
    return picture.toImage(targetWidth, targetHeight);
  }
}
