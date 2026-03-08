import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/di/injection.dart';
import 'core/environment/env.dart';

Future<void> initApp() async {
  MapboxOptions.setAccessToken(Environment.mapboxToken);

  await Supabase.initialize(
    url: Environment.supabaseURL,
    anonKey: Environment.supabasePublishable,
  );

  // Registrar todas las dependencias después de que Supabase esté inicializado.
  // LocationService se inicializa automáticamente via @PostConstruct.
  await configureDependencies();
}
