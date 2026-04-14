import 'package:flutter/material.dart';

import '../../data/catalog_feed_repository.dart';
import '../catalog_tier_branding.dart';

enum CatalogPreviewLayout { compact, full }

class CatalogPreviewSection extends StatelessWidget {
  const CatalogPreviewSection({
    super.key,
    this.title = 'Videokatalog',
    this.description,
    this.includeSurface = false,
    this.showBrowseAction = false,
    this.onBrowseTap,
    this.onItemTap,
    this.layout = CatalogPreviewLayout.full,
  });

  final String title;
  final String? description;
  final bool includeSurface;
  final bool showBrowseAction;
  final VoidCallback? onBrowseTap;
  final ValueChanged<CatalogFeedItem>? onItemTap;
  final CatalogPreviewLayout layout;

  static const Color _base = Color(0xFF09040F);
  static const Color _card = Color(0xFF12081B);
  static const Color _cardRaised = Color(0xFF1A0D27);
  static const Color _outline = Color(0xFF3C2450);
  static const Color _text = Color(0xFFF8F1FF);
  static const Color _muted = Color(0xFFC5AFD9);
  static const Color _accent = Color(0xFFD56DFF);
  static const Color baseColor = _base;
  static const Color cardColor = _card;
  static const Color cardRaisedColor = _cardRaised;
  static const Color outlineColor = _outline;
  static const Color textColor = _text;
  static const Color mutedColor = _muted;
  static const Color accentColor = _accent;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CatalogPageData>(
      future: catalogFeedRepository.loadPageData(),
      builder: (context, snapshot) {
        final child = switch (snapshot.connectionState) {
          ConnectionState.done when snapshot.hasData => _CatalogBody(
            title: title,
            description: description,
            showBrowseAction: showBrowseAction,
            onBrowseTap: onBrowseTap,
            onItemTap: onItemTap,
            layout: layout,
            data: snapshot.data!,
          ),
          ConnectionState.done => _StateCard(
            title: title,
            description: description,
            headline: 'Feed nicht bereit',
            body:
                snapshot.error?.toString() ??
                'Feed-Daten konnten nicht geladen werden.',
            accent:
                r'Vor lokalem Web-Start: powershell -ExecutionPolicy Bypass -File .\scripts\sync-hub-feeds.ps1',
          ),
          _ => _StateCard(
            title: title,
            description: description,
            headline: 'Feed wird geladen',
            body:
                'Die Read-only-Produktvorschau wird aus den exportierten Hub-Feeds aufgebaut.',
            loading: true,
          ),
        };

        if (!includeSurface) {
          return child;
        }

        return DecoratedBox(
          decoration: BoxDecoration(
            color: _base,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: _outline),
          ),
          child: Padding(padding: const EdgeInsets.all(20), child: child),
        );
      },
    );
  }
}

class _CatalogBody extends StatelessWidget {
  const _CatalogBody({
    required this.title,
    required this.description,
    required this.showBrowseAction,
    required this.onBrowseTap,
    required this.onItemTap,
    required this.layout,
    required this.data,
  });

  final String title;
  final String? description;
  final bool showBrowseAction;
  final VoidCallback? onBrowseTap;
  final ValueChanged<CatalogFeedItem>? onItemTap;
  final CatalogPreviewLayout layout;
  final CatalogPageData data;

  int get _latestLimit => layout == CatalogPreviewLayout.compact ? 6 : 12;
  int get _shelfLimit => layout == CatalogPreviewLayout.compact ? 3 : 4;
  int get _itemsPerShelf => layout == CatalogPreviewLayout.compact ? 4 : 6;
  int get _tagLimit => layout == CatalogPreviewLayout.compact ? 6 : 10;

  @override
  Widget build(BuildContext context) {
    final latestItems = data.latestItems
        .take(_latestLimit)
        .toList(growable: false);
    final featuredTags = data.featuredTags
        .take(_tagLimit)
        .toList(growable: false);
    final shelves = data.shelves
        .take(_shelfLimit)
        .map((shelf) {
          return CatalogShelf(
            id: shelf.id,
            title: shelf.title,
            subtitle: shelf.subtitle,
            items: shelf.items.take(_itemsPerShelf).toList(growable: false),
          );
        })
        .toList(growable: false);
    final generatedAt = data.generatedAt;
    final generatedLabel = generatedAt == null
        ? 'unbekannt'
        : '${generatedAt.day.toString().padLeft(2, '0')}.${generatedAt.month.toString().padLeft(2, '0')}.${generatedAt.year} ${generatedAt.hour.toString().padLeft(2, '0')}:${generatedAt.minute.toString().padLeft(2, '0')}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: CatalogPreviewSection._text,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (description != null) ...[
          const SizedBox(height: 10),
          Text(
            description!,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: CatalogPreviewSection._muted,
              height: 1.45,
            ),
          ),
        ],
        const SizedBox(height: 18),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _Pill(
              icon: Icons.cloud_done_rounded,
              label: 'Hub feed snapshot',
              color: CatalogPreviewSection._accent,
            ),
            _Pill(
              icon: Icons.schedule_rounded,
              label: 'Stand $generatedLabel',
              color: CatalogPreviewSection._muted,
            ),
            _Pill(
              icon: Icons.photo_library_rounded,
              label: '${latestItems.length} Preview-Karten',
              color: CatalogPreviewSection._muted,
            ),
          ],
        ),
        if (featuredTags.isNotEmpty) ...[
          const SizedBox(height: 22),
          Text(
            'Top Tags',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: CatalogPreviewSection._muted,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 78,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) =>
                  _TagChip(tag: featuredTags[index]),
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemCount: featuredTags.length,
            ),
          ),
        ],
        const SizedBox(height: 26),
        _SectionHeader(
          title: 'Neu im Feed',
          subtitle: '${latestItems.length} aktuelle Produktkarten',
          showBrowseAction: showBrowseAction,
          onBrowseTap: onBrowseTap,
        ),
        const SizedBox(height: 14),
        _WallpaperGrid(items: latestItems, onItemTap: onItemTap),
        for (final shelf in shelves) ...[
          const SizedBox(height: 28),
          _SectionHeader(
            title: shelf.title.replaceAll('_', ' ').toUpperCase(),
            subtitle: shelf.subtitle,
            showBrowseAction: showBrowseAction,
            onBrowseTap: onBrowseTap,
          ),
          const SizedBox(height: 14),
          _WallpaperGrid(items: shelf.items, onItemTap: onItemTap),
        ],
      ],
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({
    required this.title,
    required this.description,
    required this.headline,
    required this.body,
    this.accent,
    this.loading = false,
  });

  final String title;
  final String? description;
  final String headline;
  final String body;
  final String? accent;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: CatalogPreviewSection._text,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (description != null) ...[
          const SizedBox(height: 10),
          Text(
            description!,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: CatalogPreviewSection._muted,
            ),
          ),
        ],
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: CatalogPreviewSection._card,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: CatalogPreviewSection._outline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (loading)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  if (loading) const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      headline,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: CatalogPreviewSection._text,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                body,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: CatalogPreviewSection._muted,
                ),
              ),
              if (accent != null) ...[
                const SizedBox(height: 10),
                Text(
                  accent!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: CatalogPreviewSection._accent,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.subtitle,
    required this.showBrowseAction,
    required this.onBrowseTap,
  });

  final String title;
  final String subtitle;
  final bool showBrowseAction;
  final VoidCallback? onBrowseTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: CatalogPreviewSection._text,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: CatalogPreviewSection._muted,
                ),
              ),
            ],
          ),
        ),
        if (showBrowseAction)
          TextButton.icon(
            onPressed: onBrowseTap,
            icon: const Icon(Icons.arrow_forward_rounded),
            label: const Text('Katalog'),
          ),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.tag});

  final CatalogTagSummary tag;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: CatalogPreviewSection._card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: CatalogPreviewSection._outline),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: tag.heroImageUrl == null
                ? Container(
                    width: 40,
                    height: 58,
                    color: CatalogPreviewSection._cardRaised,
                  )
                : Image.network(
                    tag.heroImageUrl!,
                    width: 40,
                    height: 58,
                    fit: BoxFit.cover,
                    webHtmlElementStrategy: WebHtmlElementStrategy.prefer,
                    errorBuilder: (_, __, ___) => Container(
                      width: 40,
                      height: 58,
                      color: CatalogPreviewSection._cardRaised,
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  tag.label.replaceAll('_', ' '),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: CatalogPreviewSection._text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${tag.count} Items',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: CatalogPreviewSection._muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WallpaperGrid extends StatelessWidget {
  const _WallpaperGrid({required this.items, this.onItemTap});

  final List<CatalogFeedItem> items;
  final ValueChanged<CatalogFeedItem>? onItemTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1100
            ? 4
            : constraints.maxWidth >= 760
            ? 3
            : 2;
        const spacing = 16.0;
        final width =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final item in items)
              SizedBox(
                width: width,
                child: CatalogWallpaperCard(item: item, onTap: onItemTap),
              ),
          ],
        );
      },
    );
  }
}

class CatalogWallpaperCard extends StatelessWidget {
  const CatalogWallpaperCard({required this.item, this.onTap, super.key});

  final CatalogFeedItem item;
  final ValueChanged<CatalogFeedItem>? onTap;

  Color get _tierColor => catalogTierColor(item.tierId);
  Color get _tierOnColor => catalogTierOnColor(item.tierId);
  String? get _tierBadgeAsset => catalogTierBadgeAsset(item.tierId);
  bool get _usesTierFrame => isPremiumCatalogTier(item.tierId);

  @override
  Widget build(BuildContext context) {
    final card = Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: _usesTierFrame
              ? _tierColor.withAlpha(160)
              : CatalogPreviewSection._outline,
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _usesTierFrame
              ? [
                  _tierColor.withAlpha(54),
                  CatalogPreviewSection._card,
                  CatalogPreviewSection._cardRaised,
                ]
              : [CatalogPreviewSection._card, CatalogPreviewSection._card],
        ),
        boxShadow: _usesTierFrame
            ? [
                BoxShadow(
                  color: _tierColor.withAlpha(34),
                  blurRadius: 18,
                  offset: const Offset(0, 10),
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.all(1.25),
        child: Container(
          decoration: BoxDecoration(
            color: CatalogPreviewSection._card,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _usesTierFrame
                  ? _tierColor.withAlpha(90)
                  : CatalogPreviewSection._outline,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    child: AspectRatio(
                      aspectRatio: 9 / 16,
                      child: item.previewImageUrl == null
                          ? _FallbackPreview()
                          : Image.network(
                              item.previewImageUrl!,
                              fit: BoxFit.cover,
                              webHtmlElementStrategy:
                                  WebHtmlElementStrategy.prefer,
                              errorBuilder: (_, __, ___) => _FallbackPreview(),
                              loadingBuilder: (context, child, progress) =>
                                  progress == null ? child : _FallbackPreview(),
                            ),
                    ),
                  ),
                  Positioned(
                    top: 14,
                    left: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _tierColor.withAlpha(230),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.black.withAlpha(28)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_tierBadgeAsset != null) ...[
                            Image.asset(
                              _tierBadgeAsset!,
                              width: 18,
                              height: 18,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(width: 7),
                          ],
                          Text(
                            item.tierLabel,
                            style: Theme.of(context).textTheme.labelLarge
                                ?.copyWith(
                                  color: _tierOnColor,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (item.previewVideoUrl != null)
                    Positioned(
                      top: 14,
                      right: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(130),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.smart_display_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Preview',
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: CatalogPreviewSection._text,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.description?.trim().isNotEmpty == true
                          ? item.description!
                          : 'Read-only Preview aus dem Live-Katalog.',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: CatalogPreviewSection._muted,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        _MetaChip(label: item.id),
                        if (item.tags.isNotEmpty)
                          _MetaChip(
                            label: item.tags.first.replaceAll('_', ' '),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (onTap == null) {
      return card;
    }

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap!(item),
        child: card,
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: CatalogPreviewSection._cardRaised,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: CatalogPreviewSection._muted),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: CatalogPreviewSection._card,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: CatalogPreviewSection._outline),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: CatalogPreviewSection._text,
            ),
          ),
        ],
      ),
    );
  }
}

class _FallbackPreview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color(0xFF0E2238),
            Color(0xFF154066),
            Color(0xFF1D5E88),
          ],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.motion_photos_on_rounded,
          size: 42,
          color: Colors.white.withAlpha(170),
        ),
      ),
    );
  }
}
