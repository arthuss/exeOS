import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/catalog_feed_repository.dart';
import 'widgets/catalog_preview_section.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _query = '';
  String? _selectedTier;
  String? _selectedTag;
  String? _selectedCollection;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearFilters() {
    setState(() {
      _query = '';
      _selectedTier = null;
      _selectedTag = null;
      _selectedCollection = null;
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('dotexe'),
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
              CatalogPreviewSection.accentColor.withAlpha(18),
              CatalogPreviewSection.baseColor,
              CatalogPreviewSection.baseColor,
            ],
          ),
        ),
        child: FutureBuilder<CatalogPageData>(
          future: catalogFeedRepository.loadPageData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const _CatalogLoadState(
                title: 'Katalog wird geladen',
                body:
                    'Der Vollkatalog wird direkt aus den exportierten Hub-Feeds aufgebaut.',
                loading: true,
              );
            }

            if (!snapshot.hasData) {
              return _CatalogLoadState(
                title: 'Feed nicht bereit',
                body:
                    snapshot.error?.toString() ??
                    'Die Katalogdaten konnten nicht geladen werden.',
              );
            }

            return _CatalogBrowser(
              data: snapshot.data!,
              query: _query,
              selectedTier: _selectedTier,
              selectedTag: _selectedTag,
              selectedCollection: _selectedCollection,
              searchController: _searchController,
              onQueryChanged: (value) => setState(() => _query = value),
              onTierSelected: (value) => setState(() => _selectedTier = value),
              onTagSelected: (value) => setState(() => _selectedTag = value),
              onCollectionSelected: (value) =>
                  setState(() => _selectedCollection = value),
              onClearFilters: _clearFilters,
            );
          },
        ),
      ),
    );
  }
}

class _CatalogBrowser extends StatelessWidget {
  const _CatalogBrowser({
    required this.data,
    required this.query,
    required this.selectedTier,
    required this.selectedTag,
    required this.selectedCollection,
    required this.searchController,
    required this.onQueryChanged,
    required this.onTierSelected,
    required this.onTagSelected,
    required this.onCollectionSelected,
    required this.onClearFilters,
  });

  final CatalogPageData data;
  final String query;
  final String? selectedTier;
  final String? selectedTag;
  final String? selectedCollection;
  final TextEditingController searchController;
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<String?> onTierSelected;
  final ValueChanged<String?> onTagSelected;
  final ValueChanged<String?> onCollectionSelected;
  final VoidCallback onClearFilters;

  static const List<_TierOption> _tierOptions = <_TierOption>[
    _TierOption(id: null, label: 'Alle'),
    _TierOption(id: 'free', label: 'Free'),
    _TierOption(id: 'gold', label: 'Gold'),
    _TierOption(id: 'amethyst', label: 'Amethyst'),
    _TierOption(id: 'onyx', label: 'Onyx'),
    _TierOption(id: 'platinum', label: 'Platinum'),
  ];

  @override
  Widget build(BuildContext context) {
    final filteredItems = _filterItems(data.allItems);
    final featuredTags = data.featuredTags.take(12).toList(growable: false);
    final collectionOptions = _buildCollectionOptions(data.allItems);
    final generatedAt = data.generatedAt;
    final generatedLabel = generatedAt == null
        ? 'unbekannt'
        : '${generatedAt.day.toString().padLeft(2, '0')}.${generatedAt.month.toString().padLeft(2, '0')}.${generatedAt.year} ${generatedAt.hour.toString().padLeft(2, '0')}:${generatedAt.minute.toString().padLeft(2, '0')}';
    final hasActiveFilters =
        query.trim().isNotEmpty ||
        selectedTier != null ||
        selectedTag != null ||
        selectedCollection != null;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wallpaper Catalog',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: CatalogPreviewSection.textColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Der Web-Start landet jetzt direkt auf dem Vollkatalog statt auf einer separaten Landing-Teaserflaeche.',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: CatalogPreviewSection.mutedColor,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _InfoPill(
                      icon: Icons.grid_view_rounded,
                      label: '${data.allItems.length} Wallpapers gesamt',
                      tone: CatalogPreviewSection.accentColor,
                    ),
                    _InfoPill(
                      icon: Icons.schedule_rounded,
                      label: 'Stand $generatedLabel',
                      tone: CatalogPreviewSection.mutedColor,
                    ),
                    _InfoPill(
                      icon: Icons.filter_alt_rounded,
                      label: '${filteredItems.length} Treffer',
                      tone: CatalogPreviewSection.mutedColor,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _SearchBox(
                  controller: searchController,
                  onChanged: onQueryChanged,
                  showClear: query.trim().isNotEmpty,
                ),
                const SizedBox(height: 20),
                _FilterSection(
                  title: 'Tier',
                  children: _tierOptions.map((option) {
                    return ChoiceChip(
                      label: Text(option.label),
                      selected: selectedTier == option.id,
                      onSelected: (_) => onTierSelected(
                        selectedTier == option.id ? null : option.id,
                      ),
                    );
                  }).toList(growable: false),
                ),
                if (collectionOptions.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _FilterSection(
                    title: 'Collections',
                    children: collectionOptions.map((collection) {
                      return ChoiceChip(
                        label: Text(collection),
                        selected: selectedCollection == collection,
                        onSelected: (_) => onCollectionSelected(
                          selectedCollection == collection ? null : collection,
                        ),
                      );
                    }).toList(growable: false),
                  ),
                ],
                if (featuredTags.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _FilterSection(
                    title: 'Tags',
                    children: featuredTags.map((tag) {
                      final label = tag.label.replaceAll('_', ' ');
                      return ChoiceChip(
                        label: Text(label),
                        selected: selectedTag == tag.slug,
                        onSelected: (_) => onTagSelected(
                          selectedTag == tag.slug ? null : tag.slug,
                        ),
                      );
                    }).toList(growable: false),
                  ),
                ],
                if (hasActiveFilters) ...[
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: onClearFilters,
                      icon: const Icon(Icons.clear_all_rounded),
                      label: const Text('Filter zuruecksetzen'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (filteredItems.isEmpty)
          const SliverFillRemaining(
            hasScrollBody: false,
            child: _EmptyCatalogState(),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate((context, index) {
                final item = filteredItems[index];
                return CatalogWallpaperCard(
                  item: item,
                  onTap: (selectedItem) =>
                      context.push('/catalog/${selectedItem.id}', extra: selectedItem),
                );
              }, childCount: filteredItems.length),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 320,
                mainAxisExtent: 470,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
            ),
          ),
      ],
    );
  }

  List<String> _buildCollectionOptions(List<CatalogFeedItem> items) {
    final counts = <String, int>{};
    for (final item in items) {
      for (final raw in item.collections) {
        final value = raw.trim();
        if (value.isEmpty) {
          continue;
        }
        counts.update(value, (current) => current + 1, ifAbsent: () => 1);
      }
    }

    final entries = counts.entries.toList(growable: false)
      ..sort((a, b) {
        final countCompare = b.value.compareTo(a.value);
        if (countCompare != 0) {
          return countCompare;
        }
        return a.key.compareTo(b.key);
      });
    return entries.map((entry) => entry.key).take(12).toList(growable: false);
  }

  List<CatalogFeedItem> _filterItems(List<CatalogFeedItem> items) {
    final normalizedQuery = query.trim().toLowerCase();
    final filtered = items.where((item) {
      final normalizedTier = _resolveTierId(item);
      if (selectedTier != null && normalizedTier != selectedTier) {
        return false;
      }
      if (selectedTag != null &&
          !item.tags.any((tag) => tag.trim().toLowerCase() == selectedTag)) {
        return false;
      }
      if (selectedCollection != null &&
          !item.collections.any(
            (collection) =>
                collection.trim().toLowerCase() ==
                selectedCollection!.trim().toLowerCase(),
          )) {
        return false;
      }
      if (normalizedQuery.isEmpty) {
        return true;
      }
      final haystack = <String>[
        item.title,
        item.description ?? '',
        ...item.tags,
        ...item.collections,
        item.tierLabel,
      ].join(' ').toLowerCase();
      return haystack.contains(normalizedQuery);
    }).toList(growable: false);

    filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return filtered;
  }

  String _resolveTierId(CatalogFeedItem item) {
    final normalized = item.tierId?.trim().toLowerCase();
    if (normalized != null && normalized.isNotEmpty) {
      return normalized;
    }
    return item.requiresSubscription ? 'subscription' : 'free';
  }
}

class _CatalogLoadState extends StatelessWidget {
  const _CatalogLoadState({
    required this.title,
    required this.body,
    this.loading = false,
  });

  final String title;
  final String body;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: CatalogPreviewSection.cardColor,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: CatalogPreviewSection.outlineColor),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (loading)
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              if (loading) const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: CatalogPreviewSection.textColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      body,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: CatalogPreviewSection.mutedColor,
                      ),
                    ),
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

class _SearchBox extends StatelessWidget {
  const _SearchBox({
    required this.controller,
    required this.onChanged,
    this.showClear = false,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool showClear;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      style: const TextStyle(color: CatalogPreviewSection.textColor),
      decoration: InputDecoration(
        hintText: 'Search wallpapers, tags, collections',
        hintStyle: const TextStyle(color: CatalogPreviewSection.mutedColor),
        prefixIcon: const Icon(
          Icons.search_rounded,
          color: CatalogPreviewSection.accentColor,
        ),
        suffixIcon: !showClear
            ? null
            : IconButton(
                tooltip: 'Suche leeren',
                onPressed: () {
                  controller.clear();
                  onChanged('');
                },
                icon: const Icon(Icons.close_rounded),
              ),
        filled: true,
        fillColor: CatalogPreviewSection.cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: CatalogPreviewSection.outlineColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: CatalogPreviewSection.outlineColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: CatalogPreviewSection.accentColor),
        ),
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: CatalogPreviewSection.textColor,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(spacing: 10, runSpacing: 10, children: children),
      ],
    );
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
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyCatalogState extends StatelessWidget {
  const _EmptyCatalogState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 560),
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: CatalogPreviewSection.cardColor,
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: CatalogPreviewSection.outlineColor),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.filter_alt_off_rounded,
              size: 36,
              color: CatalogPreviewSection.accentColor,
            ),
            const SizedBox(height: 14),
            Text(
              'Keine Treffer',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: CatalogPreviewSection.textColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Die aktuelle Kombination aus Suche, Tier, Collection und Tag liefert keine Wallpapers.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: CatalogPreviewSection.mutedColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TierOption {
  const _TierOption({required this.id, required this.label});

  final String? id;
  final String label;
}
