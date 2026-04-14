import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../legal/presentation/widgets/legal_footer.dart';
import '../data/catalog_feed_repository.dart';
import 'catalog_links.dart';
import 'catalog_tier_branding.dart';
import 'widgets/catalog_preview_section.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _query = '';
  String? _selectedTier;
  String? _selectedTag;
  String? _selectedCollection;

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
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
        title: const Text('dotexe.pro'),
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
              scrollController: _scrollController,
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
    required this.scrollController,
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

  final ScrollController scrollController;
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
    _TierOption(
      id: 'free',
      label: 'Free',
      assetPath: 'assets/catalog/badges/tier_badge_free.png',
    ),
    _TierOption(
      id: 'gold',
      label: 'Gold',
      assetPath: 'assets/catalog/badges/tier_badge_gold.png',
    ),
    _TierOption(
      id: 'amethyst',
      label: 'Amethyst',
      assetPath: 'assets/catalog/badges/tier_badge_amethyst.png',
    ),
    _TierOption(
      id: 'onyx',
      label: 'Onyx',
      assetPath: 'assets/catalog/badges/tier_badge_onyx.png',
    ),
    _TierOption(
      id: 'platinum',
      label: 'Platinum',
      assetPath: 'assets/catalog/badges/tier_badge_platinum.png',
    ),
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
      controller: scrollController,
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktopWidth(context) ? 22 : 20,
                    vertical: isDesktopWidth(context) ? 18 : 20,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: CatalogPreviewSection.accentColor.withAlpha(90),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        CatalogPreviewSection.accentColor.withAlpha(36),
                        CatalogPreviewSection.cardRaisedColor,
                        CatalogPreviewSection.baseColor,
                      ],
                    ),
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 980;
                      final visualWidth = (constraints.maxWidth * 0.31).clamp(
                        280.0,
                        390.0,
                      );
                      final content = _CatalogHeroContent(
                        isWide: isWide,
                        onLaunchPlay: _launchPlayStoreListing,
                      );
                      final visual = _CatalogHeroVisual(isWide: isWide);

                      if (!isWide) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            content,
                            const SizedBox(height: 24),
                            visual,
                          ],
                        );
                      }

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(child: content),
                          const SizedBox(width: 22),
                          SizedBox(width: visualWidth, child: visual),
                        ],
                      );
                    },
                  ),
                ),
                const SizedBox(height: 18),
                _CatalogBridge(
                  generatedLabel: generatedLabel,
                  totalCount: data.allItems.length,
                  filteredCount: filteredItems.length,
                ),
                const SizedBox(height: 28),
                _SearchBox(
                  controller: searchController,
                  onChanged: onQueryChanged,
                  showClear: query.trim().isNotEmpty,
                ),
                const SizedBox(height: 20),
                _FilterSection(
                  title: 'Tier',
                  children: _tierOptions
                      .map((option) {
                        final tone = option.id == null
                            ? CatalogPreviewSection.outlineColor
                            : catalogTierColor(option.id);
                        return ChoiceChip(
                          avatar: option.assetPath == null
                              ? null
                              : Image.asset(
                                  option.assetPath!,
                                  width: 22,
                                  height: 22,
                                  fit: BoxFit.contain,
                                ),
                          label: Text(option.label),
                          labelStyle: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(
                                color: CatalogPreviewSection.textColor,
                                fontWeight: selectedTier == option.id
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                              ),
                          backgroundColor: CatalogPreviewSection.cardColor,
                          selectedColor: tone.withAlpha(40),
                          showCheckmark: false,
                          side: BorderSide(
                            color: selectedTier == option.id
                                ? tone
                                : CatalogPreviewSection.outlineColor,
                          ),
                          selected: selectedTier == option.id,
                          onSelected: (_) => onTierSelected(
                            selectedTier == option.id ? null : option.id,
                          ),
                        );
                      })
                      .toList(growable: false),
                ),
                if (collectionOptions.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _FilterSection(
                    title: 'Collections',
                    children: collectionOptions
                        .map((collection) {
                          return ChoiceChip(
                            label: Text(collection),
                            selected: selectedCollection == collection,
                            onSelected: (_) => onCollectionSelected(
                              selectedCollection == collection
                                  ? null
                                  : collection,
                            ),
                          );
                        })
                        .toList(growable: false),
                  ),
                ],
                if (featuredTags.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _FilterSection(
                    title: 'Tags',
                    children: featuredTags
                        .map((tag) {
                          final label = tag.label.replaceAll('_', ' ');
                          return ChoiceChip(
                            label: Text(label),
                            selected: selectedTag == tag.slug,
                            onSelected: (_) => onTagSelected(
                              selectedTag == tag.slug ? null : tag.slug,
                            ),
                          );
                        })
                        .toList(growable: false),
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
          const SliverPadding(
            padding: EdgeInsets.fromLTRB(24, 0, 24, 24),
            sliver: SliverToBoxAdapter(child: _EmptyCatalogState()),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate((context, index) {
                final item = filteredItems[index];
                return CatalogWallpaperCard(
                  item: item,
                  onTap: (selectedItem) => context.push(
                    '/w/${selectedItem.canonicalRef}',
                    extra: selectedItem,
                  ),
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
        const SliverPadding(
          padding: EdgeInsets.fromLTRB(24, 0, 24, 36),
          sliver: SliverToBoxAdapter(child: LegalFooter()),
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
    final queryCandidates = _buildSearchCandidates(query);
    final filtered = items
        .where((item) {
          final normalizedTier = _resolveTierId(item);
          if (selectedTier != null && normalizedTier != selectedTier) {
            return false;
          }
          if (selectedTag != null &&
              !item.tags.any(
                (tag) => tag.trim().toLowerCase() == selectedTag,
              )) {
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
          if (queryCandidates.isEmpty) {
            return true;
          }
          final haystacks = _buildSearchHaystacks(item);
          return queryCandidates.any(
            (candidate) =>
                haystacks.any((haystack) => haystack.contains(candidate)),
          );
        })
        .toList(growable: false);

    filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return filtered;
  }

  List<String> _buildSearchHaystacks(CatalogFeedItem item) {
    final values = <String>{
      _canonicalizeSearchText(item.id),
      _canonicalizeSearchText(item.canonicalRef),
      _canonicalizeSearchText(item.title),
      _canonicalizeSearchText(item.displayTitle),
      _canonicalizeSearchText(item.description ?? ''),
      _canonicalizeSearchText(item.displayDescription ?? ''),
      _canonicalizeSearchText(item.tierLabel),
      ...item.tags.map(_canonicalizeSearchText),
      ...item.collections.map(_canonicalizeSearchText),
      ..._buildProductAliases(item.id),
      ..._buildProductAliases(item.canonicalRef),
    };
    return values.where((value) => value.isNotEmpty).toList(growable: false);
  }

  List<String> _buildSearchCandidates(String rawQuery) {
    final normalized = _canonicalizeSearchText(rawQuery);
    if (normalized.isEmpty) {
      return const <String>[];
    }
    return <String>{
      normalized,
      ..._buildProductAliases(rawQuery),
    }.where((value) => value.isNotEmpty).toList(growable: false);
  }

  List<String> _buildProductAliases(String rawValue) {
    final normalized = _canonicalizeSearchText(rawValue);
    if (normalized.isEmpty) {
      return const <String>[];
    }

    final compact = normalized.replaceAll(' ', '');
    final digits = RegExp(
      r'\d+',
    ).allMatches(compact).map((match) => match.group(0) ?? '').join();

    final aliases = <String>{normalized, compact};
    if (digits.isNotEmpty) {
      aliases.add(digits);
      aliases.add('product$digits');
      aliases.add('product $digits');
    }
    return aliases.where((value) => value.isNotEmpty).toList(growable: false);
  }

  String _canonicalizeSearchText(String raw) {
    return raw
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
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
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
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
          borderSide: const BorderSide(
            color: CatalogPreviewSection.outlineColor,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: CatalogPreviewSection.outlineColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: CatalogPreviewSection.accentColor,
          ),
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

class _CatalogHeroContent extends StatelessWidget {
  const _CatalogHeroContent({required this.isWide, required this.onLaunchPlay});

  final bool isWide;
  final VoidCallback onLaunchPlay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: const [
            _InfoPill(
              icon: Icons.verified_rounded,
              label: 'Official Android live wallpaper catalog',
              tone: CatalogPreviewSection.accentColor,
            ),
            _InfoPill(
              icon: Icons.rocket_launch_rounded,
              label: 'Production launch in under a week',
              tone: Color(0xFFFFC857),
            ),
          ],
        ),
        SizedBox(height: isWide ? 16 : 18),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/branding/play_store_512.png',
              width: isWide ? 64 : 52,
              height: isWide ? 64 : 52,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                'dotexe.pro',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontSize: isWide ? 30 : 26,
                  color: CatalogPreviewSection.textColor,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Animated live wallpapers for Android',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontSize: isWide ? 26 : 24,
            color: CatalogPreviewSection.textColor,
            fontWeight: FontWeight.w700,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Explore fantasy, sci-fi, AMOLED and premium motion wallpapers in one live catalog. Install the Android app on Google Play and jump straight into the feed below.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: CatalogPreviewSection.mutedColor,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: onLaunchPlay,
          icon: const Icon(Icons.android_rounded),
          label: const Text(catalogPrimaryInstallLabel),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Official site by exeget · Android app · Deep links · Full wallpaper catalog',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: CatalogPreviewSection.mutedColor,
          ),
        ),
      ],
    );
  }
}

class _CatalogHeroVisual extends StatelessWidget {
  const _CatalogHeroVisual({required this.isWide});

  final bool isWide;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isWide ? 8 : 10),
      decoration: BoxDecoration(
        color: CatalogPreviewSection.cardColor.withAlpha(160),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: CatalogPreviewSection.outlineColor.withAlpha(180),
        ),
        boxShadow: [
          BoxShadow(
            color: CatalogPreviewSection.accentColor.withAlpha(14),
            blurRadius: 22,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: AspectRatio(
        aspectRatio: isWide ? 1.86 : 1.28,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            Expanded(
              child: _HeroTileCard(
                assetPath: 'assets/branding/hero_tile_1.jpg',
                topInset: 10,
                bottomInset: 30,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _HeroTileCard(
                assetPath: 'assets/branding/hero_tile_2.jpg',
                topInset: 0,
                bottomInset: 18,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _HeroTileCard(
                assetPath: 'assets/branding/hero_tile_4.jpg',
                topInset: 18,
                bottomInset: 10,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: _HeroTileCard(
                assetPath: 'assets/branding/hero_tile_5.jpg',
                topInset: 6,
                bottomInset: 42,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

bool isDesktopWidth(BuildContext context) =>
    MediaQuery.sizeOf(context).width >= 980;

class _HeroTileCard extends StatelessWidget {
  const _HeroTileCard({
    required this.assetPath,
    required this.topInset,
    required this.bottomInset,
  });

  final String assetPath;
  final double topInset;
  final double bottomInset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: topInset, bottom: bottomInset),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withAlpha(18)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(32),
              blurRadius: 16,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Image.asset(assetPath, fit: BoxFit.cover),
        ),
      ),
    );
  }
}

class _CatalogBridge extends StatelessWidget {
  const _CatalogBridge({
    required this.generatedLabel,
    required this.totalCount,
    required this.filteredCount,
  });

  final String generatedLabel;
  final int totalCount;
  final int filteredCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
      decoration: BoxDecoration(
        color: CatalogPreviewSection.cardColor.withAlpha(140),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: CatalogPreviewSection.outlineColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Browse the full wallpaper catalog',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: CatalogPreviewSection.textColor,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Search by tier, collection and tags, then jump straight into the live feed.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: CatalogPreviewSection.mutedColor,
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _InfoPill(
                icon: Icons.grid_view_rounded,
                label: '$totalCount Wallpapers gesamt',
                tone: CatalogPreviewSection.accentColor,
              ),
              _InfoPill(
                icon: Icons.schedule_rounded,
                label: 'Stand $generatedLabel',
                tone: CatalogPreviewSection.mutedColor,
              ),
              _InfoPill(
                icon: Icons.filter_alt_rounded,
                label: '$filteredCount Treffer',
                tone: CatalogPreviewSection.mutedColor,
              ),
            ],
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
  const _TierOption({required this.id, required this.label, this.assetPath});

  final String? id;
  final String label;
  final String? assetPath;
}

Future<void> _launchPlayStoreListing() async {
  await launchUrl(catalogPrimaryInstallUri, mode: LaunchMode.platformDefault);
}
