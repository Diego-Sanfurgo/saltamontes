import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'package:saltamontes/core/services/navigation_service.dart';
import 'package:saltamontes/features/map/widgets/mocked_search_bar.dart';
import 'package:saltamontes/features/map/widgets/place_details_sheet.dart';
import 'package:saltamontes/features/map/widgets/location_button/cubit/location_cubit.dart';
import 'package:saltamontes/features/map/widgets/location_button/location_button.dart';

import '../home/bloc/map_bloc.dart';
import 'widgets/floating_chips.dart';
import 'widgets/map_style_selector.dart';
import '../../widgets/simple_scale_bar.dart';
import 'widgets/zoom_buttons.dart';

class MapView extends StatelessWidget {
  const MapView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LocationCubit(),
      child: const _MapViewWidget(),
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
    return Scaffold(body: SafeArea(child: _Body()));
  }
}

class _Body extends StatefulWidget {
  const _Body();

  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> {
  late final ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapBloc, MapState>(
      buildWhen: (prev, curr) =>
          prev.selectedPlace != curr.selectedPlace ||
          prev.isLoadingPlace != curr.isLoadingPlace,
      builder: (context, state) {
        return Stack(
          children: [
            _MapboxWidget(),
            // Right Side Controls (Centered Vertical)
            Positioned(
              right: 16,
              top: 0,
              bottom: 0,
              child: Center(child: const ZoomButtons()),
            ),

            // Top Right Layer Button (Below Chips)
            Positioned(
              top: 130,
              right: 16,
              child: FloatingActionButton.small(
                heroTag: Key("layer_FAB"),
                child: Icon(Icons.layers_outlined),
                onPressed: () => showMapStyleSelector(context),
              ),
            ),

            // Bottom Right Location Button
            Positioned(bottom: 32, right: 16, child: const LocationButton()),

            Positioned(
              top: 16,
              left: 0,
              right: 0,
              child: Column(
                spacing: 8,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: MockedSearchBar(
                      onTap: () => NavigationService.go(
                        Routes.SEARCH,
                        actualUri: GoRouterState.of(context).uri,
                      ),
                      onFilterTap: () =>
                          NavigationService.go(Routes.MAP_FILTER),
                    ),
                  ),
                  FloatingChips(),
                ],
              ),
            ),

            // Place details sheet or loading indicator
            if (state.isLoadingPlace)
              Positioned(
                bottom: 24,
                left: 0,
                right: 0,
                child: Center(child: CircularProgressIndicator()),
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
        );
      },
    );
  }
}

class _MapboxWidget extends StatefulWidget {
  const _MapboxWidget();

  @override
  State<_MapboxWidget> createState() => _MapboxWidgetState();
}

class _MapboxWidgetState extends State<_MapboxWidget> {
  MapboxMap? mapController;
  late final MapBloc bloc;

  final ValueNotifier<CameraState?> _cameraNotifier = ValueNotifier(null);

  /// Viewport gestionado localmente para usar setStateWithViewportAnimation.
  ViewportState _viewport = IdleViewportState();

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<MapBloc>(context);
  }

  @override
  void dispose() {
    mapController?.dispose();
    _cameraNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapBloc, MapState>(
      builder: (context, state) {
        if (state.status == MapStatus.loading) {
          return const Center(child: CircularProgressIndicator());
        }
        return Stack(
          children: [
            // BlocListener escucha cambios de modo y anima la transición
            BlocListener<LocationCubit, LocationState>(
              listenWhen: (prev, curr) => prev.cameraMode != curr.cameraMode,
              listener: (context, locationState) async {
                // Leer zoom actual para modo compass
                double? currentZoom;
                if (locationState.cameraMode == CameraMode.compass &&
                    mapController != null) {
                  final camera = await mapController!.getCameraState();
                  currentZoom = camera.zoom;
                }

                // Transición animada (500ms máximo)
                setStateWithViewportAnimation(
                  () {
                    _viewport = locationState.toViewportState(
                      currentZoom: currentZoom,
                    );
                  },
                  transition: DefaultViewportTransition(
                    maxDuration: Duration(milliseconds: 500),
                  ),
                );
              },
              child: Listener(
                onPointerDown: (_) {
                  context.read<LocationCubit>().onUserInteracted();
                },
                child: MapWidget(
                  key: const PageStorageKey('map_widget'),
                  viewport: _viewport,
                  onMapCreated: (controller) {
                    mapController = controller;
                    context.read<LocationCubit>().setController(controller);
                    controller
                      ..logo.updateSettings(LogoSettings(marginBottom: 8))
                      ..attribution.updateSettings(
                        AttributionSettings(marginBottom: 8, marginLeft: 88),
                      )
                      ..compass.updateSettings(
                        CompassSettings(marginTop: 140, marginRight: 16),
                      )
                      ..scaleBar.updateSettings(
                        ScaleBarSettings(
                          position: OrnamentPosition.BOTTOM_LEFT,
                          enabled: false,
                        ),
                      );
                    bloc.add(MapCreated(controller));
                  },
                  styleUri: MapboxStyles.OUTDOORS,
                  mapOptions: MapOptions(pixelRatio: 2),
                  cameraOptions: CameraOptions(zoom: 5),
                  onCameraChangeListener: (cameraChangedEventData) {
                    _cameraNotifier.value = cameraChangedEventData.cameraState;
                  },
                ),
              ),
            ),

            Positioned(
              left: 16,
              top: 0,
              bottom: 0,
              child: SimpleScaleBar(
                cameraStateNotifier: _cameraNotifier,
                alignment: Alignment.centerLeft,
                // padding: const EdgeInsets.only(left: 16, top: 100),
              ),
            ),
          ],
        );
      },
    );
  }
}
