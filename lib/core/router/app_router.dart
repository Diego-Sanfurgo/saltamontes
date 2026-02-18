import 'package:go_router/go_router.dart';

import 'package:saltamontes/core/utils/constant_and_variables.dart';
import 'package:saltamontes/features/tracking_map/tracking_map.dart';

import 'route_widgets_export.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    debugLogDiagnostics: true,
    navigatorKey: AppUtil.navigatorKey,
    initialLocation: "/map",
    routes: [
      GoRoute(path: "/", redirect: (context, state) => '/map'),

      // CAMBIO PRINCIPAL: Usar StatefulShellRoute
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          // Pasamos el navigationShell al HomeShellView en lugar del child genérico
          return HomeShellView(navigationShell: navigationShell);
        },
        branches: [
          // RAMA 1: Mapa
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: "/map",
                builder: (context, state) => const MapView(),
                routes: [
                  GoRoute(
                    path: '/search',
                    builder: (context, state) => const SearchView(),
                  ),
                  GoRoute(
                    path: '/filter',
                    builder: (context, state) => const MapFilterView(),
                  ),
                ],
              ),
            ],
          ),

          // RAMA 2: mapa de seguimiento
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: "/tracking_map",
                builder: (context, state) => const TrackingMapView(),
                // LocationDebugScreen(database: TrackingDatabase()),
              ),
            ],
          ),

          //RAMA 3: Perfil
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: "/profile",
                builder: (context, state) => const ProfileView(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
