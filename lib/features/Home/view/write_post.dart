import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/features/Home/home_enums.dart';
import 'package:link_up/features/Home/widgets/bottom_sheets.dart';
import 'package:link_up/shared/themes/colors.dart';

class WritePost extends StatefulWidget {
  const WritePost({super.key});

  @override
  State<WritePost> createState() => _WritePostState();
}

class _WritePostState extends State<WritePost> {
  Visibilities _visbilityPost = Visibilities.anyone;
  Visibilities _visibilityComment = Visibilities.anyone;
  bool _brandPartnerships = false;
  final TextEditingController _controller = TextEditingController();

  void setVisbilityPost(Visibilities value) {
    setState(() {
      _visbilityPost = value;
    });
  }

  void setVisibilityComment(Visibilities value) {
    setState(() {
      _visibilityComment = value;
    });
  }

  void setBrandPartnerships(bool value) {
    setState(() {
      _brandPartnerships = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        toolbarHeight: 60.h,
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20.r,
              backgroundImage: const AssetImage('assets/images/profile.png'),
            ),
            SizedBox(
              width: 10.w,
            ),
            TextButton(
              onPressed: () {
                postVisibiltyBottomSheet(
                    context,
                    setVisbilityPost,
                    setVisibilityComment,
                    setBrandPartnerships,
                    _visbilityPost,
                    _visibilityComment,
                    _brandPartnerships);
              },
              child: Wrap(
                alignment: WrapAlignment.end,
                children: [
                  SizedBox(
                    width: 50.w,
                    child: Text(
                        _visbilityPost == Visibilities.anyone
                            ? 'Anyone'
                            : 'Connections Only',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.grey,
                        )),
                  ),
                  SizedBox(
                    width: 5.w,
                  ),
                  Transform.translate(
                    offset: Offset(0, -2.h),
                    child: const Icon(
                      Icons.arrow_drop_down,
                      color: AppColors.grey,
                    ),
                  )
                ],
              ),
            )
          ],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.access_time)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              disabledBackgroundColor: AppColors.lightGrey.withOpacity(0.5),
              side: BorderSide(color: AppColors.lightGrey.withOpacity(0.5)),
              disabledForegroundColor: AppColors.grey,
            ),
            onPressed: _controller.text.isEmpty ? null : () {},
            child: const Text('Post'),
          ),
          SizedBox(
            width: 5.w,
          )
        ],
      ),
      body:
          Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Padding(
          padding: EdgeInsets.all(5.r),
          child: TextField(
            controller: _controller,
            onChanged: (value) {
              setState(() {});
            },
            maxLines: 10,
            decoration: const InputDecoration(
                hintText: 'What do you want to talk about?',
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(10)),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(10.r),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.photo,
                  size: 25.r,
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(Icons.more_horiz, size: 25.r),
              ),
            ],
          ),
        )
      ]),
      resizeToAvoidBottomInset: true,
    );
  }
}
