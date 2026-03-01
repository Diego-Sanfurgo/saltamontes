import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saltamontes/core/theme/colors.dart';
import 'package:saltamontes/data/providers/map_controller_provider.dart';
import 'cubit/location_cubit.dart';

class LocationFAB extends StatelessWidget {
  const LocationFAB({super.key});

  @override
  Widget build(BuildContext context) {
    final mapControllerProvider = context.read<MapControllerProvider>();
    return BlocProvider(
      create: (context) => LocationCubit(mapControllerProvider),
      child: const _LocationFABWidget(),
    );
  }
}

class _LocationFABWidget extends StatelessWidget {
  const _LocationFABWidget();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LocationCubit, LocationState>(
      builder: (context, state) {
        return FloatingActionButton(
          backgroundColor: state.cameraMode != CameraMode.compass
              ? Theme.of(context).colorScheme.surface
              : AppColors.accentColor,
          heroTag: Key("location_FAB"),
          child: Icon(
            _getIcon(state.cameraMode),
            color: state.cameraMode != CameraMode.compass
                ? Theme.of(context).colorScheme.onSurface
                : Colors.white,
          ),
          onPressed: () => context.read<LocationCubit>().toggleTracking(),
        );
      },
    );
  }

  IconData _getIcon(CameraMode mode) {
    switch (mode) {
      case CameraMode.free:
        return BootstrapIcons.crosshair;
      case CameraMode.following:
        return BootstrapIcons.compass;
      case CameraMode.compass:
        return BootstrapIcons.compass_fill;
    }
  }
}
