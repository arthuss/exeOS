import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../features/catalog/data/catalog_feed_repository.dart';
import '../features/catalog/presentation/catalog_detail_screen.dart';
import '../features/catalog/presentation/catalog_screen.dart';
import '../features/auth/presentation/auth_complete_screen.dart';
import '../features/auth/presentation/integration_complete_screen.dart';
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
      path: '/auth/complete',
      pageBuilder: (BuildContext context, GoRouterState state) {
        final provider = state.uri.queryParameters['provider'] ?? 'google';
        final nextPath = state.uri.queryParameters['next'] ?? '/settings';
        return NoTransitionPage(
          child: AuthCompleteScreen(provider: provider, nextPath: nextPath),
        );
      },
    ),
    GoRoute(
      path: '/connect/drive/complete',
      pageBuilder: (BuildContext context, GoRouterState state) {
        final nextPath = state.uri.queryParameters['next'] ?? '/settings';
        return NoTransitionPage(
          child: IntegrationCompleteScreen(
            title: 'Google Drive callback',
            body:
                'The route is reserved for the later Drive scope handoff. Drive stays a separate consent from Google owner login.',
            nextPath: nextPath,
          ),
        );
      },
    ),
    GoRoute(
      path: '/integrations/:provider/complete',
      pageBuilder: (BuildContext context, GoRouterState state) {
        final provider = state.pathParameters['provider'] ?? 'provider';
        final nextPath = state.uri.queryParameters['next'] ?? '/settings';
        return NoTransitionPage(
          child: IntegrationCompleteScreen(
            title: '$provider callback',
            body:
                'This route is reserved for later provider-specific return flows, so social integrations can land back in the Flutter shell without introducing a second callback model.',
            nextPath: nextPath,
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
