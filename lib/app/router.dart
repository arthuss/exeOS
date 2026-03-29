import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../features/catalog/data/catalog_feed_repository.dart';
import '../features/catalog/presentation/catalog_detail_screen.dart';
import '../features/catalog/presentation/catalog_screen.dart';
import '../features/home/presentation/home_screen.dart';
import '../features/settings/presentation/settings_screen.dart';

final GoRouter appRouter = GoRouter(
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      pageBuilder: (BuildContext context, GoRouterState state) =>
          const NoTransitionPage(child: HomeScreen()),
      routes: <RouteBase>[
        GoRoute(
          path: 'catalog',
          pageBuilder: (BuildContext context, GoRouterState state) =>
              const NoTransitionPage(child: CatalogScreen()),
          routes: <RouteBase>[
            GoRoute(
              path: ':wallpaperId',
              pageBuilder: (BuildContext context, GoRouterState state) {
                final initialItem = state.extra is CatalogFeedItem
                    ? state.extra as CatalogFeedItem
                    : null;
                return NoTransitionPage(
                  child: CatalogDetailScreen(
                    wallpaperId: state.pathParameters['wallpaperId'] ?? '',
                    initialItem: initialItem,
                  ),
                );
              },
            ),
          ],
        ),
        GoRoute(
          path: 'settings',
          pageBuilder: (BuildContext context, GoRouterState state) =>
              const NoTransitionPage(child: SettingsScreen()),
        ),
      ],
    ),
  ],
);
