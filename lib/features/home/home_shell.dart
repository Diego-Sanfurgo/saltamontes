import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bootstrap_icons/bootstrap_icons.dart';

import 'package:saltamontes/data/providers/map_controller_provider.dart';
import 'package:saltamontes/data/providers/place_provider.dart';
import 'package:saltamontes/data/repositories/map_repository.dart';
import 'package:saltamontes/data/repositories/place_repository.dart';
import 'package:saltamontes/features/map_filter/cubit/map_filter_cubit.dart';

import 'bloc/map_bloc.dart';
import 'cubit/home_shell_cubit.dart';

class HomeShellView extends StatelessWidget {
  const HomeShellView({super.key, required this.navigationShell});

  // Recibimos el shell que controla el estado y el índice
  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MapControllerProvider(),
      child: Builder(
        builder: (context) {
          final mapControllerProvider = context.read<MapControllerProvider>();
          return RepositoryProvider(
            create: (context) => TrackingMapRepository(PlaceApiProvider()),
            child: BlocProvider(
              create: (context) => MapBloc(
                PlaceRepository(PlaceApiProvider()),
                mapControllerProvider,
              )..add(MapStarted()),
              child: BlocProvider(
                create: (context) => MapFilterCubit(mapControllerProvider),
                child: BlocProvider(
                  create: (context) => HomeShellCubit(),
                  child: Scaffold(
                    extendBody: true,
                    body: navigationShell,
                    bottomNavigationBar: BlocBuilder<HomeShellCubit, bool>(
                      builder: (context, isNavBarVisible) {
                        return AnimatedSlide(
                          offset: isNavBarVisible
                              ? Offset.zero
                              : const Offset(0, 1.2),
                          duration: const Duration(milliseconds: 300),
                          child: NavigationBar(
                            selectedIndex: navigationShell.currentIndex,
                            destinations: const [
                              NavigationDestination(
                                icon: Icon(BootstrapIcons.map),
                                label: "Mapa",
                              ),
                              NavigationDestination(
                                icon: Icon(BootstrapIcons.person),
                                label: "Perfil",
                              ),
                            ],
                            onDestinationSelected: (index) {
                              navigationShell.goBranch(
                                index,
                                initialLocation:
                                    index == navigationShell.currentIndex,
                              );
                            },
                          ),
                        );
                      },
                    ), // BlocBuilder
                  ), // Scaffold
                ), // HomeShellCubit
              ), // MapFilterCubit
            ), // MapBloc
          ); // RepositoryProvider
        }, // builder function
      ), // Builder
    ); // ChangeNotifierProvider
  }
}
