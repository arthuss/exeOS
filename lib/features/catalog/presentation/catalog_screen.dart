import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'widgets/catalog_preview_section.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Catalog')),
    body: ListView(
      padding: EdgeInsets.fromLTRB(24, 24, 24, 32),
      children: [
        CatalogPreviewSection(
          title: 'Wallpaper catalog',
          description:
              'Read-only Feed aus dem Hub. Die Vorschaukarten kommen jetzt direkt aus den exportierten Produkt-Feeds und bleiben bewusst bildzentriert.',
          layout: CatalogPreviewLayout.full,
          onItemTap: (item) => context.push('/catalog/${item.id}', extra: item),
        ),
      ],
    ),
  );
}
