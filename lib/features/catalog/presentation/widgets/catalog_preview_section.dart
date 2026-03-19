import 'package:flutter/material.dart';

class CatalogPreviewSection extends StatelessWidget {
  const CatalogPreviewSection({
    super.key,
    this.title = 'Preview catalog',
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

  static const List<_PreviewItem> _items = <_PreviewItem>[
    _PreviewItem(
      title: 'Astral Portals',
      tier: 'Free',
      accent: Color(0xFF58B7FF),
      shadow: Color(0xFF102B50),
    ),
    _PreviewItem(
      title: 'Frozen Signals',
      tier: 'Gold',
      accent: Color(0xFF89E0FF),
      shadow: Color(0xFF163F6A),
    ),
    _PreviewItem(
      title: 'Neon Warden',
      tier: 'Amethyst',
      accent: Color(0xFF4EA0FF),
      shadow: Color(0xFF0F2845),
    ),
    _PreviewItem(
      title: 'Void Signals',
      tier: 'Free',
      accent: Color(0xFF74C8FF),
      shadow: Color(0xFF12273F),
    ),
    _PreviewItem(
      title: 'Cloud Relay',
      tier: 'Gold',
      accent: Color(0xFF7AB4FF),
      shadow: Color(0xFF173154),
    ),
    _PreviewItem(
      title: 'Blue Current',
      tier: 'Free',
      accent: Color(0xFF95EDFF),
      shadow: Color(0xFF14314C),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final section = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.headlineSmall),
                  if (description != null) ...[
                    const SizedBox(height: 10),
                    Text(
                      description!,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (showBrowseAction)
              TextButton.icon(
                onPressed: onBrowseTap,
                icon: const Icon(Icons.open_in_new_rounded),
                label: const Text('Browse all'),
              ),
          ],
        ),
        const SizedBox(height: 18),
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
        const SizedBox(height: 18),
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double width = constraints.maxWidth;
            int crossAxisCount = 2;
            if (width >= 1200) {
              crossAxisCount = 5;
            } else if (width >= 900) {
              crossAxisCount = 4;
            } else if (width >= 640) {
              crossAxisCount = 3;
            }

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _items.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.62,
              ),
              itemBuilder: (BuildContext context, int index) {
                return _PreviewCard(item: _items[index]);
              },
            );
          },
        ),
      ],
    );

    if (!includeSurface) {
      return section;
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: section,
      ),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.item});

  final _PreviewItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  item.shadow,
                  const Color(0xFF081120),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.7),
                  radius: 1.0,
                  colors: [
                    item.accent.withAlpha(190),
                    item.accent.withAlpha(24),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 18,
            left: 18,
            right: 18,
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(120),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: item.accent.withAlpha(160),
                    ),
                  ),
                  child: Text(
                    item.tier,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(110),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child:
                      const Icon(Icons.play_arrow_rounded, color: Colors.white),
                ),
              ],
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 26,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Image-first placeholder card for the first web rollout. Feed-backed previews replace this shell next.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white.withAlpha(190),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 76,
            bottom: 96,
            left: 24,
            right: 24,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: item.accent.withAlpha(220), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: item.accent.withAlpha(110),
                    blurRadius: 30,
                    spreadRadius: 1,
                  ),
                ],
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withAlpha(32),
                    item.accent.withAlpha(18),
                    Colors.black.withAlpha(24),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 16,
                    top: 18,
                    child: Container(
                      width: 72,
                      height: 140,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.white.withAlpha(130)),
                        color: Colors.black.withAlpha(40),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 18,
                    top: 32,
                    child: Container(
                      width: 92,
                      height: 160,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: Colors.white.withAlpha(180)),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.white.withAlpha(120),
                            item.accent.withAlpha(70),
                            Colors.black.withAlpha(50),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border:
                      Border.all(color: scheme.outlineVariant.withAlpha(90)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PreviewItem {
  const _PreviewItem({
    required this.title,
    required this.tier,
    required this.accent,
    required this.shadow,
  });

  final String title;
  final String tier;
  final Color accent;
  final Color shadow;
}
