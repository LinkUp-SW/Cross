import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:link_up/shared/widgets/navigation_rail.dart';

class ResponsiveNavigation extends ConsumerWidget {
  const ResponsiveNavigation({
    required this.navigationShell,
    required this.scaffoldKey,
    super.key,
  });

  final StatefulNavigationShell navigationShell;
  final GlobalKey<ScaffoldState> scaffoldKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Use MediaQuery to determine screen width
    final screenWidth = MediaQuery.of(context).size.width;
    
    // For small screens (mobile), use bottom navigation
    if (screenWidth <= 600) {
      return CustomBottomNavigationBar(navigationShell: navigationShell);
    } 
    // For larger screens (tablet, desktop), use navigation rail
    else {
      return CustomNavigationRail(navigationShell: navigationShell);
    }
  }
}