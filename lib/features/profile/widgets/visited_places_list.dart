import 'package:flutter/material.dart';

import 'package:saltamontes/data/models/place.dart';

class VisitedPlacesList extends StatelessWidget {
  final List<Place> places;
  final bool isLoading;

  const VisitedPlacesList({
    super.key,
    required this.places,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (places.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(
                Icons.place_outlined,
                size: 48,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 8),
              Text(
                'Aún no visitaste ningún lugar',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final place = places[index];
        return _VisitedPlaceTile(place: place);
      }, childCount: places.length),
    );
  }
}

class _VisitedPlaceTile extends StatelessWidget {
  final Place place;
  const _VisitedPlaceTile({required this.place});

  IconData _iconForType(PlaceType type) {
    return switch (type) {
      PlaceType.peak => Icons.terrain,
      PlaceType.lake => Icons.water,
      PlaceType.pass => Icons.swap_horiz,
      PlaceType.waterfall => Icons.water_drop,
      PlaceType.park => Icons.park,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.secondaryContainer,
          child: Icon(
            _iconForType(place.type),
            color: colorScheme.onSecondaryContainer,
          ),
        ),
        title: Text(
          place.name,
          style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          [
            if (place.alt != null) '${place.alt}m',
            if (place.simpleStateName != null) place.simpleStateName!,
          ].join(' · '),
          style: textTheme.bodySmall,
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
