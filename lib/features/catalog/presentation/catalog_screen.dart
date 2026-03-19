import 'package:flutter/material.dart';

import 'widgets/catalog_preview_section.dart';

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Catalog'),
        ),
        body: ListView(
          padding: EdgeInsets.fromLTRB(24, 24, 24, 32),
          children: const [
            CatalogPreviewSection(
              title: 'Wallpaper catalog',
              description:
                  'Phase A keeps the web catalog read-only and image-first. Real feed-backed preview images replace these placeholders in the next integration step.',
            ),
          ],
        ),
      );
}
