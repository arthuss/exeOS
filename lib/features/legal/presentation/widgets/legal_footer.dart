import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../catalog/presentation/widgets/catalog_preview_section.dart';
import '../../data/legal_documents.dart';

class LegalFooter extends StatelessWidget {
  const LegalFooter({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 20 : 24),
      decoration: BoxDecoration(
        color: CatalogPreviewSection.cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: CatalogPreviewSection.outlineColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Rechtliches',
            style: theme.textTheme.titleLarge?.copyWith(
              color: CatalogPreviewSection.textColor,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Datenschutz, Nutzungsbedingungen, Kontoloeschung und Impressum werden zentral auf dotexe.pro gepflegt.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: CatalogPreviewSection.mutedColor,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _FooterLinkChip(
                label: 'Datenschutz',
                onTap: () => context.push('/privacy-policy'),
              ),
              _FooterLinkChip(
                label: 'Nutzungsbedingungen',
                onTap: () => context.push('/terms-of-service'),
              ),
              _FooterLinkChip(
                label: 'Konto loeschen',
                onTap: () => context.push('/delete-account'),
              ),
              _FooterLinkChip(
                label: 'Impressum',
                onTap: () => context.push('/impressum'),
              ),
              _FooterLinkChip(
                label: legalContactEmail,
                onTap: () => launchUrl(
                  Uri(scheme: 'mailto', path: legalContactEmail),
                  mode: LaunchMode.externalApplication,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FooterLinkChip extends StatelessWidget {
  const _FooterLinkChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: CatalogPreviewSection.cardRaisedColor,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: CatalogPreviewSection.outlineColor),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: CatalogPreviewSection.textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
