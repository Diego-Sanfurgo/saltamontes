import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:saltamontes/data/repositories/place_repository.dart';

import 'place_details_state.dart';

@injectable
class PlaceDetailsCubit extends Cubit<PlaceDetailsState> {
  PlaceDetailsCubit(this._placeRepository) : super(const PlaceDetailsState());

  final PlaceRepository _placeRepository;

  Future<void> loadPois(String protectedAreaId) async {
    emit(state.copyWith(isLoadingPois: true, error: null));
    try {
      final pois = await _placeRepository.getByProtectedAreaId(protectedAreaId);
      emit(state.copyWith(isLoadingPois: false, pois: pois));
    } catch (e) {
      emit(state.copyWith(isLoadingPois: false, error: e.toString()));
    }
  }
}
