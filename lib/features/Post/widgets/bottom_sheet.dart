import 'package:flutter/material.dart';
import 'package:link_up/features/Home/home_enums.dart' show Visibilities;
import 'package:link_up/shared/themes/colors.dart';

postVisibiltyBottomSheet(
  BuildContext context,
  Function setVisbilityPost,
  Function setVisibilityComment,
  //Function setBrandPartnerships,
  Visibilities post,
  Visibilities comment, {
  bool showPost = true,
  showComment = true,
}
    //bool initBrandPartnerships
    ) {
  //bool brandPartnerships = initBrandPartnerships;
  Visibilities visbilityPost = post;
  Visibilities visibilityComment = comment;
  return showModalBottomSheet(
    context: context,
    builder: (context) =>
        StatefulBuilder(builder: (BuildContext context, StateSetter setState) {
      return Padding(
        padding: EdgeInsets.all(10),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showPost) ...[
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
              ],
              if (showPost && showComment)
                const Divider(
                  color: AppColors.grey,
                  thickness: 0,
                ),
              if (showComment) ...[
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
              ],
              // const Divider(
              //   color: AppColors.grey,
              //   thickness: 0,
              // ),
              // SwitchListTile(
              //   title: const Text('Brand Partnerships'),
              //   subtitle: Text(
              //     brandPartnerships ? 'On' : 'Off',
              //   ),
              //   value: brandPartnerships,
              //   onChanged: (value) {
              //     setBrandPartnerships(value);
              //     setState(() {
              //       brandPartnerships = value;
              //     });
              //   },
              //   activeColor: Theme.of(context).colorScheme.tertiary,
              // )
            ],
          ),
        ),
      );
    }),
  );
}
