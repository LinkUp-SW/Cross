import 'dart:async';
import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:linkify/linkify.dart';
import 'package:link_up/features/Home/home_enums.dart';
import 'package:link_up/features/Home/model/media_model.dart';
import 'package:url_launcher/url_launcher.dart';

class LinkifyData {
  static TextSpan convertToTextSpan(
    String text, {
    required TextStyle textStyle,
    required TextStyle linkStyle,
    Function(String)? onLinkTap,
  }) {
    final List<LinkifyElement> elements = linkify(
      text,
      options: const LinkifyOptions(humanize: false),
    );
    
    List<InlineSpan> spans = [];
    
    for (var element in elements) {
      if (element is LinkableElement) {
        spans.add(
          TextSpan(
            text: element.text,
            style: linkStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                if (onLinkTap != null) {
                  onLinkTap(element.url);
                }
              },
          ),
        );
      } else {
        // Process markdown-like formatting
        String plainText = element.text;
        int currentPosition = 0;
        
        // Process text for formatting
        while (currentPosition < plainText.length) {
          
          // Check for bold text (*text*)
          if (currentPosition + 1 < plainText.length && 
              plainText[currentPosition] == '*') {
            int endBold = plainText.indexOf('*', currentPosition + 1);
            if (endBold != -1) {
              // Add text before bold
              if (currentPosition > 0) {
                spans.add(TextSpan(
                  text: plainText.substring(0, currentPosition),
                  style: textStyle,
                ));
              }
              
              // Add bold text
              spans.add(TextSpan(
                text: plainText.substring(currentPosition + 1, endBold),
                style: textStyle.copyWith(fontWeight: FontWeight.bold),
              ));
              
              // Update remaining text and position
              plainText = plainText.substring(endBold + 1);
              currentPosition = 0;
              continue;
            }
          }
          
          // Check for italic text (~text~)
          if (currentPosition + 1 < plainText.length && 
              plainText[currentPosition] == '~') {
            int endItalic = plainText.indexOf('~', currentPosition + 1);
            if (endItalic != -1) {
              // Add text before italic
              if (currentPosition > 0) {
                spans.add(TextSpan(
                  text: plainText.substring(0, currentPosition),
                  style: textStyle,
                ));
              }
              
              // Add italic text
              spans.add(TextSpan(
                text: plainText.substring(currentPosition + 1, endItalic),
                style: textStyle.copyWith(fontStyle: FontStyle.italic),
              ));
              
              // Update remaining text and position
              plainText = plainText.substring(endItalic + 1);
              currentPosition = 0;
              continue;
            }
          }
          
          // Check for underlined text (_text_)
          if (currentPosition + 1 < plainText.length && 
              plainText[currentPosition] == '_') {
            int endUnderline = plainText.indexOf('_', currentPosition + 1);
            if (endUnderline != -1) {
              // Add text before underline
              if (currentPosition > 0) {
                spans.add(TextSpan(
                  text: plainText.substring(0, currentPosition),
                  style: textStyle,
                ));
              }
              
              // Add underlined text
              spans.add(TextSpan(
                text: plainText.substring(currentPosition + 1, endUnderline),
                style: textStyle.copyWith(decoration: TextDecoration.underline),
              ));
              
              // Update remaining text and position
              plainText = plainText.substring(endUnderline + 1);
              currentPosition = 0;
              continue;
            }
          }
          currentPosition++;
        }
        
        // Add any remaining text
        if (plainText.isNotEmpty) {
          spans.add(TextSpan(
            text: plainText,
            style: textStyle,
          ));
        }
      }
    }
    
    return TextSpan(children: spans);
  }
}

class FormattedInput extends ConsumerStatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(bool) onTagsVisibilityChanged;
  final Function(Media) onMediaChanged;
  final MediaType mediaType;

  const FormattedInput({
    super.key,
    required this.mediaType,
    required this.controller,
    required this.focusNode,
    required this.onTagsVisibilityChanged,
    required this.onMediaChanged,
  });

  @override
  ConsumerState<FormattedInput> createState() => _TextFormattingInputState();
}

class _TextFormattingInputState extends ConsumerState<FormattedInput> {
  Timer? _debounce;

  void checkForLinks(String text) {
    final elements = linkify(text);

    for (var element in elements) {
      if (element is LinkableElement) {
        // A link was found
        log('Found link: ${element.url}');

        // Validate the URL before setting it as media
        try {
          final uri = Uri.parse(element.url);
          if (uri.hasScheme && uri.host.isNotEmpty) {
            // Valid URL, set it as media
            widget.onMediaChanged(Media(
              type: MediaType.link, 
              urls: [element.url]
            ));

            log('Valid link added: ${element.url}');
            break; // If you only care about the first link
          } else {
            log('Invalid link format: ${element.url}');
          }
        } catch (e) {
          log('Error parsing URL: ${e.toString()}');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {

    return Padding(
      padding: EdgeInsets.all(10.r),
      child: Stack(
        children: [
          Theme(
            data: Theme.of(context).copyWith(
              textSelectionTheme: TextSelectionThemeData(
                selectionColor: Colors.transparent,
                cursorColor: Colors.transparent,
                selectionHandleColor: Colors.transparent,
              ),
            ),
            child: TextField(
              focusNode: widget.focusNode,
              controller: widget.controller,
              onChanged: (value) {
                if (_debounce?.isActive ?? false) {
                  _debounce!.cancel();
                }
                _debounce = Timer(const Duration(seconds: 1), () {
                  if (widget.mediaType == MediaType.none) {
                    checkForLinks(value);
                  }
                  if (value.contains('@')) {
                    widget.onTagsVisibilityChanged(true);
                  } else {
                    widget.onTagsVisibilityChanged(false);
                  }
                });

                setState(() {});
              },
              cursorColor: Colors.transparent,
              cursorWidth: 0,
              maxLines: null,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'What are your thoughts?',
                isDense: true,
                isCollapsed: true,
              ),
              autofocus: true,
              style: TextStyle(
                decoration: TextDecoration.none,
                color: Colors.transparent,
                fontSize: 15.r,
                letterSpacing: 0,
              ),
            ),
          ),
          SelectableText.rich(
            LinkifyData.convertToTextSpan(
              widget.controller.text,
              textStyle: TextStyle(
                fontSize: 15.r,
                letterSpacing: 0,
                color: Theme.of(context).textTheme.bodyLarge!.color,
              ),
              linkStyle: TextStyle(
                fontSize: 15.r,
                letterSpacing: 0,
                color: Theme.of(context).colorScheme.secondary,
                decoration: TextDecoration.underline,
              ),
              onLinkTap: (url) async {
                if (!await launchUrl(Uri.parse(url))) {
                  throw Exception('Could not open the link');
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}