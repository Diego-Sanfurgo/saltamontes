import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:saltamontes/core/utils/constant_and_variables.dart';
import '../../home/bloc/map_bloc.dart';

const chipData = [
  (MapConstants.peakID, 'Cerros', Icons.volcano_outlined),
  (MapConstants.lakeID, 'Lagos', Icons.water_drop_outlined),
  (MapConstants.waterfallID, 'Cascadas', Icons.water_drop_outlined),
  (MapConstants.parkID, 'Parques', Icons.park_outlined),
];

class FloatingChips extends StatelessWidget {
  const FloatingChips({super.key});

  @override
  Widget build(BuildContext context) {
    final double height = MediaQuery.sizeOf(context).height * 0.05;

    return BlocSelector<MapBloc, MapState, Set<String>>(
      selector: (state) => state.placeTypeFilter,
      builder: (context, activeFilters) {
        return SizedBox(
          height: height,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16),
            child: Row(
              spacing: 4,
              children: chipData.map((chip) {
                final (type, label, icon) = chip;
                final isSelected = activeFilters.contains(type);
                return ChoiceChip(
                  shape: StadiumBorder(),
                  selected: isSelected,
                  avatar: isSelected ? null : Icon(icon),
                  onSelected: (_) => BlocProvider.of<MapBloc>(
                    context,
                  ).add(MapFilterPlaces(type)),
                  label: Text(label),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}
