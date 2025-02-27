// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// class CustomTabBar extends ConsumerWidget {
//   const CustomTabBar({super.key})


//   @override
//   Widget build(BuildContext context, WidgetRef ref) {

//     return const DefaultTabController(
//             initialIndex: 1,
//             length: 2,
//             child: widget(
//               child: TabBar(            
//                 isScrollable: false, // Ensures tabs take equal width
//                 indicatorSize: TabBarIndicatorSize.tab,
//                 tabs: <Widget>[
//                   Tab(text: 'Grow'),
//                   Tab(text: 'Catch'),
//                 ],),
//             ),
//             body: TabBarView(
//         children: <Widget>[
//           Center(child: Text("Grow Tab")),
//           Center(child: Text("Catch Tab")),
//         ],
//       ),
//           ),
//   }
// }
