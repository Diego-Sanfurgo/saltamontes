import 'package:flutter/material.dart';
import 'package:saltamontes/data/models/place.dart';

class PlaceDetailsSheet extends StatefulWidget {
  const PlaceDetailsSheet({
    super.key,
    required this.place,
    required this.onClose,
  });

  final Place place;
  final VoidCallback onClose;

  @override
  State<PlaceDetailsSheet> createState() => _PlaceDetailsSheetState();
}

class _PlaceDetailsSheetState extends State<PlaceDetailsSheet> {
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: 0.3,
      minChildSize: 0.15,
      maxChildSize: 1.0,
      snap: true,
      snapSizes: const [0.3, 0.6, 1.0],
      builder: (context, scrollController) {
        return Container(
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: CustomScrollView(
            controller: scrollController,
            slivers: [
              SliverToBoxAdapter(child: _Handle()),
              SliverToBoxAdapter(
                child: _Header(place: widget.place, onClose: widget.onClose),
              ),
              SliverToBoxAdapter(child: const Divider()),
              SliverToBoxAdapter(child: _Description()),
              SliverToBoxAdapter(child: _PhotoCarousel()),
              SliverToBoxAdapter(child: _WeatherForecast()),
              // Extra bottom padding
              SliverToBoxAdapter(child: const SizedBox(height: 48)),
            ],
          ),
        );
      },
    );
  }
}

class _Handle extends StatelessWidget {
  const _Handle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 12, bottom: 4),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.place, required this.onClose});

  final Place place;
  final VoidCallback onClose;

  String _placeTypeLabel(PlaceType type) {
    return switch (type) {
      PlaceType.peak => 'Cerro',
      PlaceType.lake => 'Lago',
      PlaceType.pass => 'Paso',
      PlaceType.waterfall => 'Cascada',
      PlaceType.park => 'Parque',
    };
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final String typeLabel = _placeTypeLabel(place.type);

    final String? locationText =
        place.simpleDistrictName != null && place.simpleStateName != null
        ? '${place.simpleDistrictName}, ${place.simpleStateName}'
        : place.simpleDistrictName ?? place.simpleStateName;

    final String subtitle = locationText != null
        ? '$typeLabel · $locationText'
        : typeLabel;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.name,
                  style: textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (place.alt != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.height, size: 16, color: colorScheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        '${place.alt} m.s.n.m.',
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onClose,
            tooltip: 'Cerrar',
          ),
        ],
      ),
    );
  }
}

class _Description extends StatelessWidget {
  const _Description();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Descripción',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Este lugar se encuentra en una zona de montaña con paisajes '
            'increíbles para disfrutar de la naturaleza. Ideal para '
            'senderismo, trekking y actividades al aire libre. '
            'La zona cuenta con senderos marcados y refugios cercanos.',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoCarousel extends StatelessWidget {
  const _PhotoCarousel();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Fotos',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 160,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 5,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return Container(
                  width: 220,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.photo_outlined,
                          size: 40,
                          color: colorScheme.onSurface.withValues(alpha: 0.3),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Foto ${index + 1}',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurface.withValues(alpha: 0.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _WeatherForecast extends StatelessWidget {
  const _WeatherForecast();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    final List<Map<String, dynamic>> forecast = [
      {'day': 'Lun', 'icon': Icons.wb_sunny, 'temp': '22°'},
      {'day': 'Mar', 'icon': Icons.cloud, 'temp': '18°'},
      {'day': 'Mié', 'icon': Icons.grain, 'temp': '15°'},
      {'day': 'Jue', 'icon': Icons.wb_cloudy, 'temp': '17°'},
      {'day': 'Vie', 'icon': Icons.wb_sunny, 'temp': '21°'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Pronóstico',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: forecast.map((day) {
              return Column(
                children: [
                  Text(
                    day['day'] as String,
                    style: textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Icon(
                    day['icon'] as IconData,
                    color: colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    day['temp'] as String,
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
