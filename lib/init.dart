import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:saltamontes/core/services/location_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/environment/env.dart';
import 'core/injection.dart';

Future<void> initApp() async {
  MapboxOptions.setAccessToken(Environment.mapboxToken);

  await Future.wait([
    Supabase.initialize(
      url: Environment.supabaseURL,
      anonKey: Environment.supabasePublishable,
    ),

    LocationService.instance.init(),
  ]);

  // Registrar dependencias después de que Supabase esté inicializado
  initDependencies();
}
