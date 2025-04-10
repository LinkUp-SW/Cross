
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/features/Post/widgets/formatting_styles.dart';

class FormattedInput extends StatelessWidget {
  const FormattedInput({super.key,
    required this.focusNode,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.r),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: (value) {
          onChanged(value);
        },
        autocorrect: false,
        enableSuggestions: false,
        maxLines: null,
        decoration: const InputDecoration(
          border: InputBorder.none,
          hintText: 'What are your thoughts?',
          isDense: true,
          isCollapsed: true,
        ),
        autofocus: true,
        cursorColor: Theme.of(context).colorScheme.secondary,
        textCapitalization: TextCapitalization.none,
      ),
    );
  }
}
//

//

//

//
class StyleableTextFieldController extends TextEditingController {
  StyleableTextFieldController({
    required this.styles,
  }) : combinedPattern = styles.createCombinedPatternBasedOnStyleMap() {
    // Add listener to detect patterns whenever text changes
    addListener(_checkForPatterns);
  }

  final TextPartStyleDefinitions styles;
  final Pattern combinedPattern;
  TextEditingValue? _lastKnownValue;
  final Set<String> _detectedPatterns = <String>{};

  // Method to check for new patterns
  void _checkForPatterns() {
    if (text.isEmpty) {
      _detectedPatterns.clear();
      return;
    }

    for (final definition in styles.definitionList) {
      if (definition.onDetected == null) continue;

      final RegExp regExp = RegExp(definition.pattern, caseSensitive: false);
      for (final match in regExp.allMatches(text)) {
        final String matched = match.group(0) ?? '';

        // If we haven't seen this exact pattern match before, call onDetected
        if (matched.isNotEmpty && !_detectedPatterns.contains(matched)) {
          _detectedPatterns.add(matched);
          definition.onDetected!(matched);
        }
      }
    }

    // Clean up patterns that no longer exist in the text
    final Set<String> currentPatterns = <String>{};
    for (final definition in styles.definitionList) {
      final RegExp regExp = RegExp(definition.pattern, caseSensitive: false);
      for (final match in regExp.allMatches(text)) {
        final String matched = match.group(0) ?? '';
        if (matched.isNotEmpty) {
          currentPatterns.add(matched);
        }
      }
    }

    // Remove patterns that no longer exist in the text
    _detectedPatterns
        .removeWhere((element) => !currentPatterns.contains(element));
  }

  @override
  void dispose() {
    removeListener(_checkForPatterns);
    super.dispose();
  }

  @override
  set value(TextEditingValue newValue) {
    // Check if text is being deleted (text is shorter than before)
    if (_lastKnownValue != null &&
        newValue.text.length < _lastKnownValue!.text.length) {
      // Get the removed text
      final String previousText = _lastKnownValue!.text;
      final String currentText = newValue.text;

      // Find deletion range
      int startIndex = 0;
      while (startIndex < currentText.length &&
          startIndex < previousText.length &&
          currentText[startIndex] == previousText[startIndex]) {
        startIndex++;
      }

      int endDiff = 0;
      while (endDiff < currentText.length &&
          endDiff < previousText.length &&
          currentText[currentText.length - 1 - endDiff] ==
              previousText[previousText.length - 1 - endDiff]) {
        endDiff++;
      }

      // Calculate deletion points
      final int deletionStart = startIndex;
      final int deletionEnd = previousText.length - endDiff;

      // Check if deletion affects a styled pattern
      bool affectsPattern = false;
      Match? affectedMatch;
      String? patternToRemove;
      TextPartStyleDefinition? affectedDefinition;

      for (final definition in styles.definitionList) {
        // Skip definitions that don't prevent partial deletion
        if (!definition.preventPartialDeletion) continue;

        final RegExp regExp = RegExp(definition.pattern, caseSensitive: false);
        for (final match in regExp.allMatches(previousText)) {
          final int matchStart = match.start;
          final int matchEnd = match.end;

          // Check if deletion overlaps with this match but doesn't remove it completely
          if ((deletionStart <= matchEnd && deletionEnd >= matchStart) &&
              !(deletionStart <= matchStart && deletionEnd >= matchEnd)) {
            affectsPattern = true;
            affectedMatch = match;
            patternToRemove = match.group(0);
            affectedDefinition = definition;
            break;
          }
        }
        if (affectsPattern) break;
      }

      // If deleting part of a styled pattern, remove the whole pattern
      if (affectsPattern &&
          patternToRemove != null &&
          affectedMatch != null &&
          affectedDefinition != null &&
          affectedDefinition.preventPartialDeletion) {
        final int matchStart = affectedMatch.start;
        final int matchEnd = affectedMatch.end;

        // Create a new TextEditingValue that removes the entire pattern
        final String newText = previousText.substring(0, matchStart) +
            previousText.substring(matchEnd);

        // Call onDelete callback if provided
        if (affectedDefinition.onDelete != null) {
          affectedDefinition.onDelete!(patternToRemove);
        }

        // Adjust selection to maintain cursor position
        int newCursorPos;
        if (deletionStart <= matchStart) {
          // If deleting from before or at the pattern start
          newCursorPos = matchStart;
        } else {
          // If deleting from inside the pattern
          // Calculate how much of the pattern was deleted
          final int patternDeletedPortion = deletionEnd - deletionStart;
          // Calculate how much of the pattern is after the cursor
          final int remainingPatternPortion = matchEnd - deletionStart;

          // Adjust cursor position
          newCursorPos = newValue.selection.baseOffset -
              (remainingPatternPortion - patternDeletedPortion);
        }

        // Ensure cursor position is valid
        newCursorPos = newCursorPos.clamp(0, newText.length);

        final newSelection = TextSelection.collapsed(offset: newCursorPos);

        // Update with the modified value instead
        super.value = TextEditingValue(
          text: newText,
          selection: newSelection,
        );
        _lastKnownValue = value;
        return;
      }
    }

    // Normal update for cases that don't trigger pattern removal
    super.value = newValue;
    _lastKnownValue = newValue;
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final List<InlineSpan> textSpanChildren = <InlineSpan>[];

    text.splitMapJoin(
      combinedPattern,
      onMatch: (Match match) {
        final String? textPart = match.group(0);

        if (textPart == null) return '';

        final TextPartStyleDefinition? styleDefinition =
            styles.getStyleOfTextPart(
          textPart,
          text,
        );

        if (styleDefinition == null) return '';

        // Apply text replacement if provided
        String displayText = textPart;
        if (styleDefinition.replacement != null) {
          displayText = styleDefinition.replacement!(textPart);
        }

        _addTextSpan(
          textSpanChildren,
          displayText,
          style?.merge(styleDefinition.style),
          styleDefinition.onTap != null
              ? () => styleDefinition.onTap!(textPart)
              : null,
        );

        return '';
      },
      onNonMatch: (String text) {
        _addTextSpan(textSpanChildren, text, style, null);

        return '';
      },
    );

    return TextSpan(style: style, children: textSpanChildren);
  }

  void _addTextSpan(
    List<InlineSpan> textSpanChildren,
    String? textToBeStyled,
    TextStyle? style,
    VoidCallback? onTap,
  ) {
    textSpanChildren.add(
      TextSpan(
        text: textToBeStyled,
        style: style,
        recognizer:
            onTap != null ? (TapGestureRecognizer()..onTap = onTap) : null,
      ),
    );
  }
}
