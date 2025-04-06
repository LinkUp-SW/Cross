import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'package:link_up/routes/app_routes.dart';
import 'package:link_up/shared/themes/app_themes.dart';
import 'shared/themes/theme_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]).then((_) {
    runApp(const ProviderScope(child: MyApp()));
  });
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: ScreenUtilInit(
          designSize: const Size(360, 690),
          minTextAdapt: true,
          builder: (context, child) {
            final goRouter = ref.watch(goRouterProvider);
            final theme = ref.watch(themeNotifierProvider);
            return GestureDetector(
              onTap: () {
                final currentFocus = FocusManager.instance.primaryFocus;
                if (currentFocus != null) {
                  currentFocus.unfocus();
                }
              },
              child: MaterialApp.router(
                debugShowCheckedModeBanner: false,
                routerConfig: goRouter,
                title: 'LinkUp',
                theme: AppThemes.lightTheme,
                darkTheme: AppThemes.darkTheme,
                themeMode: theme,
              ),
            );
          }),
    );
  }
}
