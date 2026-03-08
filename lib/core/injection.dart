import 'package:get_it/get_it.dart';

import 'package:saltamontes/data/providers/excursion_provider.dart';
import 'package:saltamontes/data/providers/place_provider.dart';
import 'package:saltamontes/data/providers/settings_provider.dart';
import 'package:saltamontes/data/providers/sync_provider.dart';
import 'package:saltamontes/data/providers/tracking_provider.dart';

import 'package:saltamontes/data/repositories/excursion_repository.dart';
import 'package:saltamontes/data/repositories/place_repository.dart';
import 'package:saltamontes/data/repositories/settings_repository.dart';
import 'package:saltamontes/data/repositories/sync_repository.dart';
import 'package:saltamontes/data/repositories/tracking_map_repository.dart';
import 'package:saltamontes/data/repositories/map_repository.dart' as map_repo;

/// Service Locator global.
///
/// Todas las dependencias se registran como [LazySingleton]:
/// no se instancian hasta que son referenciadas por primera vez.
final sl = GetIt.instance;

/// Registrar todas las dependencias de la aplicación.
///
/// Debe llamarse una sola vez en [initApp] antes de [runApp].
void initDependencies() {
  // ─── Providers (capa de datos / I/O) ───
  sl.registerLazySingleton<PlaceApiProvider>(() => PlaceApiProvider());
  sl.registerLazySingleton<ExcursionProvider>(() => ExcursionProvider());
  sl.registerLazySingleton<TrackingProvider>(() => TrackingProvider());
  sl.registerLazySingleton<SyncProvider>(() => SyncProvider.instance);
  sl.registerLazySingleton<SettingsProvider>(() => SettingsProvider());

  // ─── Repositories (lógica de negocio) ───
  sl.registerLazySingleton<PlaceRepository>(
    () => PlaceRepository(sl<PlaceApiProvider>()),
  );
  sl.registerLazySingleton<ExcursionRepository>(
    () => ExcursionRepository(sl<ExcursionProvider>()),
  );
  sl.registerLazySingleton<TrackingMapRepository>(
    () => TrackingMapRepository(provider: sl<TrackingProvider>()),
  );
  sl.registerLazySingleton<SyncRepository>(
    () => SyncRepository(sl<SyncProvider>()),
  );
  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepository(sl<SettingsProvider>()),
  );
  sl.registerLazySingleton<map_repo.TrackingMapRepository>(
    () => map_repo.TrackingMapRepository(sl<PlaceApiProvider>()),
  );
}
