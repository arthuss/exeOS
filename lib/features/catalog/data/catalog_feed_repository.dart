import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

final CatalogFeedRepository catalogFeedRepository = CatalogFeedRepository();

class CatalogFeedRepository {
  CatalogFeedRepository({http.Client? client, Uri? baseUri})
    : _client = client ?? http.Client(),
      _baseUri = baseUri ?? _resolveBaseUri();

  final http.Client _client;
  final Uri _baseUri;

  CatalogPageData? _cache;
  Future<CatalogPageData>? _pending;

  Future<CatalogPageData> loadPageData({bool forceRefresh = false}) {
    if (!forceRefresh && _cache != null) {
      return SynchronousFuture<CatalogPageData>(_cache!);
    }
    if (!forceRefresh && _pending != null) {
      return _pending!;
    }

    final future = _load();
    _pending = future;
    future
        .then((value) {
          _cache = value;
          _pending = null;
        })
        .catchError((_) {
          _pending = null;
        });
    return future;
  }

  static Uri _resolveBaseUri() {
    final base = Uri.base;
    if (base.hasScheme && (base.scheme == 'http' || base.scheme == 'https')) {
      return base.resolve('/feeds/');
    }
    return Uri.parse('https://www.dotexe.pro/feeds/');
  }

  Future<CatalogPageData> _load() async {
    final curatedMeta = await _getJson('curated.json');
    final latestFeed = await _getJson('curated/last-updated/premium.json');
    final tagsMeta = await _getJson('tags.json');

    final tags = _parseTags(tagsMeta['tags']);
    final featuredTags = tags
        .where((tag) => tag.heroImageUrl != null)
        .take(8)
        .toList(growable: false);
    final shelves = <CatalogShelf>[];

    for (final tag in featuredTags.take(4)) {
      final feed = await _loadTagFeed(tag.slug);
      if (feed.items.isEmpty) {
        continue;
      }
      shelves.add(
        CatalogShelf(
          id: tag.slug,
          title: tag.label,
          subtitle: '${tag.count} Wallpapers',
          items: feed.items,
        ),
      );
    }

    return CatalogPageData(
      generatedAt: _parseDateTime(curatedMeta['generatedAt']),
      latestItems: CatalogFeed.fromJson(latestFeed).items,
      featuredTags: featuredTags,
      shelves: shelves,
      sourceBaseUrl: _baseUri.toString(),
    );
  }

  Future<CatalogFeed> _loadTagFeed(String slug) async {
    for (final bucket in const <String>['premium', 'standard', 'free']) {
      final json = await _getJson('tags/$slug/$bucket.json');
      final feed = CatalogFeed.fromJson(json);
      if (feed.items.isNotEmpty) {
        return feed;
      }
    }
    return const CatalogFeed(items: <CatalogFeedItem>[]);
  }

  Future<Map<String, dynamic>> _getJson(String relativePath) async {
    final response = await _client.get(
      _baseUri.resolve(relativePath),
      headers: const <String, String>{'accept': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw CatalogFeedException(
        'Feed $relativePath antwortete mit ${response.statusCode}. '
        'Vor lokalem Web-Start zuerst scripts/sync-hub-feeds.ps1 ausfuehren.',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw CatalogFeedException(
        'Feed $relativePath hat kein gueltiges JSON-Objekt.',
      );
    }
    return decoded;
  }

  static List<CatalogTagSummary> _parseTags(Object? value) {
    if (value is! List) {
      return const <CatalogTagSummary>[];
    }
    return value
        .whereType<Map<String, dynamic>>()
        .map(CatalogTagSummary.fromJson)
        .toList(growable: false);
  }

  static DateTime? _parseDateTime(Object? value) {
    if (value is! String || value.isEmpty) {
      return null;
    }
    return DateTime.tryParse(value);
  }
}

class CatalogPageData {
  const CatalogPageData({
    required this.latestItems,
    required this.featuredTags,
    required this.shelves,
    required this.sourceBaseUrl,
    this.generatedAt,
  });

  final DateTime? generatedAt;
  final List<CatalogFeedItem> latestItems;
  final List<CatalogTagSummary> featuredTags;
  final List<CatalogShelf> shelves;
  final String sourceBaseUrl;
}

class CatalogShelf {
  const CatalogShelf({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.items,
  });

  final String id;
  final String title;
  final String subtitle;
  final List<CatalogFeedItem> items;
}

class CatalogTagSummary {
  const CatalogTagSummary({
    required this.label,
    required this.slug,
    required this.count,
    this.heroImageUrl,
  });

  factory CatalogTagSummary.fromJson(Map<String, dynamic> json) {
    final hero = json['heroPreview'];
    return CatalogTagSummary(
      label:
          (json['canonical'] as String?) ??
          (json['tag'] as String?) ??
          (json['slug'] as String?) ??
          'Unknown',
      slug: (json['slug'] as String?) ?? '',
      count: (json['count'] as num?)?.toInt() ?? 0,
      heroImageUrl: hero is Map<String, dynamic>
          ? hero['image'] as String?
          : null,
    );
  }

  final String label;
  final String slug;
  final int count;
  final String? heroImageUrl;
}

class CatalogFeed {
  const CatalogFeed({required this.items});

  factory CatalogFeed.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    if (rawItems is! List) {
      return const CatalogFeed(items: <CatalogFeedItem>[]);
    }
    return CatalogFeed(
      items: rawItems
          .whereType<Map<String, dynamic>>()
          .map(CatalogFeedItem.fromJson)
          .toList(growable: false),
    );
  }

  final List<CatalogFeedItem> items;
}

class CatalogFeedItem {
  const CatalogFeedItem({
    required this.id,
    required this.title,
    required this.tags,
    required this.tierId,
    required this.requiresSubscription,
    required this.previewImageUrl,
    required this.previewVideoUrl,
    required this.updatedAt,
    this.description,
  });

  factory CatalogFeedItem.fromJson(Map<String, dynamic> json) {
    final tier = json['tier'];
    final media = json['media'];
    final preview = media is Map<String, dynamic> ? media['preview'] : null;
    final previewImage = preview is Map<String, dynamic>
        ? preview['image']
        : null;
    final previewVideo = preview is Map<String, dynamic>
        ? preview['video']
        : null;

    return CatalogFeedItem(
      id: (json['id'] as String?) ?? '',
      title: (json['title'] as String?) ?? 'Untitled',
      description: json['description'] as String?,
      tags: _parseStringList(json['tags']),
      tierId: tier is Map<String, dynamic> ? tier['id'] as String? : null,
      requiresSubscription:
          tier is Map<String, dynamic> && tier['requiresSubscription'] == true,
      previewImageUrl: previewImage is Map<String, dynamic>
          ? previewImage['url'] as String?
          : null,
      previewVideoUrl: previewVideo is Map<String, dynamic>
          ? previewVideo['url'] as String?
          : null,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        (json['updatedAt'] as num?)?.toInt() ?? 0,
        isUtc: true,
      ).toLocal(),
    );
  }

  final String id;
  final String title;
  final String? description;
  final List<String> tags;
  final String? tierId;
  final bool requiresSubscription;
  final String? previewImageUrl;
  final String? previewVideoUrl;
  final DateTime updatedAt;

  String get tierLabel {
    switch (tierId?.toLowerCase()) {
      case 'free':
        return 'Free';
      case 'gold':
        return 'Gold';
      case 'amethyst':
        return 'Amethyst';
      case 'onyx':
        return 'Onyx';
      case 'platinum':
        return 'Platinum';
      default:
        return requiresSubscription ? 'Subscription' : 'Unlocked';
    }
  }

  static List<String> _parseStringList(Object? value) {
    if (value is! List) {
      return const <String>[];
    }
    return value.whereType<String>().toList(growable: false);
  }
}

class CatalogFeedException implements Exception {
  CatalogFeedException(this.message);

  final String message;

  @override
  String toString() => message;
}
