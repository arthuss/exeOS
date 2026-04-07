import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../application/auth_controller.dart';

class AuthCompleteScreen extends StatefulWidget {
  const AuthCompleteScreen({
    super.key,
    required this.provider,
    required this.nextPath,
  });

  final String provider;
  final String nextPath;

  @override
  State<AuthCompleteScreen> createState() => _AuthCompleteScreenState();
}

class _AuthCompleteScreenState extends State<AuthCompleteScreen> {
  late Future<AuthRedirectOutcome> _resolution;

  @override
  void initState() {
    super.initState();
    _resolution = _resolveFlow();
  }

  Future<AuthRedirectOutcome> _resolveFlow() {
    if (widget.provider != 'google') {
      return Future<AuthRedirectOutcome>.value(
        AuthRedirectOutcome.unsupported(
          'Unsupported auth provider: ${widget.provider}',
        ),
      );
    }
    return context.read<AuthController>().completeGoogleWebSignIn();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Account callback')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: FutureBuilder<AuthRedirectOutcome>(
              future: _resolution,
              builder: (context, snapshot) {
                final outcome = snapshot.data;
                final waiting =
                    snapshot.connectionState != ConnectionState.done ||
                    outcome?.kind == AuthRedirectOutcomeKind.redirecting;

                if (waiting) {
                  return _AuthFlowCard(
                    title: 'Google sign-in is being prepared',
                    body:
                        'Firebase Auth now owns the web session bootstrap. If this is the first pass, the browser will hand off to Google and then return here.',
                    footer:
                        'This callback surface is also the basis for later Drive and social integration returns.',
                    accent: scheme.primary,
                    child: const Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  );
                }

                if (outcome == null) {
                  return _AuthFlowCard(
                    title: 'No auth result was produced',
                    body:
                        'The callback route loaded, but Firebase Auth returned no result. Retry the Google handoff from Settings.',
                    footer: 'Current return target: ${widget.nextPath}',
                    accent: scheme.error,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          FilledButton(
                            onPressed: () =>
                                setState(() => _resolution = _resolveFlow()),
                            child: const Text('Retry'),
                          ),
                          OutlinedButton(
                            onPressed: () => context.go(widget.nextPath),
                            child: const Text('Back'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                switch (outcome.kind) {
                  case AuthRedirectOutcomeKind.signedIn:
                  case AuthRedirectOutcomeKind.alreadySignedIn:
                    final user = outcome.user;
                    final displayName = user?.displayName?.trim();
                    final label = displayName != null && displayName.isNotEmpty
                        ? displayName
                        : (user?.email ?? 'Google account');
                    return _AuthFlowCard(
                      title: 'Google session connected',
                      body:
                          'The Firebase web session is now live. Owner merge, entitlements, and Drive/social scopes remain separate follow-up steps.',
                      footer: 'Signed in as $label',
                      accent: scheme.primary,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            FilledButton(
                              onPressed: () => context.go(widget.nextPath),
                              child: const Text('Continue'),
                            ),
                            OutlinedButton(
                              onPressed: () => context.go('/'),
                              child: const Text('Open catalog'),
                            ),
                          ],
                        ),
                      ),
                    );
                  case AuthRedirectOutcomeKind.unsupported:
                    return _AuthFlowCard(
                      title: 'Auth route reserved',
                      body:
                          outcome.message ??
                          'This callback route is reserved, but the current platform does not execute the Google web flow yet.',
                      footer: 'Return target: ${widget.nextPath}',
                      accent: scheme.secondary,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: OutlinedButton(
                          onPressed: () => context.go(widget.nextPath),
                          child: const Text('Back'),
                        ),
                      ),
                    );
                  case AuthRedirectOutcomeKind.error:
                    return _AuthFlowCard(
                      title: 'Google sign-in failed',
                      body:
                          outcome.message ??
                          'Firebase Auth could not finish the current Google handoff.',
                      footer:
                          'Check Firebase Auth Google provider + authorized domains if this repeats.',
                      accent: scheme.error,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          children: [
                            FilledButton(
                              onPressed: () =>
                                  setState(() => _resolution = _resolveFlow()),
                              child: const Text('Retry'),
                            ),
                            OutlinedButton(
                              onPressed: () => context.go(widget.nextPath),
                              child: const Text('Back'),
                            ),
                          ],
                        ),
                      ),
                    );
                  case AuthRedirectOutcomeKind.redirecting:
                    return const SizedBox.shrink();
                }
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthFlowCard extends StatelessWidget {
  const _AuthFlowCard({
    required this.title,
    required this.body,
    required this.footer,
    required this.accent,
    required this.child,
  });

  final String title;
  final String body;
  final String footer;
  final Color accent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: accent.withAlpha(24),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.verified_user_rounded, color: accent),
            ),
            const SizedBox(height: 20),
            Text(title, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 12),
            Text(body, style: theme.textTheme.bodyLarge),
            const SizedBox(height: 12),
            Text(
              footer,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            child,
          ],
        ),
      ),
    );
  }
}
