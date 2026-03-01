import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:saltamontes/core/services/layer_service.dart';
import 'package:saltamontes/data/providers/map_controller_provider.dart';

part 'map_filter_state.dart';

class MapFilterCubit extends Cubit<MapFilterState> {
  MapFilterCubit(this._mapControllerProvider) : super(const MapFilterState()) {
    _mapControllerProvider.addListener(_onControllerChanged);
    _controller = _mapControllerProvider.controller;
  }

  final MapControllerProvider _mapControllerProvider;
  MapboxMap? _controller;

  void _onControllerChanged() {
    _controller = _mapControllerProvider.controller;
  }

  void togglePlaceType(String placeType) {
    final placeTypes = Set<String>.from(state.placeTypeFilter);
    if (placeTypes.contains(placeType)) {
      placeTypes.remove(placeType);
    } else {
      placeTypes.add(placeType);
    }
    emit(state.copyWith(placeTypeFilter: placeTypes));
  }

  void updateAltitudeFilters({double? minAlt, double? maxAlt}) {
    emit(state.copyWith(altitudeMin: () => minAlt, altitudeMax: () => maxAlt));
  }

  Future<void> applyFilters() async {
    final controller = _controller;
    if (controller == null) return;

    await LayerService.applyMapFilters(
      controller,
      placeTypes: state.placeTypeFilter,
      altitudeMin: state.altitudeMin,
      altitudeMax: state.altitudeMax,
    );
  }

  Future<void> clearFilters() async {
    final controller = _controller;
    if (controller != null) {
      await LayerService.applyMapFilters(controller);
    }
    emit(
      state.copyWith(
        placeTypeFilter: const {},
        altitudeMin: () => null,
        altitudeMax: () => null,
      ),
    );
  }

  @override
  Future<void> close() {
    _mapControllerProvider.removeListener(_onControllerChanged);
    return super.close();
  }
}
