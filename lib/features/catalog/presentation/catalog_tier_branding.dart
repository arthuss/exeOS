import 'package:flutter/material.dart';

String? normalizeCatalogTierId(String? tierId) {
  final normalized = tierId?.trim().toLowerCase();
  if (normalized == null || normalized.isEmpty) {
    return null;
  }
  return normalized;
}

bool isPremiumCatalogTier(String? tierId) {
  final normalized = normalizeCatalogTierId(tierId);
  return normalized != null && normalized != 'free';
}

Color catalogTierColor(String? tierId) {
  switch (normalizeCatalogTierId(tierId)) {
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
    case 'test':
      return const Color(0xFF63D5FF);
    default:
      return const Color(0xFF63D5FF);
  }
}

Color catalogTierOnColor(String? tierId) {
  switch (normalizeCatalogTierId(tierId)) {
    case 'platinum':
      return Colors.black;
    default:
      return Colors.white;
  }
}

String? catalogTierBadgeAsset(String? tierId) {
  switch (normalizeCatalogTierId(tierId)) {
    case 'free':
      return 'assets/catalog/badges/tier_badge_free.png';
    case 'gold':
      return 'assets/catalog/badges/tier_badge_gold.png';
    case 'amethyst':
      return 'assets/catalog/badges/tier_badge_amethyst.png';
    case 'onyx':
      return 'assets/catalog/badges/tier_badge_onyx.png';
    case 'platinum':
      return 'assets/catalog/badges/tier_badge_platinum.png';
    case 'test':
      return 'assets/catalog/badges/tier_badge_test.png';
    default:
      return null;
  }
}
