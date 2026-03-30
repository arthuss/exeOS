import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../features/catalog/data/catalog_feed_repository.dart';
import '../features/catalog/presentation/catalog_detail_screen.dart';
import '../features/catalog/presentation/catalog_screen.dart';
import '../features/legal/presentation/legal_document_screen.dart';
import '../features/settings/presentation/settings_screen.dart';

final GoRouter appRouter = GoRouter(
  routes: <RouteBase>[
    GoRoute(path: '/catalog', redirect: (_, __) => '/'),
    GoRoute(
      path: '/catalog/:wallpaperId',
      redirect: (BuildContext context, GoRouterState state) =>
          '/w/${state.pathParameters['wallpaperId'] ?? ''}',
    ),
    GoRoute(
      path: '/w/:wallpaperRef',
      pageBuilder: (BuildContext context, GoRouterState state) {
        final initialItem = state.extra is CatalogFeedItem
            ? state.extra as CatalogFeedItem
            : null;
        return NoTransitionPage(
          child: CatalogDetailScreen(
            wallpaperRef: state.pathParameters['wallpaperRef'] ?? '',
            initialItem: initialItem,
          ),
        );
      },
    ),
    GoRoute(
      path: '/settings',
      pageBuilder: (BuildContext context, GoRouterState state) =>
          const NoTransitionPage(child: SettingsScreen()),
    ),
    GoRoute(
      path: '/privacy-policy',
      pageBuilder: (BuildContext context, GoRouterState state) =>
          const NoTransitionPage(
            child: LegalDocumentScreen(slug: 'privacy-policy'),
          ),
    ),
    GoRoute(
      path: '/terms-of-service',
      pageBuilder: (BuildContext context, GoRouterState state) =>
          const NoTransitionPage(
            child: LegalDocumentScreen(slug: 'terms-of-service'),
          ),
    ),
    GoRoute(
      path: '/delete-account',
      pageBuilder: (BuildContext context, GoRouterState state) =>
          const NoTransitionPage(
            child: LegalDocumentScreen(slug: 'delete-account'),
          ),
    ),
    GoRoute(
      path: '/impressum',
      pageBuilder: (BuildContext context, GoRouterState state) =>
          const NoTransitionPage(child: LegalDocumentScreen(slug: 'impressum')),
    ),
    GoRoute(
      path: '/',
      pageBuilder: (BuildContext context, GoRouterState state) =>
          const NoTransitionPage(child: CatalogScreen()),
    ),
  ],
);
