// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:saltamontes/core/di/register_module.dart' as _i25;
import 'package:saltamontes/core/services/location_service.dart' as _i321;
import 'package:saltamontes/core/services/native_tracking_service.dart'
    as _i223;
import 'package:saltamontes/data/providers/excursion_provider.dart' as _i224;
import 'package:saltamontes/data/providers/place_provider.dart' as _i605;
import 'package:saltamontes/data/providers/settings_provider.dart' as _i490;
import 'package:saltamontes/data/providers/sync_provider.dart' as _i717;
import 'package:saltamontes/data/providers/tracking_provider.dart' as _i571;
import 'package:saltamontes/data/repositories/excursion_repository.dart'
    as _i249;
import 'package:saltamontes/data/repositories/map_repository.dart' as _i701;
import 'package:saltamontes/data/repositories/place_repository.dart' as _i44;
import 'package:saltamontes/data/repositories/settings_repository.dart'
    as _i674;
import 'package:saltamontes/data/repositories/sync_repository.dart' as _i929;
import 'package:saltamontes/data/repositories/tracking_map_repository.dart'
    as _i603;
import 'package:supabase_flutter/supabase_flutter.dart' as _i454;
import 'package:saltamontes/features/map/widgets/place_details/cubit/place_details_cubit.dart'
    as _iCub;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  Future<_i174.GetIt> init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) async {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    gh.lazySingleton<_i454.SupabaseClient>(() => registerModule.supabaseClient);
    await gh.lazySingletonAsync<_i321.LocationService>(
      () {
        final i = _i321.LocationService();
        return i.init().then((_) => i);
      },
      preResolve: true,
      dispose: (i) => i.dispose(),
    );
    gh.lazySingleton<_i223.NativeTrackingService>(
      () => _i223.NativeTrackingService(),
    );
    gh.lazySingleton<_i490.SettingsProvider>(() => _i490.SettingsProvider());
    gh.lazySingleton<_i571.TrackingProvider>(() => _i571.TrackingProvider());
    gh.lazySingleton<_i674.SettingsRepository>(
      () => _i674.SettingsRepository(gh<_i490.SettingsProvider>()),
    );
    gh.lazySingleton<_i717.SyncProvider>(
      () => _i717.SyncProvider(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i929.SyncRepository>(
      () => _i929.SyncRepository(gh<_i717.SyncProvider>()),
    );
    gh.lazySingleton<_i224.ExcursionProvider>(
      () => _i224.ExcursionProvider(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i605.PlaceApiProvider>(
      () => _i605.PlaceApiProvider(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i249.ExcursionRepository>(
      () => _i249.ExcursionRepository(gh<_i224.ExcursionProvider>()),
    );
    gh.lazySingleton<_i701.MapPlaceRepository>(
      () => _i701.MapPlaceRepository(gh<_i605.PlaceApiProvider>()),
    );
    gh.lazySingleton<_i44.PlaceRepository>(
      () => _i44.PlaceRepository(gh<_i605.PlaceApiProvider>()),
    );
    gh.factory<_iCub.PlaceDetailsCubit>(
      () => _iCub.PlaceDetailsCubit(gh<_i44.PlaceRepository>()),
    );
    gh.lazySingleton<_i603.TrackingMapRepository>(
      () => _i603.TrackingMapRepository(provider: gh<_i571.TrackingProvider>()),
    );
    return this;
  }
}

class _$RegisterModule extends _i25.RegisterModule {}
