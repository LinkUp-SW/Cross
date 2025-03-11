import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/shared/themes/colors.dart';

class WritePost extends StatefulWidget {
  const WritePost({super.key});

  @override
  State<WritePost> createState() => _WritePostState();
}

enum Visibility { anyone, connectionsOnly, noOne }

class _WritePostState extends State<WritePost> {
  Visibility _visbilityPost = Visibility.anyone;
  Visibility _visibilityComment = Visibility.anyone;
  bool _brandPartnerships = false;
  final TextEditingController _controller = TextEditingController();

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
                  postVisibiltyBottomSheet(context);
                },
                child: Wrap(
                  alignment: WrapAlignment.end,
                  children: [
                    Text(
                        _visbilityPost == Visibility.anyone
                            ? 'Anyone'
                            : 'Connections Only',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.grey,
                        )),
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
            IconButton(onPressed: (){}, icon: const Icon(Icons.access_time)),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                disabledBackgroundColor: AppColors.lightGrey.withOpacity(0.5),
                side: BorderSide(color: AppColors.lightGrey.withOpacity(0.5)),
                disabledForegroundColor: AppColors.grey,
              ),
              onPressed: _controller.text.isEmpty ? null : () {},
              child: const Text('Post'),
            )
          ],
        ),
        body: TextField(
          controller: _controller,
          onChanged: (value) {
            setState(() {});
          },
          maxLines: 10,
          decoration: const InputDecoration(
              hintText: 'What do you want to talk about?',
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(10)),
        ));
  }

  Future<dynamic> postVisibiltyBottomSheet(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
        return Padding(
          padding: EdgeInsets.all(10.r),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Who can see your post?',
                ),
                RadioListTile(
                  value: Visibility.anyone,
                  groupValue: _visbilityPost,
                  onChanged: (value) {
                    setState(() {
                      _visbilityPost = value!;
                    });
                  },
                  title: const Text('Anyone'),
                  subtitle: const Text(
                    'Anyone on or off LinkedIn',
                    style: TextStyle(color: AppColors.grey),
                  ),
                  controlAffinity: ListTileControlAffinity.trailing,
                  secondary: const Icon(Icons.public),
                  activeColor: Theme.of(context).colorScheme.tertiary,
                ),
                RadioListTile(
                  value: Visibility.connectionsOnly,
                  groupValue: _visbilityPost,
                  onChanged: (value) {
                    setState(() {
                      _visbilityPost = value!;
                    });
                  },
                  title: const Text('Connections Only'),
                  controlAffinity: ListTileControlAffinity.trailing,
                  activeColor: Theme.of(context).colorScheme.tertiary,
                  secondary: const Icon(Icons.people),
                ),
                const Divider(
                  color: AppColors.grey,
                  thickness: 0,
                ),
                const Text('Comment Cotrol'),
                RadioListTile(
                  value: Visibility.anyone,
                  groupValue: _visibilityComment,
                  onChanged: (value) {
                    setState(() {
                      _visibilityComment = value!;
                    });
                  },
                  title: const Text('Anyone'),
                  controlAffinity: ListTileControlAffinity.trailing,
                  secondary: const Icon(Icons.public),
                  activeColor: Theme.of(context).colorScheme.tertiary,
                ),
                RadioListTile(
                  value: Visibility.connectionsOnly,
                  groupValue: _visibilityComment,
                  onChanged: (value) {
                    setState(() {
                      _visibilityComment = value!;
                    });
                  },
                  title: const Text('Connections Only'),
                  controlAffinity: ListTileControlAffinity.trailing,
                  activeColor: Theme.of(context).colorScheme.tertiary,
                  secondary: const Icon(Icons.people),
                ),
                RadioListTile(
                  value: Visibility.noOne,
                  groupValue: _visibilityComment,
                  onChanged: (value) {
                    setState(() {
                      _visibilityComment = Visibility.noOne;
                    });
                  },
                  title: const Text('No One'),
                  controlAffinity: ListTileControlAffinity.trailing,
                  activeColor: Theme.of(context).colorScheme.tertiary,
                  secondary: const Icon(Icons.comments_disabled_outlined),
                ),
                const Divider(
                  color: AppColors.grey,
                  thickness: 0,
                ),
                SwitchListTile(
                  title: const Text('Brand Partnerships'),
                  subtitle: Text(
                    _brandPartnerships ? 'On' : 'Off',
                  ),
                  value: _brandPartnerships,
                  onChanged: (value) {
                    setState(() {
                      _brandPartnerships = value;
                    });
                  },
                  activeColor: Theme.of(context).colorScheme.tertiary,
                )
              ],
            ),
          ),
        );
      }),
    );
  }
}
