import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:url_launcher/url_launcher.dart';

class CommentsTextField extends StatefulWidget {
  final FocusNode focusNode;
  final TextEditingController textController;
  final bool focused;
  final String buttonName;
  final bool showSuggestions;
  const CommentsTextField(
      {super.key,
      required this.focusNode,
      required this.textController,
      required this.focused,
      required this.buttonName,
      this.showSuggestions = true});

  @override
  State<CommentsTextField> createState() => _CommentsTextFieldState();
}

class _CommentsTextFieldState extends State<CommentsTextField> {
  bool _showTags = false;
  XFile imagePath = XFile('');
  @override
  Widget build(BuildContext context) {
    final height = widget.showSuggestions ? 120.h : 70.h;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        border: const BorderDirectional(
            top: BorderSide(color: AppColors.lightGrey, width: 0)),
      ),
      height: widget.focusNode.hasFocus
          ? _showTags
              ? height + 245.h
              : height + 45.h
          : _showTags
              ? height + 210.h
              : height,
      child: Padding(
        padding: EdgeInsets.all(10.r),
        child: Focus(
          onFocusChange: (hasFocus) {
            setState(() {});
          },
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (_showTags) ...[
                        SizedBox(
                          height: 200.h,
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const ClampingScrollPhysics(),
                            itemCount: 10,
                            itemBuilder: (context, index) {
                              return ListTile(
                                leading: CircleAvatar(
                                  radius: 20.r,
                                  backgroundImage: const NetworkImage(
                                      'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__480.jpg'),
                                ),
                                title: Text("User $index"),
                                subtitle: Text("user $index",
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall!
                                        .copyWith(
                                          color: AppColors.grey,
                                        )),
                                onTap: () {
                                  widget.textController.text =
                                      widget.textController.text.replaceRange(
                                    widget.textController.text.lastIndexOf('@'),
                                    widget.textController.text.length,
                                    "User $index ",
                                  );
                                  widget.focusNode.requestFocus();
                                  setState(() {
                                    _showTags = false;
                                  });
                                },
                              );
                            },
                            separatorBuilder: (context, index) => const Divider(
                              color: AppColors.lightGrey,
                              height: 0,
                            ),
                          ),
                        ),
                        const Divider(
                          color: AppColors.lightGrey,
                          height: 0,
                        ),
                        SizedBox(
                          height: 10.h,
                        ),
                      ],
                      if (widget.showSuggestions)
                        SizedBox(
                          height: 50.h,
                          child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: 10,
                              shrinkWrap: true,
                              separatorBuilder: (context, index) =>
                                  SizedBox(width: 5.w),
                              itemBuilder: (context, index) {
                                return Chip(label: Text("label $index"));
                              }),
                        ),
                      SizedBox(
                        height: 10.h,
                      ),
                      Flex(
                        direction: Axis.horizontal,
                        spacing: 10.w,
                        children: [
                          Flexible(
                            flex: 1,
                            child: CircleAvatar(
                              radius: 20.r,
                              //TODO: Replace with user profile image
                              backgroundImage: const NetworkImage(
                                  'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__480.jpg'),
                            ),
                          ),
                          Flexible(
                            flex: 8,
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.r),
                                border: Border.all(
                                  color: AppColors.lightGrey,
                                ),
                              ),
                              child: SingleChildScrollView(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(10.r),
                                      child: Stack(
                                        children: [
                                          Linkify(
                                            text: widget.textController.text,
                                            style: TextStyle(
                                              fontSize: 15.r,
                                              letterSpacing: 0,
                                            ),
                                            options: const LinkifyOptions(
                                                humanize: false),
                                            onOpen: (link) async {
                                              if (!await launchUrl(
                                                  Uri.parse(link.url))) {
                                                throw Exception(
                                                    'Could not open the link');
                                              }
                                            },
                                          ),
                                          TextField(
                                            focusNode: widget.focusNode,
                                            controller: widget.textController,
                                            onChanged: (value) {
                                              setState(() {});
                                            },
                                            cursorColor: AppColors.lightBlue,
                                            maxLines: null,
                                            decoration: const InputDecoration(
                                              border: InputBorder.none,
                                              hintText:
                                                  'What are your thoughts?',
                                              isDense: true,
                                              isCollapsed: true,
                                            ),
                                            autofocus:
                                                widget.focusNode.hasFocus,
                                            style: TextStyle(
                                              decoration: TextDecoration.none,
                                              color: Colors.transparent,
                                              fontSize: 15.r,
                                              letterSpacing: 0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    if (imagePath.path != '')
                                      Padding(
                                        padding: EdgeInsets.all(
                                          10.r,
                                        ),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10.r),
                                          child: Stack(
                                            children: [
                                              Image.file(
                                                File(imagePath.path),
                                                fit: BoxFit.fitHeight,
                                                height: 120.h,
                                              ),
                                              Positioned(
                                                right: 0,
                                                child: IconButton(
                                                    style: IconButton.styleFrom(
                                                      backgroundColor: AppColors
                                                          .fineLinesGrey
                                                          .withValues(
                                                              alpha: 0.5),
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
                                                        imagePath = XFile('');
                                                      });
                                                    },
                                                    icon: const Icon(
                                                        Icons.close)),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (!widget.focusNode.hasFocus)
                            Flexible(
                                flex: 1,
                                child: widget.textController.text.isEmpty
                                    ? GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            _showTags = !_showTags;
                                          });
                                        },
                                        child:
                                            const Icon(Icons.alternate_email))
                                    : IconButton.filled(
                                        onPressed: () {
                                          //TODO: send message to backend
                                        },
                                        icon: Icon(
                                          Icons.arrow_upward,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .surface,
                                        ),
                                        style: IconButton.styleFrom(
                                          backgroundColor: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                        ),
                                      ))
                        ],
                      ),
                      if (widget.focusNode.hasFocus)
                        SizedBox(
                          height: 40.h,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  GestureDetector(
                                      onTap: () async {
                                        final ImagePicker picker =
                                            ImagePicker();
                                        final image = await picker.pickImage(
                                            source: ImageSource.gallery);
                                        setState(() {
                                          if (image != null) {
                                            imagePath = image;
                                          } else {
                                            throw Exception(
                                                'Could not add image');
                                          }
                                        });
                                      },
                                      child: const Icon(Icons.image)),
                                  SizedBox(
                                    width: 10.w,
                                  ),
                                  GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _showTags = !_showTags;
                                        });
                                      },
                                      child: const Icon(Icons.alternate_email))
                                ],
                              ),
                              Wrap(
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      //TODO: send message to backend
                                      widget.focusNode.unfocus();
                                    },
                                    child: Text(widget.buttonName),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
