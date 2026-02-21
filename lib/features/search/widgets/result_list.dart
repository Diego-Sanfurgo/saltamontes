import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:saltamontes/data/models/place.dart';
import 'package:saltamontes/core/services/navigation_service.dart';

import 'package:saltamontes/features/home/bloc/map_bloc.dart';

class ResultList extends StatelessWidget {
  const ResultList({super.key, required this.places});
  final Set<Place> places;

  @override
  Widget build(BuildContext context) {
    return SliverList.builder(
      itemCount: places.length,
      itemBuilder: (context, index) {
        Place place = places.elementAt(index);
        final String? subtitle =
            place.simpleDistrictName != null && place.simpleStateName != null
            ? '${place.simpleDistrictName}, ${place.simpleStateName}'
            : place.simpleDistrictName ?? place.simpleStateName;

        final IconData icon = switch (place.type) {
          PlaceType.peak => Icons.volcano_outlined,
          PlaceType.lake => Icons.water_outlined,
          PlaceType.pass => Icons.terrain_outlined,
          PlaceType.waterfall => Icons.water_drop_outlined,
          PlaceType.park => Icons.park_outlined,
        };

        return ListTile(
          title: Text(place.name ?? 'Sin nombre'),
          subtitle: subtitle != null
              ? Text(subtitle, overflow: TextOverflow.ellipsis, maxLines: 1)
              : null,
          leading: Icon(icon),
          trailing: Icon(Icons.arrow_right),
          onTap: () {
            NavigationService.pop();
            BlocProvider.of<MapBloc>(context).add(MapSelectPlace(place: place));
          },
        );
      },
    );
  }
}
