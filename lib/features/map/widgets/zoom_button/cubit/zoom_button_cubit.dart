import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:saltamontes/data/providers/map_controller_provider.dart';

part 'zoom_button_state.dart';

class ZoomButtonCubit extends Cubit<ZoomButtonState> {
  ZoomButtonCubit(this._mapControllerProvider) : super(ZoomButtonInitial()) {
    _mapControllerProvider.addListener(_onControllerChanged);
    _controller = _mapControllerProvider.controller;
  }

  final MapControllerProvider _mapControllerProvider;
  MapboxMap? _controller;

  void _onControllerChanged() {
    _controller = _mapControllerProvider.controller;
  }

  Future<void> zoom(double delta) async {
    if (_controller == null) return;
    final cameraState = await _controller!.getCameraState();
    await _controller!.easeTo(
      CameraOptions(zoom: cameraState.zoom + delta),
      MapAnimationOptions(duration: 300),
    );
  }

  @override
  Future<void> close() {
    _mapControllerProvider.removeListener(_onControllerChanged);
    return super.close();
  }
}
