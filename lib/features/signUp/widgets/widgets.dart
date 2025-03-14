//widgets related to this page only
import 'package:flutter/material.dart';

class DividerWithText extends StatelessWidget {
  final String text;

  const DividerWithText({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        const Divider(
          thickness: 1,
          color: Colors.grey,
          height: 20,
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          color: Theme.of(context)
              .colorScheme
              .surface, // Same as background to make it blend
          child: Text(
            text,
            style: const TextStyle(fontSize: 13),
          ),
        ),
      ],
    );
  }
}
