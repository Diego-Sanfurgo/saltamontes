import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'map_filter_event.dart';
part 'map_filter_state.dart';

class MapFilterBloc extends Bloc<MapFilterEvent, MapFilterState> {
  MapFilterBloc() : super(MapFilterInitial()) {
    on<MapFilterEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
