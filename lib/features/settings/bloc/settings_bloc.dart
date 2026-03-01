import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:saltamontes/data/repositories/settings_repository.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SettingsRepository _settingsRepository;

  SettingsBloc({required SettingsRepository settingsRepository})
    : _settingsRepository = settingsRepository,
      super(SettingsState.initial()) {
    on<LoadTheme>(_onLoadTheme);
    on<ToggleTheme>(_onToggleTheme);
  }

  Future<void> _onLoadTheme(
    LoadTheme event,
    Emitter<SettingsState> emit,
  ) async {
    final isDarkMode = await _settingsRepository.isDarkMode();
    emit(state.copyWith(isDarkMode: isDarkMode));
  }

  Future<void> _onToggleTheme(
    ToggleTheme event,
    Emitter<SettingsState> emit,
  ) async {
    final newMode = !state.isDarkMode;
    await _settingsRepository.setDarkMode(newMode);
    emit(state.copyWith(isDarkMode: newMode));
  }
}
