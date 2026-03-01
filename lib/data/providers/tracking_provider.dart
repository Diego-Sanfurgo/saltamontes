import 'package:saltamontes/data/providers/base_provider.dart';

class TrackingProvider extends BaseProvider {
  static final TrackingProvider _instance = TrackingProvider._internal();

  factory TrackingProvider() => _instance;

  TrackingProvider._internal();

  Future<void> saveTrackingStatus(String status) async {
    final storage = await prefs;
    await storage.setString(ProviderKey.TRACKING.name, status);
  }

  Future<String?> getTrackingStatus() async {
    final storage = await prefs;
    return storage.getString(ProviderKey.TRACKING.name);
  }

  Future<void> clearTrackingStatus() async {
    final storage = await prefs;
    await storage.remove(ProviderKey.TRACKING.name);
  }
}
