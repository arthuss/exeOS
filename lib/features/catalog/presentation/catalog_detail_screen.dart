import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/catalog_feed_repository.dart';
import 'widgets/catalog_preview_section.dart';

class CatalogDetailScreen extends StatelessWidget {
  const CatalogDetailScreen({
    super.key,
    required this.wallpaperRef,
    this.initialItem,
  });

  final String wallpaperRef;
  final CatalogFeedItem? initialItem;

  @override
  Widget build(BuildContext context) {
    final future = initialItem != null
        ? SynchronousFuture<CatalogFeedItem?>(initialItem)
        : catalogFeedRepository.loadItemByRef(wallpaperRef);

    return FutureBuilder<CatalogFeedItem?>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final item = snapshot.data;
        if (item == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Wallpaper')),
            body: _DetailState(
              title: 'Wallpaper nicht gefunden',
              body:
                  'Fuer $wallpaperRef wurde im aktuellen Feed-Snapshot kein Eintrag gefunden. Wenn der Katalog gerade umgebaut wurde, zuerst die Feed-Snapshots neu synchronisieren und erneut deployen.',
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(title: Text(item.displayTitle)),
          body: _DetailBody(item: item),
        );
      },
    );
  }
}

class _DetailBody extends StatelessWidget {
  const _DetailBody({required this.item});

  final CatalogFeedItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final previewUrl = item.previewVideoUrl ?? item.previewImageUrl;

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 36),
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            TextButton.icon(
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Zurueck'),
            ),
            _DetailPill(
              icon: Icons.tag_rounded,
              label: item.id,
              tone: CatalogPreviewSection.accentColor,
            ),
            _DetailPill(
              icon: Icons.workspace_premium_rounded,
              label: item.tierLabel,
              tone: _tierColorFor(item),
            ),
            _DetailPill(
              icon: Icons.schedule_rounded,
              label: _formatUpdated(item.updatedAt),
              tone: CatalogPreviewSection.mutedColor,
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          item.displayTitle,
          style: theme.textTheme.displaySmall?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        if (item.visualHook?.trim().isNotEmpty == true) ...[
          const SizedBox(height: 12),
          Text(
            item.visualHook!,
            style: theme.textTheme.titleMedium?.copyWith(
              color: CatalogPreviewSection.accentColor,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ],
        const SizedBox(height: 12),
        Text(
          item.displayDescription?.trim().isNotEmpty == true
              ? item.displayDescription!
              : 'Read-only Preview aus dem Live-Katalog. Die Vorschau verlinkt direkt auf die exportierten Hub-Medien.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.55,
          ),
        ),
        const SizedBox(height: 28),
        LayoutBuilder(
          builder: (context, constraints) {
            final stacked = constraints.maxWidth < 980;
            final media = _PreviewSurface(item: item);
            final meta = _MetadataPanel(item: item);
            if (stacked) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [media, const SizedBox(height: 20), meta],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 11, child: media),
                const SizedBox(width: 24),
                Expanded(flex: 9, child: meta),
              ],
            );
          },
        ),
        const SizedBox(height: 28),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton.icon(
              onPressed: () => _launchInAndroidApp(item),
              icon: const Icon(Icons.phone_android_rounded),
              label: const Text('In Android-App oeffnen'),
            ),
            OutlinedButton.icon(
              onPressed: _launchPlayStoreListing,
              icon: const Icon(Icons.shop_rounded),
              label: const Text('Bei Google Play'),
            ),
            if (item.previewVideoUrl != null)
              OutlinedButton.icon(
                onPressed: () => _launchExternal(item.previewVideoUrl!),
                icon: const Icon(Icons.play_circle_fill_rounded),
                label: const Text('Preview-Video oeffnen'),
              ),
            if (item.previewImageUrl != null)
              OutlinedButton.icon(
                onPressed: () => _launchExternal(item.previewImageUrl!),
                icon: const Icon(Icons.image_rounded),
                label: const Text('Preview-Bild oeffnen'),
              ),
            if (previewUrl != null)
              OutlinedButton.icon(
                onPressed: () => _launchExternal(previewUrl),
                icon: const Icon(Icons.open_in_new_rounded),
                label: const Text('Asset im neuen Tab'),
              ),
          ],
        ),
      ],
    );
  }
}

class _PreviewSurface extends StatelessWidget {
  const _PreviewSurface({required this.item});

  final CatalogFeedItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CatalogPreviewSection.cardColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: CatalogPreviewSection.outlineColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Preview surface',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: CatalogPreviewSection.textColor,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                children: [
                  AspectRatio(
                    aspectRatio: 9 / 16,
                    child: item.previewImageUrl == null
                        ? const _DetailFallback()
                        : Image.network(
                            item.previewImageUrl!,
                            fit: BoxFit.cover,
                            webHtmlElementStrategy:
                                WebHtmlElementStrategy.prefer,
                            errorBuilder: (_, __, ___) =>
                                const _DetailFallback(),
                            loadingBuilder: (context, child, progress) =>
                                progress == null
                                ? child
                                : const _DetailFallback(),
                          ),
                  ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withAlpha(26),
                            Colors.transparent,
                            Colors.black.withAlpha(165),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 18,
                    right: 18,
                    bottom: 18,
                    child: Row(
                      children: [
                        Container(
                          width: 54,
                          height: 54,
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(145),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Icon(
                            item.hasPreviewVideo
                                ? Icons.play_arrow_rounded
                                : Icons.image_rounded,
                            size: 34,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.hasPreviewVideo
                                    ? 'Preview-Video verfuegbar'
                                    : 'Preview-Bild verfuegbar',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                item.hasPreviewVideo
                                    ? 'Die Karte fuehrt jetzt in eine echte Detailansicht. Das MP4 liegt separat als verlinkbares Preview-Asset vor.'
                                    : 'Fuer diesen Eintrag ist aktuell nur das Preview-Bild im Feed-Snapshot vorhanden.',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: Colors.white.withAlpha(210),
                                      height: 1.35,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ],
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

class _MetadataPanel extends StatelessWidget {
  const _MetadataPanel({required this.item});

  final CatalogFeedItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final collections = item.collections
        .map((entry) => entry.replaceAll('_', ' '))
        .toList(growable: false);
    final tags = item.tags
        .map((entry) => entry.replaceAll('_', ' '))
        .toList(growable: false);

    return Container(
      decoration: BoxDecoration(
        color: CatalogPreviewSection.baseColor,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: CatalogPreviewSection.outlineColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Metadata',
              style: theme.textTheme.titleLarge?.copyWith(
                color: CatalogPreviewSection.textColor,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 16),
            _MetaRow(label: 'Wallpaper ID', value: item.id),
            if (item.marketing?.slug?.trim().isNotEmpty == true)
              _MetaRow(label: 'Canonical ref', value: item.canonicalRef),
            _MetaRow(label: 'Tier', value: item.tierLabel),
            _MetaRow(label: 'Updated', value: _formatUpdated(item.updatedAt)),
            _MetaRow(
              label: 'Preview assets',
              value: item.hasPreviewVideo ? 'image + video' : 'image only',
            ),
            if (item.marketing?.ctaMode?.trim().isNotEmpty == true)
              _MetaRow(label: 'CTA mode', value: item.marketing!.ctaMode!),
            if (collections.isNotEmpty) ...[
              const SizedBox(height: 18),
              Text(
                'Collections',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: CatalogPreviewSection.mutedColor,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final value in collections) _DetailChip(label: value),
                ],
              ),
            ],
            if (tags.isNotEmpty) ...[
              const SizedBox(height: 18),
              Text(
                'Tags',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: CatalogPreviewSection.mutedColor,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [for (final value in tags) _DetailChip(label: value)],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 112,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: CatalogPreviewSection.mutedColor,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: CatalogPreviewSection.textColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailChip extends StatelessWidget {
  const _DetailChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: CatalogPreviewSection.cardRaisedColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
          color: CatalogPreviewSection.mutedColor,
        ),
      ),
    );
  }
}

class _DetailPill extends StatelessWidget {
  const _DetailPill({
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
        color: CatalogPreviewSection.cardColor,
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

class _DetailState extends StatelessWidget {
  const _DetailState({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: CatalogPreviewSection.cardColor,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: CatalogPreviewSection.outlineColor),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: CatalogPreviewSection.textColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  body,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: CatalogPreviewSection.mutedColor,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailFallback extends StatelessWidget {
  const _DetailFallback();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: CatalogPreviewSection.cardRaisedColor,
      alignment: Alignment.center,
      child: const Icon(
        Icons.motion_photos_on_rounded,
        size: 44,
        color: CatalogPreviewSection.accentColor,
      ),
    );
  }
}

Future<void> _launchExternal(String url) async {
  final uri = Uri.tryParse(url);
  if (uri == null) {
    return;
  }
  await launchUrl(uri, mode: LaunchMode.platformDefault);
}

Future<void> _launchInAndroidApp(CatalogFeedItem item) async {
  final uri = _androidIntentUriFor(item.id);
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

Future<void> _launchPlayStoreListing() async {
  await launchUrl(_playStoreListingUri, mode: LaunchMode.externalApplication);
}

Uri _androidIntentUriFor(String wallpaperRef) {
  final normalizedRef = wallpaperRef.trim().isEmpty ? 'unknown' : wallpaperRef.trim();
  final fallback = Uri.encodeComponent(_playStoreListingUri.toString());
  return Uri.parse(
    'intent://w/$normalizedRef'
    '#Intent;scheme=exeget;package=$_androidPackageName;'
    'S.browser_fallback_url=$fallback;end',
  );
}

const String _androidPackageName = 'com.exeget.livewallpaper';
final Uri _playStoreListingUri = Uri.parse(
  'https://play.google.com/store/apps/details?id=$_androidPackageName',
);

Color _tierColorFor(CatalogFeedItem item) {
  switch (item.tierId?.toLowerCase()) {
    case 'free':
      return const Color(0xFF34B886);
    case 'gold':
      return const Color(0xFFBA9040);
    case 'amethyst':
      return const Color(0xFF7D69D8);
    case 'onyx':
      return const Color(0xFF6D7584);
    case 'platinum':
      return const Color(0xFFE7EEF9);
    default:
      return CatalogPreviewSection.accentColor;
  }
}

String _formatUpdated(DateTime value) {
  final local = value.toLocal();
  return '${local.day.toString().padLeft(2, '0')}.${local.month.toString().padLeft(2, '0')}.${local.year} ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
}
