import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'app/theme/theme_controller.dart';
import 'features/auth/application/auth_controller.dart';
import 'features/auth/application/owner_session_controller.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final authAvailable = DefaultFirebaseOptions.isConfigured;
  if (authAvailable) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  usePathUrlStrategy();
  runApp(ExeOsBootstrap(authAvailable: authAvailable));
}

class ExeOsBootstrap extends StatelessWidget {
  const ExeOsBootstrap({super.key, required this.authAvailable});

  final bool authAvailable;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider(
          create: (_) => authAvailable
              ? AuthController()
              : AuthController.disabled(
                  'Firebase web auth is not configured in this build. Add EXEOS_FIREBASE_API_KEY before promoting the auth UI live.',
                ),
        ),
        ChangeNotifierProvider(
          create: (context) => OwnerSessionController(
            authController: context.read<AuthController>(),
          ),
        ),
      ],
      child: const ExeOsApp(),
    );
  }
}
