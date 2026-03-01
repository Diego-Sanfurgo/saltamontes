import 'package:saltamontes/data/providers/tracking_provider.dart';

class TrackingMapRepository {
  final TrackingProvider _provider;

  TrackingMapRepository({required TrackingProvider provider})
    : _provider = provider;

  // Persists tracking status string (e.g. 'STARTED', 'PAUSED')
  Future<void> saveTrackingStatus(String status) async {
    await _provider.saveTrackingStatus(status);
  }

  // Gets persisted tracking status, defaults to null if not tracking
  Future<String?> getTrackingStatus() async {
    return await _provider.getTrackingStatus();
  }

  // Clear tracking status when stopped
  Future<void> clearTrackingStatus() async {
    await _provider.clearTrackingStatus();
  }
}
