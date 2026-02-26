import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:saltamontes/data/models/excursion.dart';
import 'package:saltamontes/data/models/excursion_participant.dart';
import 'package:saltamontes/data/models/excursion_place.dart';
import 'package:saltamontes/data/models/user_track.dart';
import 'package:saltamontes/data/models/place.dart';

class ExcursionRepository {
  final SupabaseClient _client;

  ExcursionRepository({SupabaseClient? client})
    : _client = client ?? Supabase.instance.client;

  String? get _userId => _client.auth.currentUser?.id;

  // ─── Excursiones ───

  /// Crear excursión borrador (Excursión Rápida)
  Future<Excursion> createDraft() async {
    final data = Excursion(
      id: '', // server generates
      ownerId: _userId,
      title: 'Excursión rápida',
      scheduledStart: DateTime.now(),
    ).toDraftInsert();

    final response = await _client
        .from('excursions')
        .insert(data)
        .select()
        .single();
    return Excursion.fromJson(response);
  }

  /// Crear excursión programada
  Future<Excursion> createScheduled({
    required String title,
    String? description,
    required DateTime scheduledStart,
    required bool isPublic,
    String? plannedTrackId,
  }) async {
    final data = Excursion(
      id: '',
      ownerId: _userId,
      title: title,
      description: description,
      scheduledStart: scheduledStart,
      isPublic: isPublic,
      plannedTrackId: plannedTrackId,
    ).toScheduledInsert();

    final response = await _client
        .from('excursions')
        .insert(data)
        .select()
        .single();
    return Excursion.fromJson(response);
  }

  /// Obtener mis excursiones
  Future<List<Excursion>> getMyExcursions() async {
    if (_userId == null) return [];
    final response = await _client
        .from('excursions')
        .select()
        .eq('owner_id', _userId!)
        .order('scheduled_start', ascending: false);
    return (response as List).map((e) => Excursion.fromJson(e)).toList();
  }

  /// Actualizar recorded_track_id al finalizar excursión
  Future<void> linkRecordedTrack(
    String excursionId,
    String recordedTrackId,
  ) async {
    await _client
        .from('excursions')
        .update({'recorded_track_id': recordedTrackId})
        .eq('id', excursionId);
  }

  // ─── Participantes ───

  /// Invitar participante por user_id
  Future<void> inviteParticipant(String excursionId, String userId) async {
    await _client.from('excursion_participants').insert({
      'excursion_id': excursionId,
      'user_id': userId,
      'status': 'pending',
      'is_organizer': false,
    });
  }

  /// Aceptar invitación
  Future<void> acceptInvite(String excursionId) async {
    if (_userId == null) return;
    await _client
        .from('excursion_participants')
        .update({'status': 'accepted'})
        .eq('excursion_id', excursionId)
        .eq('user_id', _userId!);
  }

  /// Decline invitation
  Future<void> declineInvite(String excursionId) async {
    if (_userId == null) return;
    await _client
        .from('excursion_participants')
        .update({'status': 'declined'})
        .eq('excursion_id', excursionId)
        .eq('user_id', _userId!);
  }

  /// Obtener participantes de una excursión
  Future<List<ExcursionParticipant>> getParticipants(String excursionId) async {
    final response = await _client
        .from('excursion_participants')
        .select()
        .eq('excursion_id', excursionId);
    return (response as List)
        .map((e) => ExcursionParticipant.fromJson(e))
        .toList();
  }

  // ─── Tracks ───

  /// Insertar track en Supabase
  Future<UserTrack> insertTrack(Map<String, dynamic> trackData) async {
    final response = await _client
        .from('user_tracks')
        .insert(trackData)
        .select()
        .single();
    return UserTrack.fromJson(response);
  }

  /// Obtener tracks públicos (para selector de planned_track_id)
  Future<List<UserTrack>> getPublicTracks({int limit = 20}) async {
    final response = await _client
        .from('user_tracks')
        .select()
        .order('created_at', ascending: false)
        .limit(limit);
    return (response as List).map((e) => UserTrack.fromJson(e)).toList();
  }

  // ─── Lugares visitados ───

  /// Obtener lugares visitados por el usuario (via excursion_places)
  Future<List<Place>> getVisitedPlaces() async {
    if (_userId == null) return [];
    // TODO: Implementar join con geo_core.places via Supabase
    // De momento retornamos lista vacía
    return [];
  }

  /// Obtener excursion_places del usuario
  Future<List<ExcursionPlace>> getMyExcursionPlaces() async {
    if (_userId == null) return [];

    // Primero obtener mis excursion IDs
    final excursions = await getMyExcursions();
    if (excursions.isEmpty) return [];

    final ids = excursions.map((e) => e.id).toList();
    final response = await _client
        .from('excursion_places')
        .select()
        .inFilter('excursion_id', ids)
        .order('visited_at', ascending: false);

    return (response as List).map((e) => ExcursionPlace.fromJson(e)).toList();
  }

  // ─── Sync upload ───

  /// Subir excursión completa (track + excursion update)
  Future<void> uploadExcursion({
    required Map<String, dynamic> trackJson,
    required String? excursionId,
  }) async {
    // 1. Insertar el track
    final track = await insertTrack(trackJson);

    // 2. Actualizar la excursión si existe
    if (excursionId != null) {
      await linkRecordedTrack(excursionId, track.id);
    }
  }
}
