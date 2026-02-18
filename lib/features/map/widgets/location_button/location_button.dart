import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'cubit/location_cubit.dart';

class LocationButton extends StatelessWidget {
  const LocationButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationCubit, LocationState>(
      builder: (context, state) {
        return FloatingActionButton(
          heroTag: Key("location_FAB"),
          child: Icon(_getIcon(state.cameraMode)),
          onPressed: () => context.read<LocationCubit>().toggleTracking(),
        );
      },
    );
  }

  IconData _getIcon(CameraMode mode) {
    switch (mode) {
      case CameraMode.free:
        return Icons.my_location_outlined;
      case CameraMode.following:
        return Icons.explore_outlined;
      case CameraMode.compass:
        return Icons.explore;
    }
  }
}
