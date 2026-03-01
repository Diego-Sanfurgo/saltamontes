import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:saltamontes/core/theme/theme.dart';
import 'package:saltamontes/core/router/app_router.dart';
import 'package:saltamontes/data/providers/settings_provider.dart';
import 'package:saltamontes/data/repositories/settings_repository.dart';
import 'package:saltamontes/features/settings/bloc/settings_bloc.dart';

import 'core/utils/constant_and_variables.dart';

import 'package:saltamontes/init.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initApp();
  final settingsRepository = SettingsRepository(SettingsProvider());

  runApp(App(settingsRepository: settingsRepository));
}

class App extends StatelessWidget {
  final SettingsRepository settingsRepository;

  const App({super.key, required this.settingsRepository});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: settingsRepository,
      child: BlocProvider(
        create: (context) =>
            SettingsBloc(settingsRepository: settingsRepository)
              ..add(LoadTheme()),
        child: BlocBuilder<SettingsBloc, SettingsState>(
          builder: (context, state) {
            return MaterialApp.router(
              routerConfig: AppRouter.router,
              debugShowCheckedModeBanner: false,
              scaffoldMessengerKey: AppUtil.scaffoldKey,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: state.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            );
          },
        ),
      ),
    );
  }
}
