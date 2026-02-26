import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:saltamontes/data/models/excursion.dart';
import 'package:saltamontes/features/excursion/bloc/excursion_bloc.dart';

class ExcursionList extends StatelessWidget {
  const ExcursionList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExcursionBloc, ExcursionState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        // Combinar: pending sync items primero, luego remote
        final pendingCount = state.pendingSyncCount;
        final totalItems = pendingCount + state.excursions.length;

        if (totalItems == 0) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.hiking,
                    size: 48,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Aún no tenés excursiones',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.5),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            // Pending sync items first
            if (index < pendingCount) {
              return _PendingSyncTile(index: index);
            }

            // Remote excursions
            final excursion = state.excursions[index - pendingCount];
            return _ExcursionTile(excursion: excursion);
          }, childCount: totalItems),
        );
      },
    );
  }
}

class _ExcursionTile extends StatelessWidget {
  final Excursion excursion;
  const _ExcursionTile({required this.excursion});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final hasTrack = excursion.recordedTrackId != null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: hasTrack
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest,
          child: Icon(
            hasTrack ? Icons.check : Icons.schedule,
            color: hasTrack
                ? colorScheme.onPrimaryContainer
                : colorScheme.onSurface.withValues(alpha: 0.5),
          ),
        ),
        title: Text(
          excursion.title,
          style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          DateFormat('dd/MM/yyyy HH:mm').format(excursion.scheduledStart),
          style: textTheme.bodySmall,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (excursion.isPublic)
              Icon(Icons.public, size: 18, color: colorScheme.primary),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

class _PendingSyncTile extends StatelessWidget {
  final int index;
  const _PendingSyncTile({required this.index});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: colorScheme.errorContainer.withValues(alpha: 0.3),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.errorContainer,
          child: Icon(Icons.cloud_upload, color: colorScheme.onErrorContainer),
        ),
        title: Text(
          'Excursión sin sincronizar',
          style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          'Pendiente de subida',
          style: textTheme.bodySmall?.copyWith(color: colorScheme.error),
        ),
        trailing: IconButton(
          icon: Icon(Icons.cloud_upload, color: colorScheme.error),
          tooltip: 'Reintentar subida',
          onPressed: () {
            // Retry via SyncService
            context.read<ExcursionBloc>().add(RetrySyncItem('sync_$index'));
          },
        ),
      ),
    );
  }
}
