import 'package:flutter/material.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalog'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
        children: [
          Text(
            'Wallpaper catalog',
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 10),
          Text(
            'This screen is now ready for feed integration. Phase A keeps it read-only and image-first to control traffic and keep the rollout simple.',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: const [
              Chip(label: Text('All')),
              Chip(label: Text('Free')),
              Chip(label: Text('Collections')),
              Chip(label: Text('Latest')),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Next integration step', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 10),
                  Text(
                    'Replace this placeholder with hub-fed catalog rows, preview images, and a detail route. Keep autoplay out of the grid for the first rollout.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
