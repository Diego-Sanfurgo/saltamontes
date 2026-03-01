import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:action_slider/action_slider.dart';

import 'package:saltamontes/features/map/bloc/tracking_map_bloc/tracking_map_bloc.dart';

class AnimatedActionBtn extends StatefulWidget {
  const AnimatedActionBtn({super.key});

  @override
  State<AnimatedActionBtn> createState() => _AnimatedActionBtnState();
}

class _AnimatedActionBtnState extends State<AnimatedActionBtn> {
  late final ActionSliderController standardController;
  late final ActionSliderController dualController;
  late final TrackingMapBloc bloc;

  @override
  void initState() {
    bloc = context.read<TrackingMapBloc>();
    standardController = ActionSliderController();
    dualController = ActionSliderController.dual();
    super.initState();
  }

  @override
  void dispose() {
    standardController.dispose();
    dualController.dispose();
    super.dispose();
  }

  void _handleStateChanges(TrackingMapState state) async {
    switch (state.status) {
      case TrackingState.START_LOADING:
        standardController.loading();
        break;
      case TrackingState.STARTED:
        standardController.success();
        break;
      case TrackingState.START_FAILED:
        standardController.failure();
        break;
      case TrackingState.STOP_LOADING:
        dualController.loading();
        break;
      case TrackingState.STOPPED:
        dualController.success();
        break;
      case TrackingState.STOPPED_FAILED:
        dualController.failure();
        break;
      case TrackingState.IDLE:
      case TrackingState.PAUSED:
      case TrackingState.ERROR:
        dualController.reset();
        standardController.reset();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<TrackingMapBloc, TrackingMapState>(
      listener: (context, state) => _handleStateChanges(state),
      builder: (context, state) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return AnimatedSwitcher(
              switchInCurve: Curves.easeIn,
              switchOutCurve: Curves.easeOut,
              duration: const Duration(seconds: 1),
              child:
                  state.status == TrackingState.IDLE ||
                      state.status == TrackingState.START_LOADING
                  ? _StandardSliderBtn(constraints, standardController)
                  : state.status == TrackingState.STARTED
                  ? _PausedBtn(constraints)
                  : _DualSliderBtn(constraints, dualController),
            );
          },
        );
      },
    );
  }
}

Widget _loadingIcon = const CircularProgressIndicator(
  color: Colors.white,
  padding: EdgeInsets.all(8),
);

class _StandardSliderBtn extends StatelessWidget {
  const _StandardSliderBtn(this.constraints, this.standardController);

  final BoxConstraints constraints;
  final ActionSliderController standardController;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ActionSlider.standard(
      key: const Key('standard'),
      controller: standardController,
      height: constraints.maxHeight,
      sliderBehavior: SliderBehavior.stretch,
      successIcon: const Icon(Icons.flag_outlined),
      loadingIcon: _loadingIcon,
      failureIcon: const Icon(Icons.error, color: Colors.red),
      icon: Icon(Icons.chevron_right_outlined, color: colorScheme.onPrimary),
      toggleColor: colorScheme.primary,
      customOuterBackgroundBuilder: (context, sliderState, child) =>
          _CustomOuterBackgroundBuilder(),
      action: (controller) =>
          context.read<TrackingMapBloc>().add(TrackingMapStartTracking()),
      child: const Text("Desliza para comenzar"),
    );
  }
}

class _DualSliderBtn extends StatelessWidget {
  const _DualSliderBtn(this.constraints, this.dualController);
  final BoxConstraints constraints;
  final ActionSliderController dualController;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ActionSlider.dual(
      key: const Key('dual'),
      controller: dualController,
      height: constraints.maxHeight,
      loadingIcon: _loadingIcon,
      sliderBehavior: SliderBehavior.stretch,
      icon: Icon(Icons.sync_alt_outlined, color: colorScheme.onPrimary),
      toggleColor: colorScheme.primary,
      customOuterBackgroundBuilder: (context, sliderState, child) =>
          _CustomOuterBackgroundBuilder(),
      startChild: const Text("Terminar"),
      startAction: (controller) async {
        controller.loading();
        context.read<TrackingMapBloc>().add(TrackingMapStopTracking());
        controller.success();
      },
      endChild: const Text("Reanudar"),
      endAction: (controller) async {
        controller.loading();
        context.read<TrackingMapBloc>().add(TrackingMapResumeTracking());
        controller.success();
      },
    );
  }
}

class _PausedBtn extends StatelessWidget {
  const _PausedBtn(this.constraints);
  final BoxConstraints constraints;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      style: ButtonStyle(
        fixedSize: WidgetStatePropertyAll(
          Size.fromHeight(constraints.maxHeight),
        ),
      ),
      label: const Text("Pausar"),
      icon: const Icon(Icons.pause),
      onPressed: () =>
          context.read<TrackingMapBloc>().add(TrackingMapPauseTracking()),
    );
  }
}

class _CustomOuterBackgroundBuilder extends StatelessWidget {
  const _CustomOuterBackgroundBuilder();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        color: colorScheme.surface,
        border: Border.all(color: colorScheme.primary),
      ),
    );
  }
}
