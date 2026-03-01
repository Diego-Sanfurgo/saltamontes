// ignore_for_file: constant_identifier_names

part of 'tracking_map_bloc.dart';

enum TrackingState {
  IDLE,
  START_LOADING,
  STARTED,
  START_FAILED,
  PAUSED,
  STOP_LOADING,
  STOPPED,
  STOPPED_FAILED,
  ERROR,
}

class TrackingMapState extends Equatable {
  const TrackingMapState({this.status = TrackingState.IDLE});

  final TrackingState status;

  factory TrackingMapState.initial() =>
      const TrackingMapState(status: TrackingState.IDLE);

  TrackingMapState copyWith({TrackingState? status}) {
    return TrackingMapState(status: status ?? this.status);
  }

  @override
  List<Object> get props => [status];
}
