import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:latlong2/latlong.dart';
import 'package:equatable/equatable.dart';
import 'package:saltamontes/core/services/layer_service.dart';
import 'package:saltamontes/data/models/place.dart';
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
  MapBloc(this._placeRepository)
    : super(const MapState(status: MapStatus.loading)) {
    _init();
    on<MapCreated>(_onCreated);
    on<MapReload>(_onReload);
    on<MapCameraIdle>(_onCameraIdle);
    on<MapMoveCamera>(_onMoveCamera);
    on<MapChangeStyle>(_onChangeStyle);
    on<MapToggleOverlay>(_onToggleOverlay);
    on<MapFilterPlaces>(_onFilterPlaces);
    on<MapFilterAltitude>(_onFilterAltitude);
    on<MapClearFilters>(_onClearFilters);
    on<MapSelectFeature>(_onSelectFeature);
    on<MapDeselectFeature>(_onDeselectFeature);
    on<MapZoomIn>(_onZoomIn);
    on<MapZoomOut>(_onZoomOut);
    on<MapFeatureTapped>(_onFeatureTapped);
  }

  final PlaceRepository _placeRepository;

  MapboxMap? _controller;
  final LocationService _locationService = LocationService.instance;
  SelectedFeatureDTO _selectedFeatureDTO = SelectedFeatureDTO.empty();

  Future<void> _init() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.locationAlways,
      Permission.locationWhenInUse,
    ].request();
    log(statuses.toString());

    add(MapReload());
  }

  Future<void> _onCreated(MapCreated event, Emitter<MapState> emit) async {
    _controller = event.controller;

    _controller!.location.updateSettings(
      LocationComponentSettings(enabled: true, puckBearingEnabled: true),
    );

    await LayerService.addPlacesSource(_controller!);

    final tapStream = addOnMapTapListener(_controller!, [
      MapConstants.placesID,
    ]);

    tapStream.listen((selectedFeature) {
      add(MapFeatureTapped(selectedFeature));
    });

    emit(state.copyWith(status: MapStatus.loaded, places: []));
    add(MapMoveCamera());
  }

  /// Returns `true` if the feature was deselected, `false` if a new feature was selected.
  Future<bool> _handleFeatureSelection(
    SelectedFeatureDTO selectedFeature,
  ) async {
    if (_controller == null) return false;

    // Check if re-tapping the same feature to deselect
    if (_selectedFeatureDTO.featureId == selectedFeature.featureId) {
      await _controller!.setFeatureState(
        _selectedFeatureDTO.sourceID,
        null,
        _selectedFeatureDTO.featureId,
        jsonEncode({'selected': false}),
      );

      await LayerService.clearFeatureAreaFilter(
        _controller!,
        _selectedFeatureDTO.type,
      );

      _selectedFeatureDTO = SelectedFeatureDTO.empty();
      return true;
    }

    if (_selectedFeatureDTO.featureId.isNotEmpty) {
      // Clear previous selection
      await _controller!.setFeatureState(
        _selectedFeatureDTO.sourceID,
        null,
        _selectedFeatureDTO.featureId,
        jsonEncode({'selected': false}),
      );

      // Clear previous area filter
      await LayerService.clearFeatureAreaFilter(
        _controller!,
        _selectedFeatureDTO.type,
      );
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

  Future<void> _onSelectFeature(
    MapSelectFeature event,
    Emitter<MapState> emit,
  ) async {
    if (_controller == null) return;

    final selectedFeature = SelectedFeatureDTO.fromPlace(event.place);
    await _handleFeatureSelection(selectedFeature);

    // Set selectedPlace directly since we already have the full Place
    emit(
      state.copyWith(selectedPlace: () => event.place, isLoadingPlace: false),
    );

    // Move camera to selected place
    add(
      MapMoveCamera(
        targetLocation: LatLng(
          event.place.geom.coordinates.latitude,
          event.place.geom.coordinates.longitude,
        ),
        zoomLevel: 14.5,
      ),
    );
  }

  Future<void> _onDeselectFeature(
    MapDeselectFeature event,
    Emitter<MapState> emit,
  ) async {
    if (_controller == null) return;

    if (_selectedFeatureDTO.featureId.isNotEmpty) {
      await _controller!.setFeatureState(
        _selectedFeatureDTO.sourceID,
        null,
        _selectedFeatureDTO.featureId,
        jsonEncode({'selected': false}),
      );

      await LayerService.clearFeatureAreaFilter(
        _controller!,
        _selectedFeatureDTO.type,
      );

      _selectedFeatureDTO = SelectedFeatureDTO.empty();
    }

    emit(state.copyWith(selectedPlace: () => null, isLoadingPlace: false));
  }

  Future<void> _onReload(MapReload event, Emitter<MapState> emit) async {
    emit(state.copyWith(status: MapStatus.initial));
  }

  Future<void> _onCameraIdle(
    MapCameraIdle event,
    Emitter<MapState> emit,
  ) async {
    if (_controller == null) return;
    // await filterVisiblePoints(_controller!, event.cameraState);
    // final visibleRegion = await _controller!.coordinateBoundsForCamera(
    //   event.cameraState.toCameraOptions(),
    // );
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

  Future<void> _onChangeStyle(
    MapChangeStyle event,
    Emitter<MapState> emit,
  ) async {
    if (_controller == null) return;
    await _controller!.loadStyleURI(event.styleUri);

    // Re-add base layers after style change
    await LayerService.addPlacesSource(_controller!);

    // Re-add active overlays
    for (final overlayId in state.activeOverlays) {
      await LayerService.addOverlay(_controller!, overlayId);
    }

    // Re-apply filters if active
    await LayerService.applyMapFilters(
      _controller!,
      placeTypes: state.placeTypeFilter,
      altitudeMin: state.altitudeMin,
      altitudeMax: state.altitudeMax,
    );

    emit(state.copyWith(styleUri: event.styleUri));
  }

  Future<void> _onToggleOverlay(
    MapToggleOverlay event,
    Emitter<MapState> emit,
  ) async {
    if (_controller == null) return;

    final overlays = Set<String>.from(state.activeOverlays);

    if (overlays.contains(event.overlayId)) {
      // Disable: remove from set and remove layers
      overlays.remove(event.overlayId);
      await LayerService.removeOverlayById(_controller!, event.overlayId);
    } else {
      // Enable: add to set and add layers
      overlays.add(event.overlayId);
      await LayerService.addOverlay(_controller!, event.overlayId);
    }

    emit(state.copyWith(activeOverlays: overlays));
  }

  Future<void> _onFilterPlaces(
    MapFilterPlaces event,
    Emitter<MapState> emit,
  ) async {
    if (_controller == null) return;

    // Toggle: add or remove the type from the set
    final types = Set<String>.from(state.placeTypeFilter);
    if (types.contains(event.placeType)) {
      types.remove(event.placeType);
    } else {
      types.add(event.placeType);
    }

    await LayerService.applyMapFilters(
      _controller!,
      placeTypes: types,
      altitudeMin: state.altitudeMin,
      altitudeMax: state.altitudeMax,
    );
    emit(state.copyWith(placeTypeFilter: types));
  }

  Future<void> _onFilterAltitude(
    MapFilterAltitude event,
    Emitter<MapState> emit,
  ) async {
    if (_controller == null) return;

    await LayerService.applyMapFilters(
      _controller!,
      placeTypes: state.placeTypeFilter,
      altitudeMin: event.min,
      altitudeMax: event.max,
    );
    emit(
      state.copyWith(
        altitudeMin: () => event.min,
        altitudeMax: () => event.max,
      ),
    );
  }

  Future<void> _onClearFilters(
    MapClearFilters event,
    Emitter<MapState> emit,
  ) async {
    if (_controller == null) return;

    await LayerService.applyMapFilters(_controller!);
    emit(
      state.copyWith(
        placeTypeFilter: const {},
        altitudeMin: () => null,
        altitudeMax: () => null,
      ),
    );
  }

  Future<void> _onZoomIn(MapZoomIn event, Emitter<MapState> emit) async {
    if (_controller == null) return;
    final cameraState = await _controller!.getCameraState();
    await _controller!.easeTo(
      CameraOptions(zoom: cameraState.zoom + 1),
      MapAnimationOptions(duration: 300),
    );
  }

  Future<void> _onZoomOut(MapZoomOut event, Emitter<MapState> emit) async {
    if (_controller == null) return;
    final cameraState = await _controller!.getCameraState();
    await _controller!.easeTo(
      CameraOptions(zoom: cameraState.zoom - 1),
      MapAnimationOptions(duration: 300),
    );
  }

  Future<void> _onFeatureTapped(
    MapFeatureTapped event,
    Emitter<MapState> emit,
  ) async {
    // Clusters are handled directly in the tap listener (zoom in).
    // Skip feature selection logic to avoid calling setFeatureState
    // with an empty sourceID/featureId.
    if (event.feature.isCluster) return;

    final wasDeselected = await _handleFeatureSelection(event.feature);

    if (wasDeselected) {
      emit(state.copyWith(selectedPlace: () => null, isLoadingPlace: false));
    } else {
      // Move camera to selected feature
      await _controller!.easeTo(
        CameraOptions(
          center: Point(
            coordinates: Position(event.feature.lng!, event.feature.lat!),
          ),
          zoom: 14.5,
        ),
        MapAnimationOptions(duration: 500),
      );

      // Fetch full Place data by ID
      emit(state.copyWith(isLoadingPlace: true, selectedPlace: () => null));
      final place = await _placeRepository.getById(event.feature.featureId);
      emit(state.copyWith(isLoadingPlace: false, selectedPlace: () => place));
    }
  }
}
