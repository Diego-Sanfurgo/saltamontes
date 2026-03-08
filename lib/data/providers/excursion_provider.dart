import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:saltamontes/data/models/excursion.dart';
import 'package:saltamontes/data/models/excursion_participant.dart';
import 'package:saltamontes/data/models/excursion_place.dart';
import 'package:saltamontes/data/models/user_track.dart';

/// Provider de datos para excursiones.
///
/// Responsable de:
/// - Ejecutar consultas a Supabase
/// - Mapear JSON ↔ Objetos tipados
class ExcursionProvider {
  final SupabaseClient _client;

  ExcursionProvider({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  String? get currentUserId => _client.auth.currentUser?.id;

  // ─── Excursiones ───

  /// Insertar excursión y retornar objeto tipado con relaciones embebidas
  Future<Excursion> insertExcursion(Map<String, dynamic> data) async {
    final response = await _client
        .from('excursions')
        .insert(data)
        .select('*, excursion_participants(*), excursion_places(*)')
        .single();
    return Excursion.fromJson(response);
  }

  /// Obtener excursiones del usuario con participantes y lugares embebidos
  Future<List<Excursion>> fetchMyExcursions(String userId) async {
    final response = await _client
        .from('excursions')
        .select('*, excursion_participants(*), excursion_places(*)')
        .eq('owner_id', userId)
        .order('scheduled_start', ascending: false);
    return response.map((e) => Excursion.fromJson(e)).toList();
  }

  /// Actualizar campos de una excursión
  Future<void> updateExcursion(String id, Map<String, dynamic> data) async {
    await _client.from('excursions').update(data).eq('id', id);
  }

  // ─── Participantes ───

  /// Insertar un participante
  Future<void> insertParticipant({
    required String excursionId,
    required String userId,
    required String status,
    required bool isOrganizer,
  }) async {
    await _client.from('excursion_participants').insert({
      'excursion_id': excursionId,
      'user_id': userId,
      'status': status,
      'is_organizer': isOrganizer,
    });
  }

  /// Actualizar el status de un participante
  Future<void> updateParticipantStatus({
    required String excursionId,
    required String userId,
    required String status,
  }) async {
    await _client
        .from('excursion_participants')
        .update({'status': status})
        .eq('excursion_id', excursionId)
        .eq('user_id', userId);
  }

  /// Obtener participantes de una excursión
  Future<List<ExcursionParticipant>> fetchParticipants(
    String excursionId,
  ) async {
    final response = await _client
        .from('excursion_participants')
        .select()
        .eq('excursion_id', excursionId);
    return response.map((e) => ExcursionParticipant.fromJson(e)).toList();
  }

  // ─── Tracks ───

  /// Insertar track en geo_core.user_tracks
  Future<UserTrack> insertTrack(Map<String, dynamic> trackData) async {
    final response = await _client
        .schema('geo_core')
        .from('user_tracks')
        .insert(trackData)
        .select()
        .single();
    return UserTrack.fromJson(response);
  }

  /// Obtener tracks públicos
  Future<List<UserTrack>> fetchPublicTracks({int limit = 20}) async {
    final response = await _client
        .from('user_tracks')
        .select()
        .order('created_at', ascending: false)
        .limit(limit);
    return response.map((e) => UserTrack.fromJson(e)).toList();
  }

  // ─── Excursion Places ───

  /// Obtener excursion_places filtrados por IDs
  Future<List<ExcursionPlace>> fetchExcursionPlaces(
    List<String> excursionIds,
  ) async {
    final response = await _client
        .from('excursion_places')
        .select()
        .inFilter('excursion_id', excursionIds)
        .order('visited_at', ascending: false);
    return response.map((e) => ExcursionPlace.fromJson(e)).toList();
  }
}
