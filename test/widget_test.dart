import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saltamontes/main.dart';
import 'package:saltamontes/data/repositories/settings_repository.dart';
import 'package:saltamontes/data/providers/settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({'is_dark_mode': false});
    final settingsRepository = SettingsRepository(SettingsProvider());

    // Build our app and trigger a frame.
    await tester.pumpWidget(App(settingsRepository: settingsRepository));

    // Verify that the app builds.
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
