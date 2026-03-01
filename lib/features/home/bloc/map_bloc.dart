import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:latlong2/latlong.dart';
import 'package:equatable/equatable.dart';
import 'package:saltamontes/core/services/layer_service.dart';
import 'package:saltamontes/data/models/place.dart';
import 'package:saltamontes/data/providers/map_controller_provider.dart';
import 'package:saltamontes/data/repositories/place_repository.dart';
import 'package:saltamontes/features/home/dto/selected_feature_dto.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'package:saltamontes/core/services/location_service.dart';

import 'package:saltamontes/features/home/functions/on_map_tap_listener.dart';
import 'package:saltamontes/core/utils/constant_and_variables.dart';

part 'map_event.dart';
part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc(this._placeRepository, this._mapControllerProvider)
    : super(const MapState(status: MapStatus.loading)) {
    on<MapStarted>(_onStarted);
    on<MapMoveCamera>(_onMoveCamera);
    on<MapSelectPlace>(_onSelectPlace);
    on<MapDeselectFeature>(_onDeselectFeature);
    on<MapShowTrackOverlay>(_onShowTrackOverlay);
    on<MapClearTrackOverlay>(_onClearTrackOverlay);
    on<_MapControllerReady>(_onControllerReady);
    _mapControllerProvider.addListener(_onControllerChanged);
  }

  final PlaceRepository _placeRepository;
  final MapControllerProvider _mapControllerProvider;

  MapboxMap? _controller;
  final LocationService _locationService = LocationService.instance;
  SelectedFeatureDTO _selectedFeatureDTO = SelectedFeatureDTO.empty();

  Future<void> _onStarted(MapStarted event, Emitter<MapState> emit) async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.locationAlways,
      Permission.locationWhenInUse,
    ].request();
    log(statuses.toString());

    emit(state.copyWith(status: MapStatus.initial));
  }

  void _onControllerChanged() {
    final controller = _mapControllerProvider.controller;
    if (controller != null && controller != _controller) {
      _controller = controller;
      add(_MapControllerReady(controller));
    }
  }

  Future<void> _onControllerReady(
    _MapControllerReady event,
    Emitter<MapState> emit,
  ) async {
    final controller = event.controller;

    controller.location.updateSettings(
      LocationComponentSettings(
        enabled: true,
        puckBearingEnabled: true,
        puckBearing: PuckBearing.HEADING,
        pulsingEnabled: true,
      ),
    );

    await LayerService.addPlacesSource(controller);

    final tapStream = addOnMapTapListener(controller, [MapConstants.placesID]);

    tapStream.listen((selectedFeature) {
      add(MapSelectPlace(feature: selectedFeature));
    });

    emit(state.copyWith(status: MapStatus.loaded, places: []));
    add(MapMoveCamera());
  }

  /// Returns `true` if the feature was deselected, `false` if a new feature was selected.
  Future<void> _clearSelectionFor(SelectedFeatureDTO dto) async {
    await _controller!.setFeatureState(
      dto.sourceID,
      null,
      dto.featureId,
      jsonEncode({'selected': false}),
    );

    await LayerService.clearFeatureAreaFilter(_controller!, dto.type);
  }

  /// Returns `true` if the feature was deselected, `false` if a new feature was selected.
  Future<bool> _handleFeatureSelection(
    SelectedFeatureDTO selectedFeature,
  ) async {
    if (_controller == null) return false;

    // Check if re-tapping the same feature to deselect
    if (_selectedFeatureDTO.featureId == selectedFeature.featureId) {
      await _clearSelectionFor(_selectedFeatureDTO);
      _selectedFeatureDTO = SelectedFeatureDTO.empty();
      return true;
    }

    // Clear previous selection if any
    if (_selectedFeatureDTO.featureId.isNotEmpty) {
      await _clearSelectionFor(_selectedFeatureDTO);
    }

    // Set new selection
    await _controller!.setFeatureState(
      selectedFeature.sourceID,
      null,
      selectedFeature.featureId,
      jsonEncode({'selected': true}),
    );

    // Show area for new selected feature
    await LayerService.filterFeatureArea(_controller!, selectedFeature.type, [
      selectedFeature.featureId,
    ]);

    _selectedFeatureDTO = selectedFeature;
    return false;
  }

  Future<void> _onSelectPlace(
    MapSelectPlace event,
    Emitter<MapState> emit,
  ) async {
    if (_controller == null) return;

    final SelectedFeatureDTO dto;
    final LatLng target;

    // 1. Resolve DTO and Target
    if (event.place != null) {
      dto = SelectedFeatureDTO.fromPlace(event.place!);
      target = LatLng(
        event.place!.geom.coordinates.latitude,
        event.place!.geom.coordinates.longitude,
      );
    } else if (event.feature != null && !event.feature!.isCluster) {
      dto = event.feature!;
      target = LatLng(event.feature!.lat!, event.feature!.lng!);
    } else {
      return;
    }

    // 2. Handle Selection/Deselection Logic
    final wasDeselected = await _handleFeatureSelection(dto);

    if (wasDeselected) {
      emit(state.copyWith(selectedPlace: () => null, isLoadingPlace: false));
      return;
    }

    // 3. Move Camera
    await _controller!.easeTo(
      CameraOptions(
        center: Point(coordinates: Position(target.longitude, target.latitude)),
        zoom: 14.5,
      ),
      MapAnimationOptions(duration: 500),
    );

    // 4. Update State (Place known)
    if (event.place != null) {
      emit(
        state.copyWith(selectedPlace: () => event.place, isLoadingPlace: false),
      );
      return;
    }

    // 5. Update State (Fetch Place)
    emit(state.copyWith(isLoadingPlace: true, selectedPlace: () => null));
    final place = await _placeRepository.getById(dto.featureId);
    emit(state.copyWith(isLoadingPlace: false, selectedPlace: () => place));
  }

  Future<void> _onDeselectFeature(
    MapDeselectFeature event,
    Emitter<MapState> emit,
  ) async {
    if (_controller == null) return;

    if (_selectedFeatureDTO.featureId.isNotEmpty) {
      await _clearSelectionFor(_selectedFeatureDTO);
      _selectedFeatureDTO = SelectedFeatureDTO.empty();
    }

    emit(state.copyWith(selectedPlace: () => null, isLoadingPlace: false));
  }

  Future<void> _onMoveCamera(
    MapMoveCamera event,
    Emitter<MapState> emit,
  ) async {
    if (_controller == null) return;

    if (event.coordinates != null && event.coordinates!.isNotEmpty) {
      final points = event.coordinates!
          .map((c) => Point(coordinates: Position(c.longitude, c.latitude)))
          .toList();

      final cameraOptions = await _controller!.cameraForCoordinatesPadding(
        points,
        CameraOptions(),
        MbxEdgeInsets(top: 50.0, left: 50.0, bottom: 50.0, right: 50.0),
        null,
        null,
      );

      await _controller!.flyTo(
        cameraOptions,
        MapAnimationOptions(duration: 1000),
      );
      return;
    }

    if (event.targetLocation == null && _locationService.lastPosition == null) {
      return;
    }

    LatLng coords = event.targetLocation == null
        ? LatLng(
            _locationService.lastPosition!.latitude,
            _locationService.lastPosition!.longitude,
          )
        : event.targetLocation!;

    await _controller!.flyTo(
      CameraOptions(
        zoom: event.zoomLevel ?? 14.0,
        center: Point(coordinates: Position(coords.longitude, coords.latitude)),
      ),
      MapAnimationOptions(duration: 500),
    );
  }

  // ─── Track Overlay (Module 3) ───

  Future<void> _onShowTrackOverlay(
    MapShowTrackOverlay event,
    Emitter<MapState> emit,
  ) async {
    if (_controller == null) return;

    final geojsonStr = jsonEncode({
      'type': 'FeatureCollection',
      'features': [
        {'type': 'Feature', 'geometry': event.geojson, 'properties': {}},
      ],
    });

    await LayerService.addTrackOverlay(_controller!, geojsonStr);
    emit(state.copyWith(trackOverlayGeoJson: () => event.geojson));
  }

  Future<void> _onClearTrackOverlay(
    MapClearTrackOverlay event,
    Emitter<MapState> emit,
  ) async {
    if (_controller == null) return;

    await LayerService.removeTrackOverlay(_controller!);
    emit(state.copyWith(trackOverlayGeoJson: () => null));
  }

  @override
  Future<void> close() {
    _mapControllerProvider.removeListener(_onControllerChanged);
    return super.close();
  }
}
