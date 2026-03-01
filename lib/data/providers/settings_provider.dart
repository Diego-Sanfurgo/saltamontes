import 'package:saltamontes/data/providers/base_provider.dart';

class SettingsProvider extends BaseProvider {
  static final SettingsProvider _instance = SettingsProvider._internal();

  factory SettingsProvider() => _instance;

  SettingsProvider._internal();

  Future<bool?> getThemeMode() async {
    final storage = await prefs;
    return storage.getBool(ProviderKey.SETTINGS.name);
  }

  Future<void> setThemeMode(bool isDarkMode) async {
    final storage = await prefs;
    await storage.setBool(ProviderKey.SETTINGS.name, isDarkMode);
  }
}
