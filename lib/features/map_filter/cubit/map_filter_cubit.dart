import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:saltamontes/core/services/layer_service.dart';

part 'map_filter_state.dart';

class MapFilterCubit extends Cubit<MapFilterState> {
  MapboxMap? _controller;

  MapFilterCubit() : super(const MapFilterState());

  void setController(MapboxMap controller) {
    _controller = controller;
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
}
