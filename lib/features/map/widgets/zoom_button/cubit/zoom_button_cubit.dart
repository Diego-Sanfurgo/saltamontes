import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

part 'zoom_button_state.dart';

class ZoomButtonCubit extends Cubit<ZoomButtonState> {
  ZoomButtonCubit() : super(ZoomButtonInitial());
  MapboxMap? _controller;

  void setController(MapboxMap controller) {
    _controller = controller;
  }

  Future<void> zoom(double delta) async {
    if (_controller == null) return;
    final cameraState = await _controller!.getCameraState();
    await _controller!.easeTo(
      CameraOptions(zoom: cameraState.zoom + delta),
      MapAnimationOptions(duration: 300),
    );
  }
}
