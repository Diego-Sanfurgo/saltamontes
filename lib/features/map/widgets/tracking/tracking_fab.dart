import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:saltamontes/core/services/navigation_service.dart';
import 'package:saltamontes/features/excursion/bloc/excursion_bloc.dart';
import 'package:saltamontes/features/map/bloc/tracking_map_bloc/tracking_map_bloc.dart';

import '../create_excursion_sheet.dart';

class TrackingFAB extends StatelessWidget {
  const TrackingFAB({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => _showCreateOptions(context),
      child: const Icon(BootstrapIcons.plus_lg),
    );
  }
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
                child: const Icon(BootstrapIcons.record_circle),
              ),
              title: const Text('Grabar actividad'),
              subtitle: const Text('Comienza a grabar inmediatamente'),
              onTap: () {
                NavigationService.pop();
                context.read<TrackingMapBloc>().add(TrackingMapStartTracking());
              },
            ),
            ListTile(
              leading: CircleAvatar(
                child: const Icon(BootstrapIcons.calendar3_event),
              ),
              title: const Text('Crear excursión'),
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
