import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../catalog/presentation/widgets/catalog_preview_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('exeOS'),
        actions: [
          IconButton(
            tooltip: 'Settings',
            onPressed: () => context.go('/settings'),
            icon: const Icon(Icons.tune_rounded),
          ),
        ],
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              scheme.primary.withAlpha(30),
              theme.scaffoldBackgroundColor,
              theme.scaffoldBackgroundColor,
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          children: [
            Text(
              'Web catalog for animated wallpapers',
              style: theme.textTheme.displaySmall,
            ),
            const SizedBox(height: 12),
            Text(
              'Phase A sets the hosted shell: branding, routing, catalog entry, and a clean base for Google auth and feed integration.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.icon(
                  onPressed: () => context.go('/catalog'),
                  icon: const Icon(Icons.grid_view_rounded),
                  label: const Text('Full catalog'),
                ),
                OutlinedButton.icon(
                  onPressed: () => context.go('/settings'),
                  icon: const Icon(Icons.display_settings_rounded),
                  label: const Text('App settings'),
                ),
              ],
            ),
            const SizedBox(height: 28),
            CatalogPreviewSection(
              title: 'Preview catalog',
              description:
                  'Der Katalog sitzt direkt auf der Startflaeche und zieht seine Vorschau jetzt aus den exportierten Hub-Feeds. Die Weboberflaeche bleibt zunaechst read-only und image-first.',
              includeSurface: true,
              showBrowseAction: true,
              onBrowseTap: () => context.go('/catalog'),
              layout: CatalogPreviewLayout.compact,
            ),
            const SizedBox(height: 28),
            const _FeatureCard(
              title: 'Hosted web front end',
              body:
                  'This repo drives the public web app on the dedicated dotexe-pro Firebase Hosting site instead of sharing Android presentation code.',
              icon: Icons.language_rounded,
            ),
            const SizedBox(height: 16),
            const _FeatureCard(
              title: 'Shared path toward iOS',
              body:
                  'The same codebase stays aligned for a later iOS target, but Live Photo export and platform-specific media work remain separate later-phase tasks.',
              icon: Icons.phone_iphone_rounded,
            ),
            const SizedBox(height: 16),
            const _FeatureCard(
              title: 'Catalog-first rollout',
              body:
                  'Der oeffentliche Read-only-Katalog ist jetzt feed-gebunden. Authentifizierung, Entitlements, Zahlungen und Account-Linking folgen danach.',
              icon: Icons.auto_awesome_mosaic_rounded,
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({
    required this.title,
    required this.body,
    required this.icon,
  });

  final String title;
  final String body;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: scheme.primary.withAlpha(36),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: scheme.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    body,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
