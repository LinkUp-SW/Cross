import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/shared/themes/colors.dart';

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
  
  @override
  Widget build(BuildContext context) {
    final double height = widget.showSuggestions ? 100.h : 70.h;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        border: const BorderDirectional(
            top: BorderSide(color: AppColors.lightGrey, width: 0)),
      ),
      height: widget.focusNode.hasFocus ? height + 40.h : height,
      child: Padding(
        padding: EdgeInsets.all(10.r),
        child: Focus(
          onFocusChange: (hasFocus) {
            setState(() {});
          },
          child: Column(
            children: [
              if (widget.showSuggestions)
                Expanded(
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
                children: [
                  Flexible(
                    flex: 1,
                    child: CircleAvatar(
                      radius: 15.r,
                      //TODO: Replace with user profile image
                      backgroundImage: const NetworkImage(
                          'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__480.jpg'),
                    ),
                  ),
                  SizedBox(
                    width: 10.w,
                  ),
                  Flexible(
                    flex: 8,
                    child: TextField(
                      autofocus: widget.focused,
                      focusNode: widget.focusNode,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(10.r),
                        hintText: "leave your thoughts here...",
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: AppColors.lightGrey, width: 0),
                          borderRadius: BorderRadius.all(
                            Radius.circular(30.r),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(
                              color: AppColors.lightGrey, width: 0),
                          borderRadius: BorderRadius.all(
                            Radius.circular(20.r),
                          ),
                        ),
                      ),
                      controller: widget.textController,
                    ),
                  ),
                  SizedBox(
                    width: 10.h,
                  ),
                  if (!widget.focusNode.hasFocus)
                    GestureDetector(
                        onTap: () {}, child: const Icon(Icons.alternate_email))
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
                              onTap: () {}, child: const Icon(Icons.image)),
                          SizedBox(
                            width: 10.w,
                          ),
                          GestureDetector(
                              onTap: () {},
                              child: const Icon(Icons.alternate_email))
                        ],
                      ),
                      Wrap(
                        children: [
                          TextButton(
                            onPressed: () {
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
    );
  }
}
