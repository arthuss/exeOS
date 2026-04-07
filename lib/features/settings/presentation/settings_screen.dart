import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/theme/theme_controller.dart';
import '../../auth/application/auth_controller.dart';
import '../../auth/application/owner_session_controller.dart';
import '../../legal/presentation/widgets/legal_footer.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = context.watch<ThemeController>();
    final authController = context.watch<AuthController>();
    final ownerSessionController = context.watch<OwnerSessionController>();
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
                        : authController.isSignedIn &&
                              ownerSessionController.isLinked
                        ? 'The Firebase web session and canonical owner resolution are live. This is the base for later web entitlements, AI history, and provider connects.'
                        : authController.isSignedIn
                        ? 'The Firebase web session is live. The shell is now resolving the canonical owner path behind that linked identity.'
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
                    if (ownerSessionController.isResolving) ...[
                      const SizedBox(height: 8),
                      const LinearProgressIndicator(minHeight: 3),
                      const SizedBox(height: 12),
                      Text(
                        'Resolving the canonical ownerId for this linked session...',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ] else if (ownerSessionController.isLinked &&
                        ownerSessionController.snapshot != null) ...[
                      const SizedBox(height: 8),
                      _OwnerResolutionPanel(
                        snapshot: ownerSessionController.snapshot!,
                      ),
                    ] else if (ownerSessionController.hasError) ...[
                      const SizedBox(height: 8),
                      Text(
                        ownerSessionController.errorMessage!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: scheme.error,
                        ),
                      ),
                    ],
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
                          onPressed: ownerSessionController.isResolving
                              ? null
                              : () async {
                                  await context
                                      .read<OwnerSessionController>()
                                      .refresh();
                                },
                          icon: const Icon(Icons.sync_rounded),
                          label: const Text('Refresh owner'),
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
                    'Branding, Routing, der feed-gebundene Read-only-Katalog, Firebase-Web-Auth und die erste account-zentrierte Owner-Resolution stehen. Als Naechstes folgen Entitlements und die spaeteren Provider-Connects.',
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

class _OwnerResolutionPanel extends StatelessWidget {
  const _OwnerResolutionPanel({required this.snapshot});

  final OwnerSessionSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final resolutionText = snapshot.wasCreated
        ? 'A new canonical owner path was created for this linked identity.'
        : 'This linked identity resolved back into an existing canonical owner path.';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withAlpha(120),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Canonical owner', style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          SelectableText(snapshot.ownerId, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 8),
          Text(
            'Provider: ${snapshot.provider}',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          Text(
            resolutionText,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
