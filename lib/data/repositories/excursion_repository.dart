import 'package:injectable/injectable.dart';
import 'package:saltamontes/data/models/excursion.dart';
import 'package:saltamontes/data/models/excursion_participant.dart';
import 'package:saltamontes/data/models/excursion_place.dart';
import 'package:saltamontes/data/models/user_track.dart';
import 'package:saltamontes/data/providers/excursion_provider.dart';

/// Repositorio de excursiones.
///
/// Orquesta la lógica de negocio delegando las operaciones
/// de datos al [ExcursionProvider].
@lazySingleton
class ExcursionRepository {
  final ExcursionProvider _provider;

  ExcursionRepository(this._provider);

  String? get _userId => _provider.currentUserId;

  // ─── Excursiones ───

  /// Crear excursión borrador (Excursión Rápida)
  Future<Excursion> createDraft() async {
    final data = Excursion(
      id: '',
      ownerId: _userId,
      title: 'Excursión rápida',
      scheduledStart: DateTime.now(),
    ).toDraftInsert();

    return await _provider.insertExcursion(data);
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

    return await _provider.insertExcursion(data);
  }

  /// Obtener mis excursiones (con participants y places embebidos)
  Future<List<Excursion>> getMyExcursions() async {
    if (_userId == null) return [];
    return await _provider.fetchMyExcursions(_userId!);
  }

  /// Actualizar recorded_track_id al finalizar excursión
  Future<void> linkRecordedTrack(
    String excursionId,
    String recordedTrackId,
  ) async {
    await _provider.updateExcursion(excursionId, {
      'recorded_track_id': recordedTrackId,
    });
  }

  // ─── Participantes ───

  /// Invitar participante por user_id
  Future<void> inviteParticipant(String excursionId, String userId) async {
    await _provider.insertParticipant(
      excursionId: excursionId,
      userId: userId,
      status: 'pending',
      isOrganizer: false,
    );
  }

  /// Aceptar invitación
  Future<void> acceptInvite(String excursionId) async {
    if (_userId == null) return;
    await _provider.updateParticipantStatus(
      excursionId: excursionId,
      userId: _userId!,
      status: 'accepted',
    );
  }

  /// Decline invitation
  Future<void> declineInvite(String excursionId) async {
    if (_userId == null) return;
    await _provider.updateParticipantStatus(
      excursionId: excursionId,
      userId: _userId!,
      status: 'declined',
    );
  }

  /// Obtener participantes de una excursión
  Future<List<ExcursionParticipant>> getParticipants(String excursionId) async {
    return await _provider.fetchParticipants(excursionId);
  }

  // ─── Tracks ───

  /// Insertar track y retornar modelo
  Future<UserTrack> insertTrack(Map<String, dynamic> trackData) async {
    return await _provider.insertTrack(trackData);
  }

  /// Obtener tracks públicos
  Future<List<UserTrack>> getPublicTracks({int limit = 20}) async {
    return await _provider.fetchPublicTracks(limit: limit);
  }

  // ─── Lugares visitados ───

  /// Obtener excursion_places del usuario (embebidos en cada Excursion)
  Future<List<ExcursionPlace>> getMyExcursionPlaces() async {
    if (_userId == null) return [];
    final excursions = await getMyExcursions();
    if (excursions.isEmpty) return [];
    return excursions.expand((e) => e.places).toList();
  }

  // ─── Sync upload ───

  /// Subir excursión completa (track + excursion update)
  Future<void> uploadExcursion({
    required Map<String, dynamic> trackJson,
    required String? excursionId,
  }) async {
    final track = await insertTrack(trackJson);
    if (excursionId != null) {
      await linkRecordedTrack(excursionId, track.id);
    }
  }
}
