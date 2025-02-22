import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:link_up/shared/themes/app_themes.dart';
import 'package:link_up/shared/themes/button_styles.dart';
import 'package:skeletonizer/skeletonizer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        builder: (context, child) {
          return MaterialApp(
            title: 'Flutter Demo',
            theme: AppThemes.lightTheme,
            darkTheme: AppThemes.darkTheme,
            themeMode: ThemeMode.system,
            home: const MyHomePage(title: 'Flutter Demo Home Page'),
          );
        });
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool darkMode = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  darkMode = !darkMode;
                });
              },
              icon:
                  Icon(darkMode == false ? Icons.dark_mode : Icons.light_mode))
        ],
      ),
      body: Column(
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ChoiceChip(
                label: const Text("Hello"),
                selected: true,
                onSelected: (value) {},
              ),
              ChoiceChip(
                label: const Text("Hello"),
                selected: false,
                onSelected: (value) {},
              ),
              ElevatedButton(
                onPressed: () {},
                style: LinkUpButtonStyles().profileOpenToLight(),
                child: const Text('Open to'),
              )
            ],
          ),
          Expanded(
            child: ListView.builder(
                shrinkWrap: true,
                itemCount: 3,
                itemBuilder: (context, index) => Skeletonizer(
                        child: Card(
                      color: Theme.of(context).colorScheme.primary,
                      child: const ListTile(
                        leading: CircleAvatar(
                          child: Icon(Icons.text_snippet),
                        ),
                        title: Text("This is a text"),
                        subtitle: Text("This is the subtitle"),
                        trailing: Icon(Icons.star_border),
                      ),
                    ))),
          ),
        ],
      ),
    );
  }
}
