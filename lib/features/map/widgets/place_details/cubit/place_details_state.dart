import 'package:equatable/equatable.dart';
import 'package:saltamontes/data/models/place.dart';

class PlaceDetailsState extends Equatable {
  const PlaceDetailsState({
    this.isLoadingPois = false,
    this.pois = const {},
    this.error,
  });

  final bool isLoadingPois;
  final Set<Place> pois;
  final String? error;

  PlaceDetailsState copyWith({
    bool? isLoadingPois,
    Set<Place>? pois,
    String? error,
  }) {
    return PlaceDetailsState(
      isLoadingPois: isLoadingPois ?? this.isLoadingPois,
      pois: pois ?? this.pois,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [isLoadingPois, pois, error];
}
