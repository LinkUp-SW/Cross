import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/features/Home/home_enums.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/widgets/bottom_sheet.dart';

aboutPostBottomSheet(BuildContext context, {bool isAd = false}) {
  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    builder: (context) => CustomModalBottomSheet(
      content: Column(
        children: [
          ListTile(
            onTap: () {},
            leading: const Icon(Icons.save_alt),
            title: const Text("Save"),
          ),
          ListTile(
            onTap: () {},
            leading: const Icon(Icons.ios_share),
            title: const Text("Share via"),
          ),
          ListTile(
            onTap: () {},
            leading: const Icon(Icons.visibility_off),
            title: Text(isAd ? "Hide or report this add" : "Not interested"),
          ),
          isAd
              ? ListTile(
                  onTap: () {},
                  leading: const Icon(Icons.info),
                  title: const Text("Why am I seeing this ad?"),
                )
              : ListTile(
                  onTap: () {},
                  leading: Transform.rotate(
                      angle: math.pi / 4,
                      child: const Icon(Icons.control_point_sharp)),
                  title: const Text("Unfollow 'name'"),
                ),
          if (!isAd)
            ListTile(
              onTap: () {},
              leading: const Icon(Icons.report),
              title: const Text("Report post"),
            ),
        ],
      ),
    ),
  );
}

shareBottomSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    builder: (context) => CustomModalBottomSheet(
      content: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Send as message",
              style: TextStyle(fontSize: 20),
            ),
          ),
          SizedBox(height: 15.h),
          TextField(
            decoration: InputDecoration(
              hintText: "Search",
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(60.r)),
            ),
          ),
          SizedBox(height: 10.h),
          SizedBox(
            height: 80.h,
            child: ListView.separated(
                separatorBuilder: (context, index) => SizedBox(
                      width: 10.w,
                    ),
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: 10,
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: 60.w,
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 25.r,
                          backgroundImage: const NetworkImage(
                              'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__480.jpg'),
                        ),
                        const Text("Name this is sparta 2",
                            textAlign: TextAlign.center),
                      ],
                    ),
                  );
                }),
          ),
          const Divider(
            thickness: 0,
            color: AppColors.grey,
          ),
          SizedBox(
            height: 80.h,
            child: ListView.separated(
                separatorBuilder: (context, index) => SizedBox(
                      width: 10.w,
                    ),
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemCount: 10,
                itemBuilder: (context, index) {
                  return SizedBox(
                    width: 60.w,
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 25.r,
                          backgroundImage: const NetworkImage(
                              'https://cdn.pixabay.com/photo/2015/04/23/22/00/tree-736885__480.jpg'),
                        ),
                        const Text("Name this is sparta 2",
                            textAlign: TextAlign.center),
                      ],
                    ),
                  );
                }),
          ),
        ],
      ),
    ),
  );
}

postVisibiltyBottomSheet(
    BuildContext context,
    Function setVisbilityPost,
    Function setVisibilityComment,
    Function setBrandPartnerships,
    Visibilities post,
    Visibilities comment,
    bool initBrandPartnerships) {
  bool brandPartnerships = initBrandPartnerships;
  Visibilities visbilityPost = post;
  Visibilities visibilityComment = comment;
  return showModalBottomSheet(
    context: context,
    builder: (context) =>
        StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
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
                value: Visibilities.anyone,
                groupValue: visbilityPost,
                onChanged: (value) {
                  setVisbilityPost(value);
                  setState(() {
                    visbilityPost = value!;
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
                value: Visibilities.connectionsOnly,
                groupValue: visbilityPost,
                onChanged: (value) {
                  setVisbilityPost(value);
                  setState(() {
                    visbilityPost = value!;
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
                value: Visibilities.anyone,
                groupValue: visibilityComment,
                onChanged: (value) {
                  setVisibilityComment(value);
                  setState(() {
                    visibilityComment = value!;
                  });
                },
                title: const Text('Anyone'),
                controlAffinity: ListTileControlAffinity.trailing,
                secondary: const Icon(Icons.public),
                activeColor: Theme.of(context).colorScheme.tertiary,
              ),
              RadioListTile(
                value: Visibilities.connectionsOnly,
                groupValue: visibilityComment,
                onChanged: (value) {
                  setVisibilityComment(value);
                  setState(() {
                    visibilityComment = value!;
                  });
                },
                title: const Text('Connections Only'),
                controlAffinity: ListTileControlAffinity.trailing,
                activeColor: Theme.of(context).colorScheme.tertiary,
                secondary: const Icon(Icons.people),
              ),
              RadioListTile(
                value: Visibilities.noOne,
                groupValue: visibilityComment,
                onChanged: (value) {
                  setVisibilityComment(value);
                  setState(() {
                    visibilityComment = value!;
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
                  brandPartnerships ? 'On' : 'Off',
                ),
                value: brandPartnerships,
                onChanged: (value) {
                  setBrandPartnerships(value);
                  setState(() {
                    brandPartnerships = value;
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
