part of 'map_filter_bloc.dart';

sealed class MapFilterState extends Equatable {
  const MapFilterState();
  
  @override
  List<Object> get props => [];
}

final class MapFilterInitial extends MapFilterState {}
