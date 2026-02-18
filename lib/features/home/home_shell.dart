import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saltamontes/data/providers/place_provider.dart';
import 'package:saltamontes/data/repositories/map_repository.dart';
import 'package:saltamontes/data/repositories/place_repository.dart';
import 'bloc/map_bloc.dart';

class HomeShellView extends StatelessWidget {
  const HomeShellView({super.key, required this.navigationShell});

  // Recibimos el shell que controla el estado y el índice
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    // Nota: El MapBloc podría necesitar moverse arriba en el árbol (en main.dart)
    // si necesitas que persista al cambiar de rutas fuera del Shell,
    // pero aquí está bien si solo vive dentro del Shell.

    // Sin embargo, GoRouterState.of(context) podría dar problemas aquí
    // ya que el contexto cambia. Intenta evitar pasar routerState al Bloc si es posible,
    // o asegúrate de que sea estrictamente necesario.

    // Corrección para evitar error de contexto si usas routerState dentro del create:
    // Es más seguro instanciar el Bloc sin depender tanto del GoRouterState inmediato si es posible.
    return RepositoryProvider(
      create: (context) => TrackingMapRepository(PlaceProvider()),
      child: BlocProvider(
        create: (context) =>
            MapBloc(PlaceRepository(PlaceProvider()))..add(MapStarted()),
        child: Scaffold(
          // El body es el navigationShell mismo.
          // GoRouter se encarga de usar un IndexedStack internamente.
          body: navigationShell,
          bottomNavigationBar: BottomNavigationBar(
            // Usamos el índice actual del shell
            currentIndex: navigationShell.currentIndex,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.travel_explore_outlined),
                label: "Mapa",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.add_location_alt_outlined),
                label: "Grabar",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_outlined),
                label: "Perfil",
              ),
            ],
            onTap: (index) {
              // Esta función es mágica: cambia de rama sin perder el estado
              navigationShell.goBranch(
                index,
                // Soporte opcional: si tocas el tab activo, vuelve al inicio de esa rama
                initialLocation: index == navigationShell.currentIndex,
              );
            },
          ),
        ),
      ),
    );
  }
}
