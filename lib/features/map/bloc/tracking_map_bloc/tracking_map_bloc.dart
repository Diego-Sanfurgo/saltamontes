import 'dart:convert';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

import 'package:saltamontes/core/services/layer_service.dart';
import 'package:saltamontes/core/services/location_service.dart';
import 'package:saltamontes/core/services/trace_service.dart';
import 'package:saltamontes/core/services/sync_service.dart';
import 'package:saltamontes/core/utils/constant_and_variables.dart';
import 'package:saltamontes/data/providers/map_controller_provider.dart';
import 'package:saltamontes/data/repositories/tracking_map_repository.dart';
import 'package:saltamontes/features/map/functions/add_tracking_polyline.dart';

part 'tracking_map_event.dart';
part 'tracking_map_state.dart';

class TrackingMapBloc extends Bloc<TrackingMapEvent, TrackingMapState> {
  TrackingMapBloc({
    required TrackingMapRepository repository,
    required MapControllerProvider mapControllerProvider,
  }) : _repository = repository,
       _mapControllerProvider = mapControllerProvider,
       super(const TrackingMapState()) {
    on<TrackingMapInitialize>(_onInitialize);
    on<TrackingMapStartTracking>(_onStartTracking);
    on<TrackingMapStopTracking>(_onStopTracking);
    on<TrackingMapPauseTracking>(_onPauseTracking);
    on<TrackingMapResumeTracking>(_onResumeTracking);
    _mapControllerProvider.addListener(_onControllerChanged);
  }

  Future<void> _onInitialize(
    TrackingMapInitialize event,
    Emitter<TrackingMapState> emit,
  ) async {
    final status = await _repository.getTrackingStatus();
    emit(state.copyWith(status: _parseStatus(status)));
  }

  static TrackingState _parseStatus(String? status) {
    switch (status) {
      case 'STARTED':
        return TrackingState.STARTED;
      case 'PAUSED':
        return TrackingState.PAUSED;
      default:
        return TrackingState.IDLE;
    }
  }

  MapboxMap? _controller;
  final TrackingMapRepository _repository;
  final MapControllerProvider _mapControllerProvider;
  // final LocationService _locationService = LocationService.instance;
  final TraceService _traceService = TraceService();

  void _onControllerChanged() {
    _controller = _mapControllerProvider.controller;
  }

  Future<void> _onStartTracking(
    TrackingMapStartTracking event,
    Emitter<TrackingMapState> emit,
  ) async {
    try {
      if (_controller == null) return;

      emit(state.copyWith(status: TrackingState.START_LOADING));

      geo.Position? position = LocationService.instance.lastPosition;
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
    } finally {
      _repository.saveTrackingStatus(state.status.name);
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
    } finally {
      _repository.saveTrackingStatus(state.status.name);
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
    } finally {
      _repository.saveTrackingStatus(state.status.name);
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

      await _repository.clearTrackingStatus();
      emit(state.copyWith(status: TrackingState.STOPPED));
      await Future.delayed(const Duration(seconds: 1));
      emit(state.copyWith(status: TrackingState.IDLE));
    } on Exception {
      emit(state.copyWith(status: TrackingState.STOPPED_FAILED));
    } finally {
      _repository.saveTrackingStatus(state.status.name);
    }
  }

  @override
  Future<void> close() {
    _mapControllerProvider.removeListener(_onControllerChanged);
    return super.close();
  }
}
