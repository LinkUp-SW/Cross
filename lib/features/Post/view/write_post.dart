import 'dart:developer';
import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:linkify/linkify.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
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
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/widgets/custom_snackbar.dart';
import 'package:url_launcher/url_launcher.dart';

class WritePost extends ConsumerStatefulWidget {
  const WritePost({super.key});

  @override
  ConsumerState<WritePost> createState() => _WritePostState();
}

class _WritePostState extends ConsumerState<WritePost> {
  bool _sending = false;
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
            ref
                .read(writePostProvider.notifier)
                .setMedia(Media(type: MediaType.link, urls: [element.url]));

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
    final postData = ref.watch(writePostProvider);
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      appBar: AppBar(
        toolbarHeight: 60.h,
        backgroundColor: Theme.of(context).colorScheme.primary,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            context.pop();
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
                    postData.media.file.isEmpty
                ? null
                : () {
                    setState(() {
                      _sending = true;
                    });
                    ref
                        .read(writePostProvider.notifier)
                        .createPost()
                        .then((value) {
                      if (value != '') {
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
                Padding(
                  padding: EdgeInsets.all(10.r),
                  child: Stack(
                    children: [
                      TextField(
                        controller: postData.controller,
                        onChanged: (value) {
                          if (postData.media.type == MediaType.none) {
                            if (_debounce?.isActive ?? false) {
                              _debounce!.cancel();
                            }
                            _debounce = Timer(const Duration(seconds: 2), () {
                              setState(() {
                                checkForLinks(value);
                              });
                            });
                          }
                          setState(() {});
                        },
                        cursorColor: AppColors.lightBlue,
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
                      Linkify(
                        text: postData.controller.text,
                        style: TextStyle(
                          fontSize: 15.r,
                          letterSpacing: 0,
                        ),
                        options: const LinkifyOptions(humanize: false),
                        onOpen: (link) async {
                          if (!await launchUrl(Uri.parse(link.url))) {
                            throw Exception('Could not open the link');
                          }
                        },
                      ),
                    ],
                  ),
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
