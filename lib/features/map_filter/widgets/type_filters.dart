import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saltamontes/features/map_filter/cubit/map_filter_cubit.dart';
import 'package:saltamontes/features/map/widgets/floating_chips.dart';

class TypeFilters extends StatelessWidget {
  const TypeFilters({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tipo de lugar', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        BlocSelector<MapFilterCubit, MapFilterState, Set<String>>(
          selector: (state) => state.placeTypeFilter,
          builder: (context, activeFilters) {
            return Wrap(
              spacing: 8,
              runSpacing: 8,
              children: chipData.map((chip) {
                final (type, label, icon) = chip;
                final isSelected = activeFilters.contains(type);
                return FilterChip(
                  selected: isSelected,
                  avatar: isSelected ? null : Icon(icon, size: 18),
                  label: Text(label),
                  onSelected: (_) =>
                      context.read<MapFilterCubit>().togglePlaceType(type),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
