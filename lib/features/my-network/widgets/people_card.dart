import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/features/my-network/model/people_card_model.dart';
import 'package:link_up/features/my-network/viewModel/grow_tab_view_model.dart';
import 'package:link_up/features/my-network/widgets/snackbar_content.dart';
import 'package:link_up/shared/themes/button_styles.dart';
import 'package:link_up/shared/themes/colors.dart';
import 'package:link_up/shared/themes/text_styles.dart';
import 'package:link_up/shared/widgets/custom_snackbar.dart';

class PeopleCard extends ConsumerStatefulWidget {
  final PeopleCardsModel data;
  final bool? isEducationCard;

  const PeopleCard({
    super.key,
    required this.data,
    this.isEducationCard,
  });

  @override
  ConsumerState<PeopleCard> createState() => _PeopleCardState();
}

class _PeopleCardState extends ConsumerState<PeopleCard> {
  bool isConnecting = false;
  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Card(
      shadowColor: isDarkMode ? AppColors.darkMain : AppColors.lightMain,
      elevation: 3.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: BorderSide(
          color: isDarkMode ? AppColors.darkGrey : AppColors.lightGrey,
          width: 0.5,
        ),
      ),
      child: Column(
        spacing: 15,
        children: [
          Stack(
            clipBehavior: Clip.none, // Important to allow overflow
            alignment:
                Alignment.bottomCenter, // Align profile pic to bottom center
            children: [
              // Cover image
              ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(6),
                  topRight: Radius.circular(6),
                ),
                child: Image(
                  image: widget.data.coverPicture != null
                      ? NetworkImage(widget.data.coverPicture!)
                      : AssetImage('assets/images/default-cover-picture.png')
                          as ImageProvider,
                  width: double.infinity,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),

              // Profile image - positioned to overlap
              Positioned(
                bottom: -25,
                right: 32,
                child: CircleAvatar(
                  radius: 45,
                  foregroundImage: widget.data.profilePicture != null
                      ? NetworkImage(widget.data.profilePicture!)
                      : AssetImage('assets/images/default-profile-picture.png')
                          as ImageProvider,
                ),
              ),
              // Cancel Button
              Positioned(
                top: 5,
                right: 3,
                child: InkWell(
                  onTap: () async {
                    final isEducationCard = widget.isEducationCard ?? false;
                    final foundReplacement = await ref
                        .read(growTabViewModelProvider.notifier)
                        .getReplacementPerson(widget.data.cardId,
                            isEducationCard ? 'education' : 'work_experience');

                    if (!foundReplacement) {
                      openSnackbar(
                          child: SnackbarContent(
                              message: 'No more people you may know available',
                              icon: Icons.info));
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: AppColors.fineLinesGrey,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(),
          Column(
            children: [
              Text(
                "${widget.data.firstName} ${widget.data.lastName}",
                style: TextStyles.font15_700Weight,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 6.0,
                ),
                child: Text(
                  widget.data.title ?? '',
                  style: TextStyles.font15_500Weight.copyWith(
                    color: isDarkMode
                        ? AppColors.darkGrey
                        : AppColors.lightSecondaryText,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 6,
                ),
                child: ElevatedButton(
                  onPressed: () {
                    if (widget.data.whoCanSendMeInvitation == "Everyone") {
                      if (isConnecting) {
                        showModalBottomSheet(
                          context: context,
                          useRootNavigator: true,
                          builder: (context) => Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: isDarkMode
                                  ? AppColors.darkMain
                                  : AppColors.lightMain,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              spacing: 5,
                              children: [
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 10),
                                  child: Text(
                                    'Withdraw Invitation',
                                    style: TextStyles.font15_700Weight.copyWith(
                                      color: isDarkMode
                                          ? AppColors.darkSecondaryText
                                          : AppColors.lightTextColor,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 10),
                                  child: Text(
                                    "If you withdraw now, you won't be able to resend to ${widget.data.firstName} ${widget.data.lastName} for up to 3 weeks",
                                    style: TextStyles.font13_500Weight.copyWith(
                                      color: isDarkMode
                                          ? AppColors.darkSecondaryText
                                          : AppColors.lightTextColor,
                                    ),
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        child: ElevatedButton(
                                          onPressed: () {
                                            context.pop();
                                          },
                                          style: isDarkMode
                                              ? LinkUpButtonStyles()
                                                  .myNetworkScreenConnectDark()
                                              : LinkUpButtonStyles()
                                                  .myNetworkScreenConnectLight(),
                                          child: Text('Cancel'),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        child: ElevatedButton(
                                          onPressed: () {
                                            ref
                                                .read(growTabViewModelProvider
                                                    .notifier)
                                                .withdrawInvitation(
                                                  widget.data.cardId,
                                                );
                                            setState(
                                              () {
                                                isConnecting = !isConnecting;
                                              },
                                            );
                                            context.pop();
                                          },
                                          style: isDarkMode
                                              ? LinkUpButtonStyles()
                                                  .profileOpenToDark()
                                              : LinkUpButtonStyles()
                                                  .profileOpenToLight(),
                                          child: Text('Withdraw'),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        );
                      } else {
                        ref
                            .read(growTabViewModelProvider.notifier)
                            .sendConnectionRequest(widget.data.cardId);
                        setState(
                          () {
                            isConnecting = !isConnecting;
                          },
                        );
                      }
                    }
                  },
                  style: isDarkMode
                      ? isConnecting
                          ? LinkUpButtonStyles()
                              .myNetworkScreenConnectDarkPressed()
                          : LinkUpButtonStyles().myNetworkScreenConnectDark()
                      : isConnecting
                          ? LinkUpButtonStyles()
                              .myNetworkScreenConnectLightPressed()
                          : LinkUpButtonStyles()
                              .myNetworkScreenConnectLightPressed(),
                  child: Text(isConnecting ? "Pending" : "Connect"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
