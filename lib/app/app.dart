import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'router.dart';
import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

class ExeOsApp extends StatelessWidget {
  const ExeOsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeController>(
      builder: (context, themeController, _) {
        return MaterialApp.router(
          title: 'exeOS',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: themeController.themeMode,
          routerConfig: appRouter,
        );
      },
    );
  }
}
