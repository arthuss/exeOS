import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'app/theme/theme_controller.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ExeOsBootstrap());
}

class ExeOsBootstrap extends StatelessWidget {
  const ExeOsBootstrap({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ThemeController(),
      child: const ExeOsApp(),
    );
  }
}
