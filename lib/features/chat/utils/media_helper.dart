import 'dart:io';
import 'dart:developer';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:video_compress/video_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class MediaHelper {
  // Size limits
  static const int MAX_IMAGE_SIZE = 2 * 1024 * 1024; // 2MB
  static const int MAX_VIDEO_SIZE = 8 * 1024 * 1024; // 8MB
  static const int MAX_DOC_SIZE = 5 * 1024 * 1024; // 5MB
  static const int ABSOLUTE_MAX_SIZE = 20 * 1024 * 1024; // 20MB hard limit

  /// Process any media file for upload
  static Future<String> prepareMediaForUpload(String filePath) async {
    final File file = File(filePath);
    if (!await file.exists()) {
      throw Exception('File does not exist: $filePath');
    }

    final fileSize = await file.length();
    final fileExt = path.extension(filePath).toLowerCase();
    log('Processing file: $filePath, size: ${(fileSize / 1024 / 1024).toStringAsFixed(2)}MB');

    // Check file type and process accordingly
    if (isImageFile(fileExt)) {
      return await _processImage(file, fileSize, fileExt);
    } else if (isVideoFile(fileExt)) {
      return await _processVideo(file, fileSize, fileExt);
    } else if (isDocumentFile(fileExt)) {
      return await _processDocument(file, fileSize, fileExt);
    } else {
      // Default handling for unsupported types
      if (fileSize > MAX_DOC_SIZE) {
        throw Exception(
            'File too large (${(fileSize / 1024 / 1024).toStringAsFixed(1)}MB). Maximum size is ${(MAX_DOC_SIZE / 1024 / 1024).toStringAsFixed(1)}MB.');
      }
      return fileToBase64(file);
    }
  }

  /// Helper methods for determining file types
  static bool isImageFile(String path) {
    final ext = path.toLowerCase();
    return ext.endsWith('.jpg') ||
        ext.endsWith('.jpeg') ||
        ext.endsWith('.png') ||
        ext.endsWith('.gif') ||
        ext.endsWith('.webp');
  }

  static bool isVideoFile(String path) {
    final ext = path.toLowerCase();
    return ext.endsWith('.mp4') || ext.endsWith('.mov') || ext.endsWith('.avi') || ext.endsWith('.mkv');
  }

  static bool isDocumentFile(String path) {
    final ext = path.toLowerCase();
    return ext.endsWith('.pdf') ||
        ext.endsWith('.doc') ||
        ext.endsWith('.docx') ||
        ext.endsWith('.txt') ||
        ext.endsWith('.xlsx');
  }

  /// Process document files
  static Future<String> _processDocument(File file, int fileSize, String fileExt) async {
    if (fileSize <= MAX_DOC_SIZE) {
      return fileToBase64(file);
    }

    throw Exception(
        'Document too large (${(fileSize / 1024 / 1024).toStringAsFixed(1)}MB). Maximum size is ${(MAX_DOC_SIZE / 1024 / 1024).toStringAsFixed(1)}MB.');
  }

  /// Convert file to base64 with proper mime type
  static Future<String> fileToBase64(File file) async {
    final bytes = await file.readAsBytes();
    final base64String = base64Encode(bytes);
    final fileExt = path.extension(file.path).toLowerCase();

    String mimeType = getMimeType(fileExt);
    return 'data:$mimeType;base64,$base64String';
  }

  /// Get MIME type for a file extension
  static String getMimeType(String fileExt) {
    switch (fileExt) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.webp':
        return 'image/webp';
      case '.mp4':
        return 'video/mp4';
      case '.mov':
        return 'video/quicktime';
      case '.avi':
        return 'video/x-msvideo';
      case '.pdf':
        return 'application/pdf';
      case '.doc':
      case '.docx':
        return 'application/msword';
      case '.xls':
      case '.xlsx':
        return 'application/vnd.ms-excel';
      case '.txt':
        return 'text/plain';
      default:
        return 'application/octet-stream';
    }
  }

  static Future<String> _processImage(File file, int fileSize, String fileExt) async {
    if (fileSize <= MAX_IMAGE_SIZE) {
      return _fileToBase64(file);
    }

    log('Compressing image: ${file.path}');
    try {
      // Read the file as bytes
      final Uint8List bytes = await file.readAsBytes();

      // Decode the image
      final img.Image? image = img.decodeImage(bytes);

      if (image == null) {
        log('Failed to decode image, using original file');
        return _fileToBase64(file);
      }

      // Resize if image is too large
      img.Image resized = image;
      if (image.width > 1200 || image.height > 1200) {
        resized = img.copyResize(
          image,
          width: image.width > image.height ? 1200 : (1200 * image.width ~/ image.height),
          height: image.height > image.width ? 1200 : (1200 * image.height ~/ image.width),
        );
      }

      // Determine quality based on file size
      int quality = 85;
      if (fileSize > 5 * 1024 * 1024) quality = 70;
      if (fileSize > 10 * 1024 * 1024) quality = 60;

      // Encode with quality
      Uint8List compressed;
      if (fileExt == '.png') {
        compressed = img.encodePng(resized);
      } else {
        compressed = img.encodeJpg(resized, quality: quality);
      }

      // Save to temporary file
      final targetPath = await _getTemporaryFilePath('compressed_${DateTime.now().millisecondsSinceEpoch}$fileExt');
      await File(targetPath).writeAsBytes(compressed);

      final compressedFile = File(targetPath);
      final compressedSize = await compressedFile.length();
      log('Image compressed from ${(fileSize / 1024 / 1024).toStringAsFixed(2)}MB to ${(compressedSize / 1024 / 1024).toStringAsFixed(2)}MB');

      // If still too large, try more aggressive compression
      if (compressedSize > MAX_IMAGE_SIZE) {
        // Try more aggressive compression
        final aggressiveTargetPath =
            await _getTemporaryFilePath('aggressive_${DateTime.now().millisecondsSinceEpoch}$fileExt');

        // For aggressive compression, reduce dimensions more and quality
        final smallerImage = img.copyResize(
          image,
          width: image.width > image.height ? 800 : (800 * image.width ~/ image.height),
          height: image.height > image.width ? 800 : (800 * image.height ~/ image.width),
        );

        Uint8List aggressiveCompressed;
        if (fileExt == '.png') {
          aggressiveCompressed = img.encodePng(smallerImage);
        } else {
          aggressiveCompressed = img.encodeJpg(smallerImage, quality: 40);
        }

        await File(aggressiveTargetPath).writeAsBytes(aggressiveCompressed);

        final aggressiveFile = File(aggressiveTargetPath);
        final aggressiveSize = await aggressiveFile.length();
        log('Image aggressively compressed to ${(aggressiveSize / 1024 / 1024).toStringAsFixed(2)}MB');

        return _fileToBase64(aggressiveFile);
      }

      return _fileToBase64(compressedFile);
    } catch (e) {
      log('Error compressing image: $e');
      // Fallback to original if compression fails
      return _fileToBase64(file);
    }
  }

  static Future<String> _processVideo(File file, int fileSize, String fileExt) async {
    if (fileSize <= MAX_VIDEO_SIZE) {
      return _fileToBase64(file);
    }

    // Check if exceeds absolute maximum
    if (fileSize > ABSOLUTE_MAX_SIZE) {
      log('Video exceeds absolute maximum size (${(fileSize / 1024 / 1024).toStringAsFixed(2)}MB)');
      throw Exception(
          'Video too large (${(fileSize / 1024 / 1024).toStringAsFixed(2)}MB). Maximum size is ${(ABSOLUTE_MAX_SIZE / 1024 / 1024).toStringAsFixed(2)}MB.');
    }

    log('Video is too large (${(fileSize / 1024 / 1024).toStringAsFixed(2)}MB), compressing...');
    try {
      // Try standard compression first
      final standardCompressionInfo = await VideoCompress.compressVideo(
        file.path,
        quality: VideoQuality.MediumQuality,
        includeAudio: true,
        deleteOrigin: false,
      );

      if (standardCompressionInfo?.path != null) {
        final compressedFile = File(standardCompressionInfo!.path!);
        final compressedSize = await compressedFile.length();
        log('Video compressed from ${(fileSize / 1024 / 1024).toStringAsFixed(2)}MB to ${(compressedSize / 1024 / 1024).toStringAsFixed(2)}MB');

        // If still too large, try aggressive compression
        if (compressedSize > MAX_VIDEO_SIZE) {
          log('Standard compression not sufficient, trying aggressive compression...');

          // Release resources from first compression
          await VideoCompress.cancelCompression();

          // Try more aggressive compression
          final aggressiveCompressionInfo = await VideoCompress.compressVideo(
            file.path,
            quality: VideoQuality.LowQuality, // Use low quality
            includeAudio: true,
            frameRate: 24, // Lower frame rate
            deleteOrigin: false,
          );

          if (aggressiveCompressionInfo?.path != null) {
            final aggressiveFile = File(aggressiveCompressionInfo!.path!);
            final aggressiveSize = await aggressiveFile.length();
            log('Video aggressively compressed to ${(aggressiveSize / 1024 / 1024).toStringAsFixed(2)}MB');

            if (aggressiveSize <= MAX_VIDEO_SIZE) {
              return _fileToBase64(aggressiveFile);
            } else {
              log('Video still too large after aggressive compression');

              // As a last resort, create a video thumbnail and send that
              log('Creating video thumbnail as fallback');
              final thumbnailFile = await VideoCompress.getFileThumbnail(
                file.path,
                quality: 50,
                position: -1, // Default position
              );

              log('Generated video thumbnail instead');
              return 'data:image/jpeg;base64,thumbnail_' + base64Encode(await thumbnailFile.readAsBytes());
            }
          }
        }

        return _fileToBase64(compressedFile);
      } else {
        log('Video compression failed or was canceled');
        throw Exception('Could not compress video');
      }
    } catch (e) {
      log('Error compressing video: $e');
      throw Exception('Error processing video: $e');
    }
  }

  static Future<String> _getTemporaryFilePath(String fileName) async {
    final tempDir = await getTemporaryDirectory();
    return '${tempDir.path}/$fileName';
  }

  static Future<String> _fileToBase64(File file) async {
    final bytes = await file.readAsBytes();
    final base64String = base64Encode(bytes);

    // Determine mime type
    String mimeType;
    final fileExt = path.extension(file.path).toLowerCase();

    if (fileExt == '.jpg' || fileExt == '.jpeg') {
      mimeType = 'image/jpeg';
    } else if (fileExt == '.png') {
      mimeType = 'image/png';
    } else if (fileExt == '.webp') {
      mimeType = 'image/webp';
    } else if (fileExt == '.mp4') {
      mimeType = 'video/mp4';
    } else if (fileExt == '.mov') {
      mimeType = 'video/quicktime';
    } else if (fileExt == '.pdf') {
      mimeType = 'application/pdf';
    } else if (fileExt == '.doc' || fileExt == '.docx') {
      mimeType = 'application/msword';
    } else {
      mimeType = 'application/octet-stream';
    }

    return 'data:$mimeType;base64,$base64String';
  }
}
