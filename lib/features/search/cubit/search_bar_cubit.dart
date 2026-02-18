import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:saltamontes/data/models/place.dart';
import 'package:saltamontes/data/repositories/place_repository.dart';

part 'search_bar_state.dart';

class SearchBarCubit extends Cubit<SearchBarState> {
  SearchBarCubit(this._placeRepository) : super(SearchBarState());

  final PlaceRepository _placeRepository;

  Future<void> queryPeaks(String query) async {
    try {
      if (query.isEmpty) {
        emit(SearchBarState());
        return;
      }

      emit(SearchBarState(status: SearchBarStatus.loading));

      final String normalizedQuery = _normalize(query);

      final Set<Place> places = await _placeRepository.queryByName(
        normalizedQuery,
        isLimited: false,
      );

      emit(SearchBarState(status: SearchBarStatus.success, places: places));
    } on Exception catch (e, stack) {
      log(e.toString(), stackTrace: stack);
      emit(SearchBarState(status: SearchBarStatus.failure));
    }
  }
}

String _normalize(String text) {
  var withDia =
      'ÀÁÂÃÄÅàáâãäåÒÓÔÕÕÖØòóôõöøÈÉÊËèéêëðÇçÐÌÍÎÏìíîïÙÚÛÜùúûüÑñŠšŸÿýŽž';
  var withoutDia =
      'AAAAAAaaaaaaOOOOOOOooooooEEEEeeeeecCdDIIIIiiiiUUUUuuuuNnSsYyyZz';

  for (int i = 0; i < withDia.length; i++) {
    text = text.replaceAll(withDia[i], withoutDia[i]);
  }

  return text.toLowerCase().trim();
}
