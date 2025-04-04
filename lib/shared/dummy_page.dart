import 'package:flutter/material.dart';
import 'package:link_up/shared/widgets/bottom_sheet.dart';

class DummyPage extends StatelessWidget {
  final String title;

  const DummyPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    useRootNavigator: true,
                    builder: (context) => const CustomModalBottomSheet(
                      content:
                          Text('This is the content inside the bottom sheet!'),
                    ),
                  );
                },
                child: const Text('Show Bottom Sheet'),
              ),
            ]),
      ),
    );
  }
}
