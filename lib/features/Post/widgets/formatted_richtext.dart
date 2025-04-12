
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:link_up/features/Post/widgets/formatting_styles.dart';



class FormattedRichText extends StatefulWidget {
  final String text;
  final TextStyle? defaultStyle;
  final TextAlign textAlign;
  final TextOverflow overflow;
  final int? maxLines;
  final bool enableReadMore;
  final int readMoreThreshold;
  final String readMoreText;
  final String readLessText;
  final TextStyle? readMoreStyle;

  const FormattedRichText({
    super.key,
    required this.text,
    this.defaultStyle,
    this.textAlign = TextAlign.start,
    this.overflow = TextOverflow.clip,
    this.maxLines,
    this.enableReadMore = false,
    this.readMoreThreshold = 3,
    this.readMoreText = 'Read more',
    this.readLessText = 'Read less',
    this.readMoreStyle,
  });

  @override
  State<FormattedRichText> createState() => _FormattedRichTextState();
}

class _FormattedRichTextState extends State<FormattedRichText> {
  bool _isExpanded = false;
  bool _hasTextOverflow = false;
  late TextSpan _textSpan;
  late TextPartStyleDefinitions _styleDefinitions;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize style definitions
    _styleDefinitions = FormattingTextStyles.getAllStyles(context);
    // Update text span when dependencies change
    _updateTextSpan();
  }

  @override
  void didUpdateWidget(FormattedRichText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text ||
        oldWidget.defaultStyle != widget.defaultStyle) {
      _updateTextSpan();
    }
  }

  void _updateTextSpan() {
    final baseStyle =
        widget.defaultStyle ?? Theme.of(context).textTheme.bodyMedium;
    _textSpan = buildFormattedTextSpan(
      context: context,
      text: widget.text,
      baseStyle: baseStyle,
    );

    if (widget.enableReadMore) {
      _checkTextOverflow();
    }
  }

  void _checkTextOverflow() {
    if (!mounted) return;

    final TextPainter textPainter = TextPainter(
      text: _textSpan,
      textDirection: TextDirection.ltr,
      maxLines: widget.readMoreThreshold,
      textAlign: widget.textAlign,
    );

    final double maxWidth = MediaQuery.of(context).size.width;
    textPainter.layout(maxWidth: maxWidth);

    _hasTextOverflow = textPainter.didExceedMaxLines;
  }

  @override
  Widget build(BuildContext context) {
    final bool shouldTruncate = widget.enableReadMore && !_isExpanded;
    final int? effectiveMaxLines =
        shouldTruncate ? widget.readMoreThreshold : widget.maxLines;

    return LayoutBuilder(builder: (context, constraints) {
      if (widget.enableReadMore && constraints.maxWidth > 0) {
        final TextPainter textPainter = TextPainter(
          text: _textSpan,
          textDirection: TextDirection.ltr,
          maxLines: widget.readMoreThreshold,
          textAlign: widget.textAlign,
        );
        textPainter.layout(maxWidth: constraints.maxWidth);
        _hasTextOverflow = textPainter.didExceedMaxLines;
      }

      return Stack(
        children: [
          // Text content
          Flex(
            direction: Axis.horizontal,
            children: [
              Flexible(
                flex: 9,
                child: RichText(
                  text: _textSpan,
                  textAlign: widget.textAlign,
                  overflow: widget.overflow,
                  maxLines: effectiveMaxLines,
                ),
              ),
              Flexible(
                flex: 2,
                child: SizedBox(),
              ),
            ],
          ),

          // Read more/less button if enabled and text overflows
          if (widget.enableReadMore && (_hasTextOverflow || _isExpanded))
            Positioned(
              bottom: 0,
              right: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _isExpanded = !_isExpanded;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        _isExpanded ? widget.readLessText : widget.readMoreText,
                        style: widget.readMoreStyle ??
                            TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      );
    });
  }

  TextSpan buildFormattedTextSpan({
    required BuildContext context,
    required String text,
    required TextStyle? baseStyle,
  }) {
    final List<InlineSpan> textSpanChildren = <InlineSpan>[];
    final RegExp combinedPattern =
        _styleDefinitions.createCombinedPatternBasedOnStyleMap();

    text.splitMapJoin(
      combinedPattern,
      onMatch: (Match match) {
        final String? textPart = match.group(0);

        if (textPart == null) return '';

        final TextPartStyleDefinition? styleDefinition =
            _styleDefinitions.getStyleOfTextPart(textPart, text);

        if (styleDefinition == null) return '';

        // Apply text replacement if provided
        String displayText = textPart;
        if (styleDefinition.replacement != null) {
          displayText = styleDefinition.replacement!(textPart);
        }

        _addTextSpan(
          textSpanChildren,
          displayText,
          baseStyle?.merge(styleDefinition.style),
          styleDefinition.onTap != null
              ? () => styleDefinition.onTap!(textPart)
              : null,
        );

        return '';
      },
      onNonMatch: (String text) {
        _addTextSpan(textSpanChildren, text, baseStyle, null);
        return '';
      },
    );

    return TextSpan(style: baseStyle, children: textSpanChildren);
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
