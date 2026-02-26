import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:saltamontes/data/repositories/excursion_repository.dart';
import 'package:saltamontes/features/excursion/bloc/excursion_bloc.dart';
import 'package:saltamontes/features/profile/widgets/excursion_list.dart';
import 'package:saltamontes/features/profile/widgets/downloads_list.dart';
import 'package:saltamontes/features/profile/widgets/visited_places_list.dart';
import 'package:saltamontes/features/settings/bloc/settings_bloc.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => ExcursionRepository(),
      child: BlocProvider(
        create: (context) =>
            ExcursionBloc(repository: context.read<ExcursionRepository>())
              ..add(LoadExcursions()),
        child: const _ProfileBody(),
      ),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Perfil'),
          actions: [
            IconButton(
              onPressed: () => context.read<SettingsBloc>().add(ToggleTheme()),
              icon: BlocBuilder<SettingsBloc, SettingsState>(
                builder: (context, state) {
                  return Icon(state.isDarkMode ? Icons.dark_mode : Icons.sunny);
                },
              ),
            ),
          ],
          bottom: TabBar(
            indicatorColor: colorScheme.primary,
            labelColor: colorScheme.primary,
            unselectedLabelColor: colorScheme.onSurface.withValues(alpha: 0.6),
            tabs: const [
              Tab(icon: Icon(Icons.hiking), text: 'Excursiones'),
              Tab(icon: Icon(Icons.download), text: 'Descargas'),
              Tab(icon: Icon(Icons.place), text: 'Lugares'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            // Tab 1: Historial de excursiones realizadas
            _ExcursionsTab(),
            // Tab 2: Descargas Offline
            _DownloadsTab(),
            // Tab 3: Lugares Visitados
            _VisitedPlacesTab(),
          ],
        ),
      ),
    );
  }
}

class _ExcursionsTab extends StatelessWidget {
  const _ExcursionsTab();

  @override
  Widget build(BuildContext context) {
    return const CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.only(top: 8),
          sliver: ExcursionList(),
        ),
      ],
    );
  }
}

class _DownloadsTab extends StatelessWidget {
  const _DownloadsTab();

  @override
  Widget build(BuildContext context) {
    return const CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.only(top: 8),
          sliver: DownloadsList(),
        ),
      ],
    );
  }
}

class _VisitedPlacesTab extends StatelessWidget {
  const _VisitedPlacesTab();

  @override
  Widget build(BuildContext context) {
    // TODO: Alimentar con datos reales de ExcursionRepository.getVisitedPlaces
    return const CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.only(top: 8),
          sliver: VisitedPlacesList(places: [], isLoading: false),
        ),
      ],
    );
  }
}
