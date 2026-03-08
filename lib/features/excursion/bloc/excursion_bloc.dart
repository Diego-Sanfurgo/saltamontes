import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:saltamontes/data/models/excursion.dart';
import 'package:saltamontes/data/repositories/excursion_repository.dart';
import 'package:saltamontes/data/repositories/sync_repository.dart';

part 'excursion_event.dart';
part 'excursion_state.dart';

class ExcursionBloc extends Bloc<ExcursionEvent, ExcursionState> {
  final ExcursionRepository _repository;
  final SyncRepository _syncRepository;

  ExcursionBloc({
    required ExcursionRepository repository,
    required SyncRepository syncRepository,
  }) : _repository = repository,
       _syncRepository = syncRepository,
       super(const ExcursionState()) {
    on<LoadExcursions>(_onLoad);
    on<CreateQuickExcursion>(_onCreateQuick);
    on<CreateScheduledExcursion>(_onCreateScheduled);
    on<RetrySyncItem>(_onRetrySync);
  }

  Future<void> _onLoad(
    LoadExcursions event,
    Emitter<ExcursionState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      // Cargar excursiones remotas (con participants y places embebidos)
      final remote = await _repository.getMyExcursions();

      // Cargar conteo de items pendientes de sync
      final pendingCount = await _syncRepository.getPendingCount();

      emit(
        state.copyWith(
          isLoading: false,
          excursions: remote,
          pendingSyncCount: pendingCount,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onCreateQuick(
    CreateQuickExcursion event,
    Emitter<ExcursionState> emit,
  ) async {
    try {
      final excursion = await _repository.createDraft();
      emit(
        state.copyWith(
          activeExcursionId: excursion.id,
          excursions: [excursion, ...state.excursions],
        ),
      );
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onCreateScheduled(
    CreateScheduledExcursion event,
    Emitter<ExcursionState> emit,
  ) async {
    try {
      final excursion = await _repository.createScheduled(
        title: event.title,
        description: event.description,
        scheduledStart: event.scheduledStart,
        isPublic: event.isPublic,
        plannedTrackId: event.plannedTrackId,
      );
      emit(state.copyWith(excursions: [excursion, ...state.excursions]));
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onRetrySync(
    RetrySyncItem event,
    Emitter<ExcursionState> emit,
  ) async {
    // Delegar retry al SyncRepository y recargar la lista
    await _syncRepository.retryItem(event.syncItemId);
    add(LoadExcursions());
  }
}
