import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Módulo para registrar dependencias externas que no pueden
/// anotarse directamente con @injectable.
@module
abstract class RegisterModule {
  /// SupabaseClient singleton ya inicializado por Supabase.initialize()
  @lazySingleton
  SupabaseClient get supabaseClient => Supabase.instance.client;
}
