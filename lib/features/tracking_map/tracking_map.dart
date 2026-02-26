import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart' as mapbox;

import 'package:saltamontes/data/providers/tracking_database.dart';

import 'package:saltamontes/core/services/navigation_service.dart';

import 'package:saltamontes/data/repositories/tracking_map_repository.dart';
import 'package:saltamontes/features/tracking_map/bloc/tracking_map_bloc.dart';
import 'package:saltamontes/features/tracking_map/widgets/actions_list.dart';
import 'package:saltamontes/features/tracking_map/widgets/metrics_grid.dart';

import 'widgets/animated_action_btn.dart';

class TrackingMapView extends StatelessWidget {
  const TrackingMapView({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => TrackingMapRepository(database: TrackingDatabase()),
      child: BlocProvider(
        create: (context) =>
            TrackingMapBloc(repository: context.read<TrackingMapRepository>()),
        child: _TrackingMapWidget(),
      ),
    );
  }
}

class _TrackingMapWidget extends StatefulWidget {
  const _TrackingMapWidget();

  @override
  State<_TrackingMapWidget> createState() => _TrackingMapWidgetState();
}

class _TrackingMapWidgetState extends State<_TrackingMapWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        height: MediaQuery.sizeOf(context).height * 0.08,
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: Colors.grey)),
        ),
        padding: const EdgeInsets.all(8),
        child: AnimatedActionBtn(),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => Stack(
            children: [
              // 1. Map Layer
              const _MapLayer(),

              // 2. Excursion FAB
              Positioned(
                bottom: constraints.maxHeight * 0.2 + 64,
                right: 16,
                child: FloatingActionButton(
                  heroTag: 'excursion_fab',
                  child: const Icon(Icons.hiking, size: 24),
                  onPressed: () => NavigationService.push(Routes.EXCURSION),
                ),
              ),

              // 3. Center on user
              Positioned(
                bottom: constraints.maxHeight * 0.2,
                right: 16,
                child: FloatingActionButton(
                  heroTag: 'center_fab',
                  child: Icon(Icons.my_location_outlined, size: 24),
                  onPressed: () => context.read<TrackingMapBloc>().add(
                    TrackingMapCenterCameraOnUser(),
                  ),
                ),
              ),

              // 3. Bottom Sheet Layer
              const _BottomSheetLayer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapLayer extends StatelessWidget {
  const _MapLayer();

  @override
  Widget build(BuildContext context) {
    // Basic MapWidget setup without credentials for preview structure
    // In a real app, ensure MapboxAccessToken is set in info.plist/AndroidManifest
    return mapbox.MapWidget(
      onMapCreated: (controller) =>
          context.read<TrackingMapBloc>().add(TrackingMapCreated(controller)),
      cameraOptions: mapbox.CameraOptions(zoom: 13.0),
    );
  }
}

class _BottomSheetLayer extends StatelessWidget {
  const _BottomSheetLayer();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: DraggableScrollableSheet(
        initialChildSize: 0.15,
        minChildSize: 0.15,
        maxChildSize: 1.0,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                children: [
                  // Handle indicator
                  Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Metrics Grid
                  const MetricsGridWidget(),

                  // Action List
                  const ActionsListWidget(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
