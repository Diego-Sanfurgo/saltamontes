import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:saltamontes/features/map_filter/cubit/map_filter_cubit.dart';
import 'package:saltamontes/features/map_filter/widgets/altitude_filters.dart';
import 'package:saltamontes/features/map_filter/widgets/type_filters.dart';

class MapFilterView extends StatelessWidget {
  const MapFilterView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filtros'),
        actions: [
          BlocSelector<MapFilterCubit, MapFilterState, bool>(
            selector: (state) => state.hasActiveFilters,
            builder: (context, hasFilters) {
              if (!hasFilters) return const SizedBox.shrink();
              return TextButton.icon(
                icon: const Icon(Icons.clear_all),
                label: const Text('Limpiar'),
                onPressed: () => context.read<MapFilterCubit>().clearFilters(),
              );
            },
          ),
        ],
      ),
      body: const _Body(),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                TypeFilters(),
                _SectionDivider(),
                AltitudeFilters(),
              ],
            ),
          ),
        ),
        SafeArea(
          minimum: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                context.read<MapFilterCubit>().applyFilters();
              },
              child: const Text('Aplicar'),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Section Divider ─────────────────────────────────────────────────────────

class _SectionDivider extends StatelessWidget {
  const _SectionDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 12),
      child: Divider(),
    );
  }
}
