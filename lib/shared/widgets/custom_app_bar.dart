import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:link_up/core/constants/endpoints.dart';
import 'package:link_up/features/chat/viewModel/chat_viewmodel.dart';


class CustomAppBar extends ConsumerStatefulWidget implements PreferredSizeWidget {
  final Widget searchBar;
  final VoidCallback? leadingAction;
  final PreferredSizeWidget? bottom;
  
  const CustomAppBar({
    super.key,
    required this.searchBar,
    required this.leadingAction,
    this.bottom,
  });

  @override
  _CustomAppBarState createState() => _CustomAppBarState();
  
  @override
 
  Size get preferredSize => const Size.fromHeight(60);
}

class _CustomAppBarState extends ConsumerState<CustomAppBar> {
  @override
  void initState() {
    super.initState();
    // Trigger the unread count fetch when this widget is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Fetch unread count from the ViewModel
      ref.read(chatViewModelProvider.notifier).getAllCounts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Theme.of(context).colorScheme.primary,
      leading: GestureDetector(
        onTap: widget.leadingAction,
        child: Padding(
          padding: EdgeInsets.all(5.r),
          child: CircleAvatar(
            radius: 20.r,
            backgroundImage: NetworkImage(InternalEndPoints.profileUrl),
          ),
        ),
      ),
      title: SizedBox(
        height: 35.h,
        child: widget.searchBar,
      ),
      actions: [
        Consumer(
          builder: (context, ref, child) {
            final chatState = ref.watch(chatViewModelProvider);
            final unreadCount = chatState.unreadCount;

            return IconButton(
              onPressed: () => context.push('/messages'),
              icon: Badge(
                isLabelVisible: unreadCount > 0,
                backgroundColor: Theme.of(context).colorScheme.error,
                textColor: Theme.of(context).colorScheme.onError,
                label: Text(unreadCount.toString()),
                offset: const Offset(-10, 0),
                child: const Icon(Icons.message),
              ),
            );
          },
        ),
      ],
      bottom: widget.bottom,
    );
  }

}
