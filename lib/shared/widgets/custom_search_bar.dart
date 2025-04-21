
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomSearchBar extends StatelessWidget {
  const CustomSearchBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SearchAnchor.bar(
      suggestionsBuilder:
          (BuildContext context, SearchController searchController) {
        return [
          SizedBox(
            height: 100.h,
            child: ListView.builder(
              itemCount: 40,
              scrollDirection: Axis.horizontal,
              itemBuilder: (BuildContext context, index) {
                return CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text('$index'),
                );
              },
            ),
          ),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: 10,
              itemBuilder: (BuildContext context, index) {
                return ListTile(
                  title: Text('Item $index'),
                );
              },
            ),
          ),
        ];
      },
      viewTrailing: const [
        Icon(Icons.qr_code),
      ],
      barHintText: "Search",
      barLeading: const Icon(Icons.search),
    );
  }
}
