import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;

class DocumentHandler {
  // Size limits
  static const int MAX_PDF_SIZE = 1 * 1024 * 1024; // 1MB for PDFs
  static const int MAX_OTHER_DOC_SIZE = 2 * 1024 * 1024; // 2MB for other docs
  static const int ABSOLUTE_MAX_SIZE = 5 * 1024 * 1024; // 5MB hard limit

  /// Validates a document and returns whether it's suitable for upload
  static Future<Map<String, dynamic>> validateDocument(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      return {'isValid': false, 'errorMessage': 'Document not found'};
    }

    final fileSize = await file.length();
    final fileName = path.basename(filePath);
    final fileExt = path.extension(filePath).toLowerCase();
    final isPdf = fileExt == '.pdf';

    // Check if document exceeds absolute maximum size
    if (fileSize > ABSOLUTE_MAX_SIZE) {
      return {
        'isValid': false,
        'errorMessage': 'Document too large (${(fileSize / 1024 / 1024).toStringAsFixed(1)}MB). ' +
            'Maximum size is ${(ABSOLUTE_MAX_SIZE / 1024 / 1024).toStringAsFixed(1)}MB.'
      };
    }

    // For files that are large but under the absolute max, we'll attempt compression
    final maxAllowedSize = isPdf ? MAX_PDF_SIZE : MAX_OTHER_DOC_SIZE;
    final needsCompression = fileSize > maxAllowedSize;

    // Validate PDF signature if it's a PDF
    if (isPdf) {
      try {
        final bytes = await file.readAsBytes();
        // Check for PDF signature at beginning of file
        if (bytes.length < 5 ||
            bytes[0] != 0x25 || // %
            bytes[1] != 0x50 || // P
            bytes[2] != 0x44 || // D
            bytes[3] != 0x46 || // F
            bytes[4] != 0x2D) {
          // -
          return {'isValid': false, 'errorMessage': 'Invalid PDF format'};
        }
      } catch (e) {
        return {'isValid': false, 'errorMessage': 'Error validating PDF: $e'};
      }
    }

    // Document passed validation, include compression flag
    return {
      'isValid': true,
      'fileSize': fileSize,
      'fileName': fileName,
      'fileType': isPdf ? 'pdf' : 'document',
      'needsCompression': needsCompression,
      'fileExt': fileExt,
    };
  }

  /// Process document for sending - automatically compress if too large
  static Future<String> processDocument(String filePath) async {
    final validation = await validateDocument(filePath);
    if (!validation['isValid']) {
      throw Exception(validation['errorMessage']);
    }

    final fileSize = validation['fileSize'];
    final fileExt = validation['fileExt'];

    // For PDFs, enforce size limit without compression
    if (validation['fileType'] == 'pdf') {
      log('[DOC] Processing PDF: ${validation['fileName']}');
      return await documentToBase64(filePath);
    }

    // For images that need compression
    if (['.jpg', '.jpeg', '.png'].contains(fileExt) && validation['needsCompression']) {
      log('[DOC] Image document needs compression: ${(fileSize / 1024 / 1024).toStringAsFixed(2)}MB');

      try {
        final compressedPath = await _compressImage(filePath);
        final compressedFile = File(compressedPath);

        if (await compressedFile.exists()) {
          final compressedSize = await compressedFile.length();
          log('[DOC] Compressed from ${(fileSize / 1024 / 1024).toStringAsFixed(2)}MB to ${(compressedSize / 1024 / 1024).toStringAsFixed(2)}MB');

          return await documentToBase64(compressedPath);
        }
      } catch (e) {
        log('[DOC] Error compressing image: $e');

        // Try fallback compression method
        try {
          final fallbackPath = await compressImage(filePath);
          return await documentToBase64(fallbackPath);
        } catch (e2) {
          log('[DOC] Fallback compression also failed: $e2');
        }
      }
    }

    // If no compression was needed or compression failed
    return await documentToBase64(filePath);
  }

  /// Compress image document using the image package instead of flutter_image_compress
  static Future<String> _compressImage(String filePath) async {
    try {
      final File file = File(filePath);
      if (!await file.exists()) {
        log('[DOC] File does not exist: $filePath');
        return filePath;
      }

      final Uint8List bytes = await file.readAsBytes();
      final img.Image? image = img.decodeImage(bytes);

      if (image == null) {
        log('[DOC] Failed to decode image: $filePath');
        return filePath;
      }

      // Resize if image is too large
      img.Image resized = image;
      if (image.width > 1200 || image.height > 1200) {
        int newWidth = image.width;
        int newHeight = image.height;

        if (image.width > image.height) {
          newWidth = 1200;
          newHeight = (1200 * image.height ~/ image.width);
        } else {
          newHeight = 1200;
          newWidth = (1200 * image.width ~/ image.height);
        }

        // Ensure dimensions are valid
        newWidth = newWidth <= 0 ? 1 : newWidth;
        newHeight = newHeight <= 0 ? 1 : newHeight;

        resized = img.copyResize(
          image,
          width: newWidth,
          height: newHeight,
        );
      }

      // Determine quality based on file size
      int quality = 85;
      final fileSize = await file.length();
      if (fileSize > 2 * 1024 * 1024) quality = 70;
      if (fileSize > 4 * 1024 * 1024) quality = 50;

      // Encode with quality
      final Uint8List compressed = img.encodeJpg(resized, quality: quality);

      // Save to temporary file
      final tempDir = await getTemporaryDirectory();
      final outputPath =
          '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}${path.extension(filePath)}';
      await File(outputPath).writeAsBytes(compressed);

      return outputPath;
    } catch (e) {
      log('[DOC] Error compressing image with internal method: $e');
      return filePath;
    }
  }

  /// Simple PDF validation without compression
  static Future<bool> isPdfValid(String filePath) async {
    final file = File(filePath);

    if (!await file.exists()) {
      return false;
    }

    try {
      // This approach can fail - let's use a more reliable method
      final randomAccess = await file.open();
      List<int> signature = [];

      try {
        // Read first 5 bytes safely
        if (await randomAccess.length() >= 5) {
          await randomAccess.setPosition(0);
          signature = await randomAccess.read(5);
        } else {
          return false;
        }
      } finally {
        await randomAccess.close();
      }

      if (signature.length < 5 ||
          signature[0] != 0x25 || // %
          signature[1] != 0x50 || // P
          signature[2] != 0x44 || // D
          signature[3] != 0x46 || // F
          signature[4] != 0x2D) {
        // -
        return false;
      }

      return true;
    } catch (e) {
      log('[DOC] Error validating PDF signature: $e');
      return false;
    }
  }

  /// Converts a document to base64 with proper mime type
  static Future<String> documentToBase64(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('File does not exist');
    }

    // Check if file is accessible and not empty
    try {
      final fileSize = await file.length();
      if (fileSize == 0) {
        throw Exception('File is empty');
      }

      if (fileSize > ABSOLUTE_MAX_SIZE) {
        throw Exception(
            'File exceeds maximum allowed size of ${(ABSOLUTE_MAX_SIZE / 1024 / 1024).toStringAsFixed(1)}MB');
      }

      final bytes = await file.readAsBytes();
      final base64Data = base64Encode(bytes);
      final fileExt = path.extension(filePath).toLowerCase();

      String mimeType;
      switch (fileExt) {
        case '.pdf':
          mimeType = 'application/pdf';
          break;
        case '.doc':
        case '.docx':
          mimeType = 'application/msword';
          break;
        case '.xls':
        case '.xlsx':
          mimeType = 'application/vnd.ms-excel';
          break;
        case '.txt':
          mimeType = 'text/plain';
          break;
        case '.png':
          mimeType = 'image/png';
          break;
        case '.jpg':
        case '.jpeg':
          mimeType = 'image/jpeg';
          break;
        default:
          mimeType = 'application/octet-stream';
      }

      return 'data:$mimeType;base64,$base64Data';
    } catch (e) {
      log('Error converting document to base64: $e');
      throw Exception('Error processing document: $e');
    }
  }
}

Future<String> compressImage(String filePath, {int quality = 85}) async {
  final File file = File(filePath);
  final Uint8List bytes = await file.readAsBytes();
  final img.Image? image = img.decodeImage(bytes);

  if (image == null) return filePath;

  // Resize if image is too large
  img.Image resized = image;
  if (image.width > 1200 || image.height > 1200) {
    resized = img.copyResize(
      image,
      width: image.width > image.height ? 1200 : (1200 * image.width ~/ image.height),
      height: image.height > image.width ? 1200 : (1200 * image.height ~/ image.width),
    );
  }

  // Encode with quality
  final Uint8List compressed = img.encodeJpg(resized, quality: quality);

  // Save to temporary file
  final tempDir = await getTemporaryDirectory();
  final outputPath = '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
  await File(outputPath).writeAsBytes(compressed);

  return outputPath;
}
