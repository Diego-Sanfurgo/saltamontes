import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:saltamontes/core/services/navigation_service.dart';
import 'package:saltamontes/data/repositories/excursion_repository.dart';
import 'package:saltamontes/features/excursion/bloc/excursion_bloc.dart';
import 'package:saltamontes/features/excursion/widgets/create_excursion_sheet.dart';

class ExcursionView extends StatelessWidget {
  const ExcursionView({super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (_) => ExcursionRepository(),
      child: BlocProvider(
        create: (context) =>
            ExcursionBloc(repository: context.read<ExcursionRepository>())
              ..add(LoadExcursions()),
        child: const _ExcursionBody(),
      ),
    );
  }
}

class _ExcursionBody extends StatelessWidget {
  const _ExcursionBody();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => NavigationService.pop(),
        ),
        title: const Text('Nueva Excursión'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateOptions(context),
        icon: const Icon(Icons.add),
        label: const Text('Crear'),
      ),
      body: BlocBuilder<ExcursionBloc, ExcursionState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.error != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 48, color: colorScheme.error),
                  const SizedBox(height: 8),
                  Text(
                    state.error!,
                    style: TextStyle(color: colorScheme.error),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () =>
                        context.read<ExcursionBloc>().add(LoadExcursions()),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state.activeExcursionId != null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 64,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '¡Excursión creada!',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Iniciá la grabación desde el mapa de seguimiento.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: () => NavigationService.pop(),
                    icon: const Icon(Icons.map),
                    label: const Text('Volver al mapa'),
                  ),
                ],
              ),
            );
          }

          // Estado inicial: opciones de creación
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                _OptionCard(
                  icon: Icons.flash_on,
                  title: 'Excursión Rápida',
                  subtitle: 'Comienza a grabar inmediatamente sin planificar.',
                  color: colorScheme.primaryContainer,
                  iconColor: colorScheme.onPrimaryContainer,
                  onTap: () =>
                      context.read<ExcursionBloc>().add(CreateQuickExcursion()),
                ),
                const SizedBox(height: 16),
                _OptionCard(
                  icon: Icons.event,
                  title: 'Excursión Programada',
                  subtitle: 'Definir fecha, ruta e invitar participantes.',
                  color: colorScheme.secondaryContainer,
                  iconColor: colorScheme.onSecondaryContainer,
                  onTap: () => _showScheduledForm(context),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showCreateOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primaryContainer,
                  child: const Icon(Icons.flash_on),
                ),
                title: const Text('Excursión Rápida'),
                subtitle: const Text('Comienza a grabar inmediatamente'),
                onTap: () {
                  NavigationService.pop();
                  context.read<ExcursionBloc>().add(CreateQuickExcursion());
                },
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.secondaryContainer,
                  child: const Icon(Icons.event),
                ),
                title: const Text('Excursión Programada'),
                subtitle: const Text(
                  'Definir fecha, ruta e invitar participantes',
                ),
                onTap: () {
                  NavigationService.pop();
                  _showScheduledForm(context);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showScheduledForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return CreateExcursionSheet(
          onSubmit:
              ({
                required title,
                description,
                required scheduledStart,
                required isPublic,
                plannedTrackId,
              }) {
                context.read<ExcursionBloc>().add(
                  CreateScheduledExcursion(
                    title: title,
                    description: description,
                    scheduledStart: scheduledStart,
                    isPublic: isPublic,
                    plannedTrackId: plannedTrackId,
                  ),
                );
              },
        );
      },
    );
  }
}

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  const _OptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: color,
                child: Icon(icon, size: 28, color: iconColor),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle, style: textTheme.bodySmall),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
