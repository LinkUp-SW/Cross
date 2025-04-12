import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;


class TextPartStyleDefinition {
  TextPartStyleDefinition({
    required this.pattern,
    required this.style,
    this.replacement,
    this.preventPartialDeletion = false,
    this.onTap,
    this.onDetected,
    this.onDelete,
  });

  final String pattern;
  final TextStyle style;
  final String Function(String)? replacement;
  final bool preventPartialDeletion;
  final void Function(String)? onTap;
  final void Function(String)? onDetected;
  final void Function(String)? onDelete; // New callback for deletion
}

class TextPartStyleDefinitions {
  TextPartStyleDefinitions({required this.definitionList});

  final List<TextPartStyleDefinition> definitionList;

  RegExp createCombinedPatternBasedOnStyleMap() {
    final String combinedPatternString = definitionList
        .map<String>(
          (TextPartStyleDefinition textPartStyleDefinition) =>
              textPartStyleDefinition.pattern,
        )
        .join('|');

    return RegExp(
      combinedPatternString,
      multiLine: true,
      caseSensitive: false,
    );
  }

  TextPartStyleDefinition? getStyleOfTextPart(
    String textPart,
    String text,
  ) {
    return List<TextPartStyleDefinition?>.from(definitionList).firstWhere(
      (TextPartStyleDefinition? styleDefinition) {
        if (styleDefinition == null) return false;

        bool hasMatch = false;

        RegExp(styleDefinition.pattern, caseSensitive: false)
            .allMatches(text)
            .forEach(
          (RegExpMatch currentMatch) {
            if (hasMatch) return;

            if (currentMatch.group(0) == textPart) {
              hasMatch = true;
            }
          },
        );

        return hasMatch;
      },
      orElse: () => null,
    );
  }
}
/// Utility class providing predefined text styles for formatted text
class FormattingTextStyles {
  // Private constructor to prevent instantiation
  FormattingTextStyles._();

  static final List<TextPartStyleDefinition> _customStyles = [];

  /// Add a custom style to the list of available styles
  static void addCustomStyle(TextPartStyleDefinition style) {
    // Check if a style with the same pattern already exists
    final existingIndex = _customStyles.indexWhere(
      (s) => s.pattern == style.pattern,
    );
    
    if (existingIndex >= 0) {
      // Replace existing style
      _customStyles[existingIndex] = style;
    } else {
      // Add new style
      _customStyles.add(style);
    }
    
    log('Custom style added: ${style.pattern}');
  }

  static bool removeCustomStyle(String pattern) {
    final initialLength = _customStyles.length;
    _customStyles.removeWhere((s) => s.pattern == pattern);
    
    final removed = initialLength > _customStyles.length;
    if (removed) {
      log('Custom style removed: $pattern');
    }
    
    return removed;
  }

  /// Clear all custom styles
  static void clearCustomStyles() {
    _customStyles.clear();
    log('All custom styles cleared');
  }

  /// Get all text style definitions for formatted input and rich text
  static TextPartStyleDefinitions getAllStyles(BuildContext context) {
    return TextPartStyleDefinitions(
      definitionList: [
        // User mentions - @username:id^
        mentionStyle(context),

        // URLs - http/https links
        urlStyle(context),

        // Bold text - *bold text*
        boldStyle,

        // Italic text - ~italic text~
        italicStyle,

        // Underlined text - -underlined text-
        underlineStyle,
        ..._customStyles
      ],
    );
  }

  /// URL styling
  static TextPartStyleDefinition urlStyle(
    BuildContext context, {
    void Function(String url)? onTap,
    void Function(String url)? onDetected,
    void Function(String url)? onDelete,
  }) {
    return TextPartStyleDefinition(
      pattern:
          r'(https?:\/\/(?:www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b(?:[-a-zA-Z0-9()@:%_\+.~#?&\/=]*)) ',
      style: TextStyle(
        color: Theme.of(context).colorScheme.secondary,
        decoration: TextDecoration.underline,
      ),
      onTap: onTap ?? (url) async {
        url = url.trim();
        final isAccessible = await isAccessibleUrl(url);
        if (isAccessible) {
          launchUrl(Uri.parse(url), mode: LaunchMode.inAppBrowserView);
        } else {
          log('URL is not accessible: $url');
          // Show feedback in your app
        }
      },
      onDetected: onDetected ?? (p0) => log('URL detected: $p0'),
      onDelete: onDelete ?? (p0) => log('URL deleted: $p0'),
    );
  }

  /// User mention styling - @username:userId^
  static TextPartStyleDefinition mentionStyle(
    BuildContext context, {
    void Function(String mention)? onTap,
    void Function(String mention)? onDetected,
    void Function(String mention)? onDelete,
  }) {
    return TextPartStyleDefinition(
      pattern: r'@([^@^:]+):([^@^]+)\^',
      style: TextStyle(
        color: Theme.of(context).colorScheme.secondary,
        fontWeight: FontWeight.bold,
      ),
      preventPartialDeletion: true,
      replacement: (match) {
        // Extract username from the mention format
        final RegExp regex = RegExp(r'@([^@^:]+):([^@^]+)\^');
        final RegExpMatch? regMatch = regex.firstMatch(match);
        if (regMatch != null) {
          final String username = regMatch.group(1) ?? '';
          return username;
        }
        return match;
      },
      onTap: onTap ?? (mention) {
        // Extract user ID and handle navigation
        final RegExp regex = RegExp(r'@([^@^:]+):([^@^]+)\^');
        final RegExpMatch? regMatch = regex.firstMatch(mention);
        if (regMatch != null) {
          final String username = regMatch.group(1) ?? '';
          final String userId = regMatch.group(2) ?? '';
          log('User tapped: $username with ID: $userId');
          // Navigate to user profile
        }
      },
      onDetected: onDetected ?? (p0) => log('Mention detected: $p0'),
      onDelete: onDelete ?? (p0) => log('Mention deleted: $p0'),
    );
  }

  /// Bold text styling - *bold text*
  static final TextPartStyleDefinition boldStyle = TextPartStyleDefinition(
    pattern: r'\*([^*]+)\*',
    style: const TextStyle(
      fontWeight: FontWeight.bold,
    ),
    replacement: (match) {
      // Remove * markers and show only the content
      return match.substring(1, match.length - 1);
    },
    preventPartialDeletion: true,
  );

  /// Italic text styling - ~italic text~
  static final TextPartStyleDefinition italicStyle = TextPartStyleDefinition(
    pattern: r'~([^~]+)~',
    style: const TextStyle(
      fontStyle: FontStyle.italic,
    ),
    replacement: (match) {
      // Remove ~ markers and show only the content
      return match.substring(1, match.length - 1);
    },
    preventPartialDeletion: true,
  );

  /// Underlined text styling - -underlined text-
  static final TextPartStyleDefinition underlineStyle = TextPartStyleDefinition(
    pattern: r'-([^-]+)-',
    style: const TextStyle(
      decoration: TextDecoration.underline,
    ),
    replacement: (match) {
      // Remove - markers and show only the content
      return match.substring(1, match.length - 1);
    },
    preventPartialDeletion: true,
  );
}

// URL validation function
Future<bool> isAccessibleUrl(String url) async {
  try {
    final uri = Uri.parse(url);
    if (uri.scheme != 'http' && uri.scheme != 'https') {
      return false;
    }
    final response = await http.head(uri);
    return response.statusCode >= 200 && response.statusCode < 400;
  } catch (e) {
    log('Error checking URL accessibility: $e');
    return false;
  }
}