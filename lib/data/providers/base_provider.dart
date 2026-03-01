// ignore_for_file: constant_identifier_names

import 'package:shared_preferences/shared_preferences.dart';

// Definimos el Enum aquí para que sea accesible
enum ProviderKey { USER, EXCURSION, TRACKING, SETTINGS }

class BaseProvider {
  // 1. Instancia estática: Compartida por todas las clases que hereden de BaseProvider
  static SharedPreferencesWithCache? _sharedPrefsInstance;

  // 2. Definimos la allowList una sola vez
  static final Set<String> _keyList = ProviderKey.values
      .map((value) => value.name)
      .toSet();

  /// Getter asíncrono inteligente.
  /// Si ya existe la instancia, la devuelve.
  /// Si no existe, la crea y espera a que esté lista.
  Future<SharedPreferencesWithCache> get prefs async {
    if (_sharedPrefsInstance != null) {
      return _sharedPrefsInstance!;
    }

    _sharedPrefsInstance = await SharedPreferencesWithCache.create(
      cacheOptions: SharedPreferencesWithCacheOptions(allowList: _keyList),
    );

    return _sharedPrefsInstance!;
  }
}
