import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../catalog/presentation/widgets/catalog_preview_section.dart';
import '../data/legal_documents.dart';
import 'widgets/legal_footer.dart';

class LegalDocumentScreen extends StatelessWidget {
  const LegalDocumentScreen({super.key, required this.slug});

  final String slug;

  @override
  Widget build(BuildContext context) {
    final document = legalDocumentsBySlug[slug];
    if (document == null) {
      return const Scaffold(
        body: Center(child: Text('Legal document not found')),
      );
    }

    final canPop = Navigator.of(context).canPop();
    return Scaffold(
      appBar: AppBar(
        title: Text(document.title),
        leading: IconButton(
          tooltip: canPop ? 'Zurueck' : 'Zum Katalog',
          onPressed: () {
            if (canPop) {
              Navigator.of(context).maybePop();
              return;
            }
            context.go('/');
          },
          icon: Icon(canPop ? Icons.arrow_back_rounded : Icons.home_rounded),
        ),
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              CatalogPreviewSection.accentColor.withAlpha(16),
              CatalogPreviewSection.baseColor,
              CatalogPreviewSection.baseColor,
            ],
          ),
        ),
        child: SelectionArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: CatalogPreviewSection.cardColor,
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: CatalogPreviewSection.outlineColor,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: [
                              _InfoPill(
                                icon: Icons.verified_user_rounded,
                                label: document.title,
                                tone: CatalogPreviewSection.accentColor,
                              ),
                              _InfoPill(
                                icon: Icons.schedule_rounded,
                                label: 'Stand ${document.updatedAtLabel}',
                                tone: CatalogPreviewSection.mutedColor,
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Text(
                            document.summary,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: CatalogPreviewSection.mutedColor,
                                  height: 1.5,
                                ),
                          ),
                          if (document.notice?.trim().isNotEmpty == true) ...[
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: CatalogPreviewSection.cardRaisedColor,
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(
                                  color: CatalogPreviewSection.outlineColor,
                                ),
                              ),
                              child: Text(
                                document.notice!,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: CatalogPreviewSection.textColor,
                                      height: 1.5,
                                    ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    for (final section in document.sections) ...[
                      _LegalSectionCard(section: section),
                      const SizedBox(height: 16),
                    ],
                    const SizedBox(height: 8),
                    const LegalFooter(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegalSectionCard extends StatelessWidget {
  const _LegalSectionCard({required this.section});

  final LegalSectionData section;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: CatalogPreviewSection.cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: CatalogPreviewSection.outlineColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.heading,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: CatalogPreviewSection.textColor,
              fontWeight: FontWeight.w800,
            ),
          ),
          for (final paragraph in section.paragraphs) ...[
            const SizedBox(height: 14),
            Text(
              paragraph,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: CatalogPreviewSection.mutedColor,
                height: 1.6,
              ),
            ),
          ],
          if (section.bullets.isNotEmpty) ...[
            const SizedBox(height: 14),
            for (final bullet in section.bullets)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Icon(
                        Icons.circle,
                        size: 8,
                        color: CatalogPreviewSection.accentColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        bullet,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: CatalogPreviewSection.mutedColor,
                          height: 1.55,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
          if (section.links.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final link in section.links)
                  FilledButton.tonalIcon(
                    onPressed: () => _openLink(context, link),
                    icon: Icon(
                      link.internal
                          ? Icons.arrow_forward_rounded
                          : Icons.open_in_new_rounded,
                    ),
                    label: Text(link.label),
                  ),
              ],
            ),
          ],
          if (section.note?.trim().isNotEmpty == true) ...[
            const SizedBox(height: 14),
            Text(
              section.note!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: CatalogPreviewSection.textColor,
                fontWeight: FontWeight.w600,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _openLink(BuildContext context, LegalLinkData link) async {
    if (link.internal) {
      context.push(link.target);
      return;
    }
    final uri = Uri.tryParse(link.target);
    if (uri == null) {
      return;
    }
    await launchUrl(uri, mode: LaunchMode.platformDefault);
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.icon,
    required this.label,
    required this.tone,
  });

  final IconData icon;
  final String label;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: CatalogPreviewSection.cardRaisedColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: CatalogPreviewSection.outlineColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: tone),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: CatalogPreviewSection.textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
