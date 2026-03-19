import 'package:flutter/material.dart';

class CatalogPreviewSection extends StatelessWidget {
  const CatalogPreviewSection({
    super.key,
    this.title = 'Videokatalog',
    this.description,
    this.includeSurface = false,
    this.showBrowseAction = false,
    this.onBrowseTap,
  });

  final String title;
  final String? description;
  final bool includeSurface;
  final bool showBrowseAction;
  final VoidCallback? onBrowseTap;

  static const Color _surfaceBase = Color(0xFF0A0F18);
  static const Color _surfaceCard = Color(0xFF121A28);
  static const Color _outlineSoft = Color(0xFF283348);
  static const Color _textPrimary = Color(0xFFF3F6FF);
  static const Color _textSecondary = Color(0xFFA8B3CB);
  static const Color _tierFree = Color(0xFF34B886);
  static const Color _tierGold = Color(0xFFBA9040);
  static const Color _tierAmethyst = Color(0xFF7D69D8);

  static const List<_FilterChipModel> _filters = <_FilterChipModel>[
    _FilterChipModel(
      id: 'all',
      iconAsset: 'assets/catalog/badges/badge_video.png',
      label: 'Alle',
    ),
    _FilterChipModel(
      id: 'free',
      iconAsset: 'assets/catalog/badges/tier_badge_free.png',
      label: 'Kostenlos',
    ),
    _FilterChipModel(
      id: 'gold',
      iconAsset: 'assets/catalog/badges/tier_badge_gold.png',
      label: 'Gold',
    ),
    _FilterChipModel(
      id: 'amethyst',
      iconAsset: 'assets/catalog/badges/tier_badge_amethyst.png',
      label: 'Amethyst',
    ),
    _FilterChipModel(
      id: 'owned',
      iconAsset: 'assets/catalog/badges/badge_gift_ready.png',
      label: 'Owned',
    ),
    _FilterChipModel(
      id: 'favorites',
      iconAsset: 'assets/catalog/badges/badge_favorites.png',
      label: 'Favoriten',
    ),
  ];

  static const List<_CatalogGroup> _groups = <_CatalogGroup>[
    _CatalogGroup(
      title: 'ANATOMY',
      ctaLabel: 'Mehr aus ANATOMY',
      items: <_PreviewItem>[
        _PreviewItem(
          title: 'Orbit Fold',
          tierLabel: 'Gold',
          tierIconAsset: 'assets/catalog/badges/tier_badge_gold.png',
          tierColor: _tierGold,
          glowColor: Color(0xFF5D9DFF),
          previewGradient: <Color>[
            Color(0xFF081527),
            Color(0xFF0D223D),
            Color(0xFF102E59),
          ],
          motif: _PreviewMotif.rings,
        ),
        _PreviewItem(
          title: 'Quiet Mammal',
          tierLabel: 'Gold',
          tierIconAsset: 'assets/catalog/badges/tier_badge_gold.png',
          tierColor: _tierGold,
          glowColor: Color(0xFF87C9FF),
          previewGradient: <Color>[
            Color(0xFF1A120E),
            Color(0xFF4F3623),
            Color(0xFF8C6643),
          ],
          motif: _PreviewMotif.orb,
        ),
        _PreviewItem(
          title: 'Drift Voyage',
          tierLabel: 'Gold',
          tierIconAsset: 'assets/catalog/badges/tier_badge_gold.png',
          tierColor: _tierGold,
          glowColor: Color(0xFF8FC8FF),
          previewGradient: <Color>[
            Color(0xFF142033),
            Color(0xFF1E3E66),
            Color(0xFF4D7FB9),
          ],
          motif: _PreviewMotif.sails,
          favorite: true,
        ),
      ],
    ),
    _CatalogGroup(
      title: 'ANIMALS',
      ctaLabel: 'Mehr aus ANIMALS',
      items: <_PreviewItem>[
        _PreviewItem(
          title: 'Signal Bloom',
          tierLabel: 'Amethyst',
          tierIconAsset: 'assets/catalog/badges/tier_badge_amethyst.png',
          tierColor: _tierAmethyst,
          glowColor: Color(0xFF54D1FF),
          previewGradient: <Color>[
            Color(0xFF140F26),
            Color(0xFF472061),
            Color(0xFF0E6BA8),
          ],
          motif: _PreviewMotif.portrait,
        ),
        _PreviewItem(
          title: 'Night Walker',
          tierLabel: 'Amethyst',
          tierIconAsset: 'assets/catalog/badges/tier_badge_amethyst.png',
          tierColor: _tierAmethyst,
          glowColor: Color(0xFF43BDFF),
          previewGradient: <Color>[
            Color(0xFF0E1525),
            Color(0xFF22365C),
            Color(0xFF0B8DD8),
          ],
          motif: _PreviewMotif.portrait,
        ),
        _PreviewItem(
          title: 'Jelly Current',
          tierLabel: 'Free',
          tierIconAsset: 'assets/catalog/badges/tier_badge_free.png',
          tierColor: _tierFree,
          glowColor: Color(0xFFA1E5FF),
          previewGradient: <Color>[
            Color(0xFF0A1622),
            Color(0xFF22455B),
            Color(0xFF9FD7F3),
          ],
          motif: _PreviewMotif.jelly,
          favorite: true,
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final section = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: _textPrimary,
                fontWeight: FontWeight.w800,
              ),
        ),
        if (description != null) ...[
          const SizedBox(height: 10),
          Text(
            description!,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: _textSecondary,
                  height: 1.45,
                ),
          ),
        ],
        const SizedBox(height: 18),
        _SearchSurface(),
        const SizedBox(height: 18),
        Text(
          'Freigeschaltete Inhalte',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: _textSecondary,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        _FilterRail(filters: _filters),
        const SizedBox(height: 24),
        for (final _CatalogGroup group in _groups) ...[
          _CatalogGroupBlock(
            group: group,
            showBrowseAction: showBrowseAction,
            onBrowseTap: onBrowseTap,
          ),
          const SizedBox(height: 28),
        ],
      ],
    );

    if (!includeSurface) {
      return section;
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        color: _surfaceBase,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _outlineSoft),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: section,
      ),
    );
  }
}

class _SearchSurface extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: CatalogPreviewSection._surfaceBase,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: CatalogPreviewSection._outlineSoft),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded,
              color: CatalogPreviewSection._textSecondary),
          const SizedBox(width: 12),
          Text(
            'Hintergrundbild suchen',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: CatalogPreviewSection._textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

class _FilterRail extends StatelessWidget {
  const _FilterRail({required this.filters});

  final List<_FilterChipModel> filters;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (int i = 0; i < filters.length; i++) ...[
            _FilterButton(
              filter: filters[i],
              selected: i == 0,
            ),
            if (i != filters.length - 1) const SizedBox(width: 10),
          ],
        ],
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.filter,
    required this.selected,
  });

  final _FilterChipModel filter;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: filter.label,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 62,
        height: 62,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: selected
              ? const RadialGradient(
                  center: Alignment.topLeft,
                  radius: 1.25,
                  colors: <Color>[
                    Color(0xFFF6F9FF),
                    Color(0x80FFFFFF),
                    Color(0x10FFFFFF),
                  ],
                )
              : null,
          color: selected ? null : Colors.transparent,
          border: Border.all(
            color: selected ? Colors.white : Colors.white.withAlpha(50),
            width: selected ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Image.asset(filter.iconAsset, fit: BoxFit.contain),
        ),
      ),
    );
  }
}

class _CatalogGroupBlock extends StatelessWidget {
  const _CatalogGroupBlock({
    required this.group,
    required this.showBrowseAction,
    this.onBrowseTap,
  });

  final _CatalogGroup group;
  final bool showBrowseAction;
  final VoidCallback? onBrowseTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                group.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: CatalogPreviewSection._textPrimary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
              ),
            ),
            if (showBrowseAction)
              _SectionCta(
                label: group.ctaLabel,
                onTap: onBrowseTap,
              ),
          ],
        ),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double width = constraints.maxWidth;
            int crossAxisCount = 2;
            if (width >= 1280) {
              crossAxisCount = 5;
            } else if (width >= 980) {
              crossAxisCount = 4;
            } else if (width >= 760) {
              crossAxisCount = 3;
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: group.items.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.58,
              ),
              itemBuilder: (BuildContext context, int index) {
                return _PreviewCard(item: group.items[index]);
              },
            );
          },
        ),
      ],
    );
  }
}

class _SectionCta extends StatelessWidget {
  const _SectionCta({
    required this.label,
    this.onTap,
  });

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF283B73),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: const Color(0xFF4E67A7)),
        ),
        child: Text(
          label,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: const Color(0xFF79A5FF),
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.item});

  final _PreviewItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: CatalogPreviewSection._surfaceCard,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: item.tierColor.withAlpha(38),
                borderRadius: BorderRadius.circular(22),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: item.tierColor.withAlpha(142), width: 2),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: item.previewGradient,
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: _PreviewArt(item: item),
            ),
          ),
          Positioned(
            top: 8,
            left: 8,
            child: SizedBox(
              width: 42,
              height: 42,
              child: Image.asset(item.tierIconAsset, fit: BoxFit.contain),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(92),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                item.favorite ? Icons.favorite_rounded : Icons.favorite_border,
                color: Colors.white.withAlpha(230),
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewArt extends StatelessWidget {
  const _PreviewArt({required this.item});

  final _PreviewItem item;

  @override
  Widget build(BuildContext context) {
    final List<Widget> layers = <Widget>[
      Positioned.fill(
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: RadialGradient(
              center: const Alignment(0, -0.6),
              radius: 1.15,
              colors: <Color>[
                item.glowColor.withAlpha(180),
                item.glowColor.withAlpha(28),
                Colors.transparent,
              ],
            ),
          ),
        ),
      ),
    ];

    switch (item.motif) {
      case _PreviewMotif.rings:
        layers.addAll(<Widget>[
          Positioned(
            left: 18,
            top: 90,
            child: Transform.rotate(
              angle: -0.35,
              child: Container(
                width: 132,
                height: 132,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: item.glowColor, width: 8),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: item.glowColor.withAlpha(120),
                      blurRadius: 30,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 36,
            top: 122,
            child: Transform.rotate(
              angle: -0.35,
              child: Container(
                width: 94,
                height: 94,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFF0503E), width: 6),
                ),
              ),
            ),
          ),
        ]);
      case _PreviewMotif.orb:
        layers.add(
          Positioned(
            right: 22,
            bottom: 40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: <Color>[
                    Colors.white.withAlpha(220),
                    item.glowColor.withAlpha(150),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        );
      case _PreviewMotif.sails:
        layers.addAll(<Widget>[
          Positioned(
            bottom: 30,
            right: 28,
            child: Container(
              width: 86,
              height: 130,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(30),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Color(0xFFF5E6C6),
                    Color(0xFFBE9A61),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 24,
            right: 94,
            child: Container(
              width: 2,
              height: 146,
              color: Colors.white.withAlpha(180),
            ),
          ),
        ]);
      case _PreviewMotif.portrait:
        layers.addAll(<Widget>[
          Positioned(
            left: 34,
            top: 54,
            child: Container(
              width: 120,
              height: 190,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(80),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Colors.white.withAlpha(170),
                    item.glowColor.withAlpha(110),
                    Colors.black.withAlpha(70),
                  ],
                ),
              ),
            ),
          ),
        ]);
      case _PreviewMotif.jelly:
        layers.addAll(<Widget>[
          Positioned(
            right: 26,
            top: 62,
            child: Container(
              width: 118,
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(64),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    Colors.white.withAlpha(150),
                    item.glowColor.withAlpha(120),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
        ]);
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: Stack(children: layers),
    );
  }
}

enum _PreviewMotif { rings, orb, sails, portrait, jelly }

class _FilterChipModel {
  const _FilterChipModel({
    required this.id,
    required this.iconAsset,
    required this.label,
  });

  final String id;
  final String iconAsset;
  final String label;
}

class _CatalogGroup {
  const _CatalogGroup({
    required this.title,
    required this.ctaLabel,
    required this.items,
  });

  final String title;
  final String ctaLabel;
  final List<_PreviewItem> items;
}

class _PreviewItem {
  const _PreviewItem({
    required this.title,
    required this.tierLabel,
    required this.tierIconAsset,
    required this.tierColor,
    required this.glowColor,
    required this.previewGradient,
    required this.motif,
    this.favorite = false,
  });

  final String title;
  final String tierLabel;
  final String tierIconAsset;
  final Color tierColor;
  final Color glowColor;
  final List<Color> previewGradient;
  final _PreviewMotif motif;
  final bool favorite;
}
