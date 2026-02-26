import 'dart:convert';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:latlong2/latlong.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:saltamontes/core/services/layer_service.dart';
import 'package:saltamontes/core/services/location_service.dart';
import 'package:saltamontes/core/services/trace_service.dart';
import 'package:saltamontes/core/services/sync_service.dart';
import 'package:saltamontes/core/utils/constant_and_variables.dart';
import 'package:saltamontes/data/repositories/tracking_map_repository.dart';

import '../functions/add_tracking_polyline.dart';

part 'tracking_map_event.dart';
part 'tracking_map_state.dart';

class TrackingMapBloc extends Bloc<TrackingMapEvent, TrackingMapState> {
  TrackingMapBloc({required TrackingMapRepository repository})
    : _repository = repository,
      super(TrackingMapState.initial()) {
    on<TrackingMapCreated>(_onMapCreated);
    on<TrackingMapStartTracking>(_onStartTracking);
    on<TrackingMapStopTracking>(_onStopTracking);
    on<TrackingMapPauseTracking>(_onPauseTracking);
    on<TrackingMapResumeTracking>(_onResumeTracking);
    on<TrackingMapCenterCameraOnUser>(_onCenterCameraOnUser);
  }

  MapboxMap? _controller;
  final TrackingMapRepository _repository;
  final LocationService _locationService = LocationService.instance;
  final TraceService _traceService = TraceService();

  Future<void> _onMapCreated(
    TrackingMapCreated event,
    Emitter<TrackingMapState> emit,
  ) async {
    _controller = event.controller;
    _controller!.location.updateSettings(
      LocationComponentSettings(enabled: true, puckBearingEnabled: true),
    );
    add(TrackingMapCenterCameraOnUser());
  }

  Future<void> _onStartTracking(
    TrackingMapStartTracking event,
    Emitter<TrackingMapState> emit,
  ) async {
    try {
      if (_controller == null) return;

      emit(state.copyWith(status: TrackingState.START_LOADING));

      geo.Position? position = _locationService.lastPosition;
      if (position == null) return;

      final Map<String, dynamic> geojson = FeatureCollection(
        features: [
          Feature(
            id: '000',
            geometry: LineString(
              coordinates: [Position(position.longitude, position.latitude)],
            ),
          ),
        ],
      ).toJson();

      await LayerService.addTrackingLayer(
        _controller!,
        jsonEncode(geojson),
        MapConstants.trackingID,
      );
      await _traceService.startTracking();
      await updateMapTrack(await _traceService.getAllTraces(), _controller);

      await Future.delayed(const Duration(seconds: 1));
      emit(state.copyWith(status: TrackingState.STARTED));
    } on Exception catch (e) {
      log(e.toString());
      emit(state.copyWith(status: TrackingState.START_FAILED));
    }
  }

  Future<void> _onPauseTracking(
    TrackingMapPauseTracking event,
    Emitter<TrackingMapState> emit,
  ) async {
    try {
      if (_controller == null) return;
      // emit(state.copyWith(state: TrackingState.STOP_LOADING));
      await updateMapTrack(await _traceService.getAllTraces(), _controller);
      emit(state.copyWith(status: TrackingState.PAUSED));
    } on Exception {
      emit(state.copyWith(status: TrackingState.ERROR));
    }
  }

  Future<void> _onResumeTracking(
    TrackingMapResumeTracking event,
    Emitter<TrackingMapState> emit,
  ) async {
    try {
      if (_controller == null) return;
      emit(state.copyWith(status: TrackingState.START_LOADING));
      await _traceService.startTracking();
      await updateMapTrack(await _traceService.getAllTraces(), _controller);
      emit(state.copyWith(status: TrackingState.STARTED));
    } on Exception catch (e) {
      log(e.toString());
      emit(state.copyWith(status: TrackingState.START_FAILED));
    }
  }

  Future<void> _onStopTracking(
    TrackingMapStopTracking event,
    Emitter<TrackingMapState> emit,
  ) async {
    try {
      if (_controller == null) return;
      emit(state.copyWith(status: TrackingState.STOP_LOADING));
      await _traceService.stopTracking();
      await updateMapTrack(await _traceService.getAllTraces(), _controller);

      // Compile-and-queue para sync offline-first (Module 5)
      await SyncService.instance.enqueueExcursion();

      emit(state.copyWith(status: TrackingState.STOPPED));
      await Future.delayed(const Duration(seconds: 1));
      emit(state.copyWith(status: TrackingState.IDLE));
    } on Exception {
      emit(state.copyWith(status: TrackingState.STOPPED_FAILED));
    }
  }

  Future<void> _onCenterCameraOnUser(
    TrackingMapCenterCameraOnUser event,
    Emitter<TrackingMapState> emit,
  ) async {
    LatLng coords = LatLng(
      _locationService.lastPosition!.latitude,
      _locationService.lastPosition!.longitude,
    );

    _controller?.flyTo(
      CameraOptions(
        zoom: 14.0,
        center: Point(coordinates: Position(coords.longitude, coords.latitude)),
      ),
      MapAnimationOptions(duration: 500),
    );
  }
}

// Future<void> _locationTracking() async {
//   final traceService = TraceService();
//   traceService.onLocation.listen((p) {
//     // actualizar UI: velocidad, altitud, desnivel, ETA calculado, etc.
//   });

//   // al iniciar:
//   await traceService.startTracking();

//   // para mostrar trazas offline:
//   final traces = await traceService
//       .getAllTraces(); // ordenadas por id/timestamp
//   // muestra en mapa (e.g. flutter_map o google_maps_flutter)
// }
