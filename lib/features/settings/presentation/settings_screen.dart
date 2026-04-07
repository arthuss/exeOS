import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/theme/theme_controller.dart';
import '../../auth/application/auth_controller.dart';
import '../../legal/presentation/widgets/legal_footer.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    final authController = context.watch<AuthController>();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final currentUser = authController.currentUser;
    final email = currentUser?.email?.trim();
    final signInTarget = Uri(
      path: '/auth/complete',
      queryParameters: <String, String>{
        'provider': 'google',
        'next': '/settings',
      },
    ).toString();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        children: [
          Text('Account', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    !authController.isAvailable
                        ? (authController.unavailableReason ??
                              'Firebase web auth is disabled in this build.')
                        : authController.isSignedIn
                        ? 'The Firebase web session is live. This is the web-side base for later owner resolution, web entitlements, and provider connects.'
                        : 'Google sign-in now boots a real Firebase web session. Owner merge rules, Drive connect, and web entitlements still follow in separate steps.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (!authController.isAvailable) ...[
                    OutlinedButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.lock_outline_rounded),
                      label: const Text('Google sign-in not configured'),
                    ),
                  ] else if (authController.isSignedIn) ...[
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: scheme.primary.withAlpha(20),
                        foregroundColor: scheme.primary,
                        child: const Icon(Icons.person_rounded),
                      ),
                      title: Text(authController.accountLabel),
                      subtitle: Text(email ?? 'Firebase session active'),
                    ),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        FilledButton.icon(
                          onPressed: () async {
                            await context.read<AuthController>().signOut();
                          },
                          icon: const Icon(Icons.logout_rounded),
                          label: const Text('Sign out'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => context.go('/'),
                          icon: const Icon(Icons.grid_view_rounded),
                          label: const Text('Open catalog'),
                        ),
                      ],
                    ),
                  ] else ...[
                    FilledButton.icon(
                      onPressed: () => context.go(signInTarget),
                      icon: const Icon(Icons.login_rounded),
                      label: const Text('Sign in with Google'),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Appearance', style: theme.textTheme.headlineMedium),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose the shell mode for the hosted catalog.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.dark,
                        label: Text('Dark'),
                        icon: Icon(Icons.dark_mode_rounded),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        label: Text('Light'),
                        icon: Icon(Icons.light_mode_rounded),
                      ),
                      ButtonSegment(
                        value: ThemeMode.system,
                        label: Text('System'),
                        icon: Icon(Icons.auto_mode_rounded),
                      ),
                    ],
                    selected: {themeController.themeMode},
                    onSelectionChanged: (selection) {
                      themeController.setThemeMode(selection.first);
                    },
                    showSelectedIcon: false,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Phase A status', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 10),
                  Text(
                    'Branding, Routing, der feed-gebundene Read-only-Katalog und das Firebase-Web-Auth-Fundament stehen. Als Naechstes folgen Owner-Resolution, Entitlements und die spaeteren Provider-Connects.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const LegalFooter(compact: true),
        ],
      ),
    );
  }
}
