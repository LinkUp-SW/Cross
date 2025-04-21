import 'dart:developer';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:link_up/core/utils/global_keys.dart';
import 'package:link_up/features/Home/home_enums.dart';
import 'package:link_up/features/Home/model/media_model.dart';
import 'package:link_up/features/Home/viewModel/post_vm.dart';
import 'package:link_up/features/Post/viewModel/write_post_vm.dart';
import 'package:link_up/features/Post/widgets/bottom_sheet.dart';
import 'package:link_up/features/Post/widgets/formatted_input.dart';
import 'package:link_up/features/logIn/viewModel/user_data_vm.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/widgets/custom_snackbar.dart';

class WritePost extends ConsumerStatefulWidget {
  const WritePost({super.key});

  @override
  ConsumerState<WritePost> createState() => _WritePostState();
}

class _WritePostState extends ConsumerState<WritePost> {
  bool _sending = false;
  bool _showTags = false;
  final FocusNode _focusNode = FocusNode();

  final List<dynamic> _listtiles = [
    {
      'name': 'This is title',
      'id': '1',
      'profile':
          'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__480.jpg',
      'subtitle': 'This is subtitle',
    },
    {
      'name': 'This is title',
      'id': '2',
      'profile':
          'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__480.jpg',
      'subtitle': 'This is subtitle',
    },
    {
      'name': 'This is title',
      'id': '3',
      'profile':
          'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__480.jpg',
      'subtitle': 'This is subtitle',
    },
    {
      'name': 'This is title',
      'id': '4',
      'profile':
          'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__480.jpg',
      'subtitle': 'This is subtitle',
    },
    {
      'name': 'This is title',
      'id': '5',
      'profile':
          'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__480.jpg',
      'subtitle': 'This is subtitle',
    },
  ];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        if (!_focusNode.hasFocus) {
          _showTags = false;
        }
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
    ref.read(writePostProvider.notifier).setController((showTags) {
      if (_showTags != showTags) {
        setState(() {
          _showTags = showTags;
        });
      }
    },
    (media) {
      ref.read(writePostProvider.notifier).setMedia(media);
    }
    );
  });
  }

  // Add this utility function to your code
  Future<bool> isAccessibleUrl(String url) async {
    try {
      // First check if the URL format is valid
      final uri = Uri.parse(url);
      if (uri.scheme != 'http' && uri.scheme != 'https') {
        return false;
      }

      // Then try to check if the URL is accessible
      // Using a HEAD request to minimize data transfer
      final response = await http.head(uri);
      return response.statusCode >= 200 && response.statusCode < 400;
    } catch (e) {
      log('Error checking URL accessibility: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final postData = ref.watch(writePostProvider);
    final userData = ref.read(userDataProvider);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        toolbarHeight: 60.h,
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            if (postData.controller.text.isEmpty &&
                postData.media.file.isEmpty) {
              context.pop();
            } else {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  elevation: 10,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Save this post for later?',
                          style: TextStyle(fontSize: 18.r)),
                      IconButton(
                        onPressed: () {
                          context.pop();
                        },
                        icon: Icon(
                          Icons.close,
                          size: 18.r,
                        ),
                      ),
                    ],
                  ),
                  content: const Text(
                      'This post you started will be here when you return'),
                  actions: [
                    TextButton(
                      onPressed: () {
                        ref.read(writePostProvider.notifier).clearWritePost();
                        context.pop();
                        context.pop();
                      },
                      child: const Text(
                        'Discard',
                        style: TextStyle(color: AppColors.red),
                      ),
                    ),
                    TextButton(
                        onPressed: () {
                          //TODO: add the save post functionality in the localstorage
                          context.pop();
                          context.pop();
                        },
                        child: const Text('Save')),
                  ],
                ),
              );
            }
          },
        ),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 20.r,
              backgroundImage: NetworkImage(userData.profileUrl),
            ),
            SizedBox(
              width: 10.w,
            ),
            TextButton(
              onPressed: () {
                postVisibiltyBottomSheet(
                  context,
                  ref.read(writePostProvider.notifier).setVisibilityPost,
                  ref.read(writePostProvider.notifier).setVisibilityComment,
                  //setBrandPartnerships,
                  postData.visbilityPost,
                  postData.visibilityComment,
                  //postData.brandPartnerships.
                );
              },
              child: Wrap(
                alignment: WrapAlignment.end,
                children: [
                  SizedBox(
                    width: 50.w,
                    child: Text(
                        postData.visbilityPost == Visibilities.anyone
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
          //TODO: add or remove the schedule post as backend implementation
          IconButton(onPressed: () {}, icon: const Icon(Icons.access_time)),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              disabledBackgroundColor:
                  AppColors.lightGrey.withValues(alpha: 0.5),
              side:
                  BorderSide(color: AppColors.lightGrey.withValues(alpha: 0.5)),
              disabledForegroundColor: AppColors.grey,
            ),
            onPressed: postData.controller.text.isEmpty &&
                        postData.media.file.isEmpty ||
                    _sending == true
                ? null
                : () {
                    if (_sending) {
                      return;
                    }
                    setState(() {
                      _sending = true;
                    });
                    ref
                        .read(writePostProvider.notifier)
                        .createPost()
                        .then((value) {
                      if (value == 'error') {
                        setState(() {
                          _sending = false;
                          openSnackbar(
                            child: Row(
                              children: [
                                Icon(Icons.error_sharp, color: AppColors.red),
                                SizedBox(
                                  width: 10.w,
                                ),
                                Text(
                                  'Error occured! Couldn\'t create post. Try again',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .color),
                                ),
                              ],
                            ),
                          );
                        });
                      } else {
                        setState(() {
                          _sending = false;
                          ref.read(writePostProvider.notifier).clearWritePost();
                          final tempRef = ref.read(postProvider.notifier);
                          context.pop();
                          openSnackbar(
                            child: Row(children: [
                              Icon(
                                Icons.check_circle,
                                color: Theme.of(context).colorScheme.tertiary,
                              ),
                              SizedBox(
                                width: 10.w,
                              ),
                              Text('Post created successfully',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .color)),
                            ]),
                            onPressed: () {
                              tempRef.fetchPost(value);
                              navigatorKey.currentContext!.push('/postPage');
                            },
                            label: 'View',
                          );
                        });
                      }
                    });
                  },
            child: _sending
                ? const CircularProgressIndicator()
                : const Text('Post'),
          ),
          SizedBox(
            width: 5.w,
          )
        ],
      ),
      body:
          Column(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                FormattedInput(
                  controller: postData.controller,
                  focusNode: _focusNode,
                ),
                if (postData.media.type != MediaType.none)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                              onPressed: () {
                                setState(() {
                                  ref
                                      .read(writePostProvider.notifier)
                                      .setMedia(Media.initial());
                                });
                              },
                              style: IconButton.styleFrom(
                                backgroundColor: AppColors.darkBackground,
                              ),
                              icon: const Icon(Icons.close)),
                        ],
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20.r),
                        child: Padding(
                          padding: EdgeInsets.all(5.r),
                          child: postData.media.getMediaLocal(),
                        ),
                      ),
                      SizedBox(
                        height: 10.h,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        if (_showTags && _focusNode.hasFocus)
          SizedBox(
            height: 200.h,
            child: ListView.separated(
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              itemCount: _listtiles.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    radius: 20.r,
                    backgroundImage: NetworkImage(_listtiles[index]['profile']),
                  ),
                  title: Text(_listtiles[index]['name'],
                      style: Theme.of(context).textTheme.bodyLarge),
                  subtitle: Text(_listtiles[index]['subtitle'],
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: AppColors.grey,
                          )),
                  onTap: () {
                    postData.controller.text =
                        postData.controller.text.replaceRange(
                      postData.controller.text.lastIndexOf('@'),
                      postData.controller.text.length,
                      "@${_listtiles[index]['name']}:${_listtiles[index]['id']}^ ",
                    );
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
        if (postData.media.type == MediaType.none)
          Padding(
            padding: EdgeInsets.all(10.r),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    // Pick multiple images and videos.
                    final tempImages = await picker.pickMultiImage();
                    setState(() {
                      ref.read(writePostProvider.notifier).setMedia(Media(
                          type: tempImages.length > 1
                              ? MediaType.images
                              : MediaType.image,
                          urls: [],
                          file: [...tempImages]));
                    });
                  },
                  icon: Icon(
                    Icons.photo,
                    size: 25.r,
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    final ImagePicker picker = ImagePicker();
                    // Pick multiple images and videos.
                    final video =
                        await picker.pickVideo(source: ImageSource.gallery);
                    setState(() {
                      if (video != null) {
                        ref.read(writePostProvider.notifier).setMedia(Media(
                            type: MediaType.video, urls: [], file: [video]));
                      } else {
                        throw Exception('Could not add video');
                      }
                    });
                  },
                  icon: Icon(Icons.video_collection, size: 25.r),
                ),
                IconButton(
                  onPressed: () async {
                    final FilePicker picker = FilePicker.platform;
                    // Pick multiple images and videos.
                    final pdf = await picker.pickFiles(
                      type: FileType.custom,
                      allowCompression: true,
                      allowedExtensions: ['pdf'],
                    );
                    setState(() {
                      if (pdf != null) {
                        ref.read(writePostProvider.notifier).setMedia(Media(
                            type: MediaType.pdf,
                            urls: [],
                            file: [pdf.paths[0]!]));
                      } else {
                        throw Exception('Could not add pdf');
                      }
                    });
                  },
                  icon: Icon(Icons.picture_as_pdf, size: 25.r),
                ),
              ],
            ),
          )
      ]),
      resizeToAvoidBottomInset: true,
    );
  }
}
