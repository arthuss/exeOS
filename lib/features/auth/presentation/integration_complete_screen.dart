import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class IntegrationCompleteScreen extends StatelessWidget {
  const IntegrationCompleteScreen({
    super.key,
    required this.title,
    required this.body,
    required this.nextPath,
  });

  final String title;
  final String body;
  final String nextPath;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Card(
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
                        color: scheme.secondary.withAlpha(20),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(Icons.route_rounded, color: scheme.secondary),
                    ),
                    const SizedBox(height: 20),
                    Text(title, style: theme.textTheme.headlineSmall),
                    const SizedBox(height: 12),
                    Text(body, style: theme.textTheme.bodyLarge),
                    const SizedBox(height: 12),
                    Text(
                      'This route is intentionally reserved now so later Drive and social OAuth returns do not need a second routing model.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        FilledButton(
                          onPressed: () => context.go(nextPath),
                          child: const Text('Back'),
                        ),
                        OutlinedButton(
                          onPressed: () => context.go('/settings'),
                          child: const Text('Settings'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
