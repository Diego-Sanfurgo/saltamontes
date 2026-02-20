import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:saltamontes/core/services/layer_service.dart';

part 'map_style_state.dart';

class MapStyleCubit extends Cubit<MapStyleState> {
  MapStyleCubit() : super(const MapStyleState());

  late MapboxMap? _controller;

  void setController(MapboxMap controller) {
    _controller = controller;
  }

  Future<void> onChangeStyle(
    String styleUri, {
    required Set<String> placeTypes,
    double? altitudeMin,
    double? altitudeMax,
  }) async {
    if (_controller == null) return;
    await _controller!.loadStyleURI(styleUri);

    // Re-add base layers after style change
    await LayerService.addPlacesSource(_controller!);

    // Re-add active overlays
    for (final overlayId in state.activeOverlays) {
      await LayerService.addOverlay(_controller!, overlayId);
    }

    // Re-apply filters if active
    await LayerService.applyMapFilters(
      _controller!,
      placeTypes: placeTypes,
      altitudeMin: altitudeMin,
      altitudeMax: altitudeMax,
    );

    emit(state.copyWith(styleUri: styleUri));
  }

  Future<void> onToggleOverlay(String overlayId) async {
    if (_controller == null) return;

    final overlays = Set<String>.from(state.activeOverlays);

    if (overlays.contains(overlayId)) {
      // Disable: remove from set and remove layers
      overlays.remove(overlayId);
      await LayerService.removeOverlayById(_controller!, overlayId);
    } else {
      // Enable: add to set and add layers
      overlays.add(overlayId);
      await LayerService.addOverlay(_controller!, overlayId);
    }

    emit(state.copyWith(activeOverlays: overlays));
  }
}
