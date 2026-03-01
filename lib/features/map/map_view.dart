import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'package:saltamontes/core/services/navigation_service.dart';
import 'package:saltamontes/data/providers/map_controller_provider.dart';
import 'package:saltamontes/data/providers/place_provider.dart';
import 'package:saltamontes/data/repositories/place_repository.dart';
import 'package:saltamontes/data/repositories/excursion_repository.dart';
import 'package:saltamontes/features/excursion/bloc/excursion_bloc.dart';
import 'package:saltamontes/features/map/widgets/mocked_search_bar.dart';
import 'package:saltamontes/features/map/widgets/place_details_sheet.dart';
import 'package:saltamontes/features/map/widgets/location_fab/location_fab.dart';

import 'package:saltamontes/features/home/bloc/map_bloc.dart';
import 'widgets/floating_chips.dart';
import 'widgets/layer_fab/layer_fab.dart';
import '../../widgets/simple_scale_bar.dart';
import 'widgets/tracking/tracking_bottom_sheet.dart';
import 'widgets/tracking/tracking_fab.dart';
import 'widgets/zoom_button/zoom_button.dart';
import 'package:saltamontes/data/providers/tracking_provider.dart';
import 'package:saltamontes/data/repositories/tracking_map_repository.dart';
import 'package:saltamontes/features/map/bloc/tracking_map_bloc/tracking_map_bloc.dart';
import 'widgets/tracking/animated_action_btn.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final mapControllerProvider = context.read<MapControllerProvider>();
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider(
          create: (context) => PlaceRepository(PlaceApiProvider()),
        ),
        RepositoryProvider(create: (context) => ExcursionRepository()),
        RepositoryProvider(
          create: (context) =>
              TrackingMapRepository(provider: TrackingProvider()),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                ExcursionBloc(repository: context.read<ExcursionRepository>())
                  ..add(LoadExcursions()),
          ),
          BlocProvider(
            create: (context) => TrackingMapBloc(
              repository: context.read<TrackingMapRepository>(),
              mapControllerProvider: mapControllerProvider,
            )..add(const TrackingMapInitialize()),
          ),
        ],
        child: const _MapViewWidget(),
      ),
    );
  }
}

class _MapViewWidget extends StatefulWidget {
  const _MapViewWidget();

  @override
  State<_MapViewWidget> createState() => _MapViewWidgetState();
}

class _MapViewWidgetState extends State<_MapViewWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrackingMapBloc, TrackingMapState>(
      builder: (context, trackingState) {
        final isTracking = trackingState.status != TrackingState.IDLE;
        return Scaffold(
          body: const _Body(),
          bottomNavigationBar: isTracking
              ? Container(
                  height: MediaQuery.sizeOf(context).height * 0.08,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: const Border(top: BorderSide(color: Colors.grey)),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: const AnimatedActionBtn(),
                )
              : null,
        );
      },
    );
  }
}

class _Body extends StatefulWidget {
  const _Body();

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  late final ScrollController scrollController;
  final ValueNotifier<CameraState?> _cameraNotifier = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
  }

  @override
  void dispose() {
    scrollController.dispose();
    _cameraNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ExcursionBloc, ExcursionState>(
          listenWhen: (prev, curr) =>
              prev.activeExcursionId != curr.activeExcursionId ||
              prev.error != curr.error,
          listener: (context, state) {
            if (state.error != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.error!)));
            } else if (state.activeExcursionId != null) {
              // Now tracking is integrated in the same view, no redirect needed.
            }
          },
        ),
      ],
      child: BlocBuilder<TrackingMapBloc, TrackingMapState>(
        builder: (context, trackingState) {
          final isTracking = trackingState.status != TrackingState.IDLE;
          return BlocBuilder<MapBloc, MapState>(
            buildWhen: (prev, curr) =>
                prev.selectedPlace != curr.selectedPlace ||
                prev.isLoadingPlace != curr.isLoadingPlace,
            builder: (context, state) {
              return Stack(
                children: [
                  _MapboxWidget(cameraNotifier: _cameraNotifier),
                  Positioned.fill(
                    child: SafeArea(
                      child: Stack(
                        children: [
                          // Right Side Controls (Centered Vertical)
                          Positioned(
                            right: 16,
                            top: 0,
                            bottom: 0,
                            child: Center(child: const ZoomButton()),
                          ),

                          // Left Side Controls (Centered Vertical)
                          Positioned(
                            left: 16,
                            top: 0,
                            bottom: 0,
                            child: SimpleScaleBar(
                              cameraStateNotifier: _cameraNotifier,
                              alignment: Alignment.centerLeft,
                            ),
                          ),

                          // Top Right Layer Button (Below Chips)
                          Positioned(top: 130, right: 16, child: LayerFAB()),

                          // Bottom Right Location Button & FAB (hidden during tracking)
                          if (!isTracking)
                            Positioned(
                              bottom: 32,
                              right: 16,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                spacing: 16,
                                children: [
                                  const LocationFAB(),
                                  const TrackingFAB(),
                                ],
                              ),
                            ),

                          Positioned(
                            top: 8,
                            left: 0,
                            right: 0,
                            child: Column(
                              spacing: 8,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  child: MockedSearchBar(
                                    onTap: () => NavigationService.go(
                                      Routes.SEARCH,
                                      actualUri: GoRouterState.of(context).uri,
                                    ),
                                    onFilterTap: () =>
                                        NavigationService.go(Routes.MAP_FILTER),
                                  ),
                                ),
                                const FloatingChips(),
                              ],
                            ),
                          ),

                          // Place details sheet or loading indicator (hidden during tracking)
                          if (!isTracking) ...[
                            if (state.isLoadingPlace)
                              Positioned(
                                bottom: 24,
                                left: 0,
                                right: 0,
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                            else if (state.selectedPlace != null)
                              Padding(
                                padding: const EdgeInsets.only(top: 16),
                                child: PlaceDetailsSheet(
                                  place: state.selectedPlace!,
                                  onClose: () => BlocProvider.of<MapBloc>(
                                    context,
                                  ).add(MapDeselectFeature()),
                                ),
                              ),
                          ],

                          // Tracking Bottom Sheet (shown during tracking)
                          if (isTracking) const TrackingBottomSheet(),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _MapboxWidget extends StatefulWidget {
  final ValueNotifier<CameraState?> cameraNotifier;

  const _MapboxWidget({required this.cameraNotifier});

  @override
  State<_MapboxWidget> createState() => _MapboxWidgetState();
}

class _MapboxWidgetState extends State<_MapboxWidget> {
  MapboxMap? mapController;
  late final MapBloc bloc;
  late final MapControllerProvider _mapControllerProvider;

  /// Viewport gestionado localmente para usar setStateWithViewportAnimation.
  ViewportState _viewport = IdleViewportState();

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<MapBloc>(context);
    _mapControllerProvider = context.read<MapControllerProvider>();
    _mapControllerProvider.viewportNotifier.addListener(_onViewportRequested);
  }

  void _onViewportRequested() {
    final request = _mapControllerProvider.viewportNotifier.value;
    if (request == null) return;
    setStateWithViewportAnimation(
      () => _viewport = request.viewport,
      transition: request.transition,
    );
  }

  @override
  void dispose() {
    _mapControllerProvider.viewportNotifier.removeListener(
      _onViewportRequested,
    );
    mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapBloc, MapState>(
      builder: (context, state) {
        if (state.status == MapStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        // Widget del mapa con viewport animado
        return Listener(
          onPointerDown: (_) {
            _mapControllerProvider.onUserInteraction?.call();
          },
          child: MapWidget(
            key: const PageStorageKey('map_widget'),
            viewport: _viewport,
            onMapCreated: (controller) {
              final topPadding = MediaQuery.of(context).padding.top;
              mapController = controller;

              // Una sola línea: el provider notifica a todos los consumers.
              context.read<MapControllerProvider>().setController(controller);

              controller
                ..logo.updateSettings(LogoSettings(marginBottom: 8))
                ..attribution.updateSettings(
                  AttributionSettings(marginBottom: 8, marginLeft: 88),
                )
                ..compass.updateSettings(
                  CompassSettings(marginTop: 186 + topPadding, marginRight: 16),
                )
                ..scaleBar.updateSettings(
                  ScaleBarSettings(
                    position: OrnamentPosition.BOTTOM_LEFT,
                    enabled: false,
                  ),
                );
            },
            styleUri: MapboxStyles.OUTDOORS,
            mapOptions: MapOptions(pixelRatio: 2),
            cameraOptions: CameraOptions(zoom: 5),
            onCameraChangeListener: (cameraChangedEventData) {
              widget.cameraNotifier.value = cameraChangedEventData.cameraState;
            },
          ),
        );
      },
    );
  }
}
