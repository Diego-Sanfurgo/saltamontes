import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:saltamontes/core/services/navigation_service.dart';
import 'package:saltamontes/data/providers/offline_content_database.dart';

class DownloadsList extends StatefulWidget {
  const DownloadsList({super.key});

  @override
  State<DownloadsList> createState() => _DownloadsListState();
}

class _DownloadsListState extends State<DownloadsList> {
  final OfflineContentDatabase _db = OfflineContentDatabase();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<DownloadedBundle>>(
      stream: _db.watchAllBundles(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        final bundles = snapshot.data ?? [];

        if (bundles.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.download_for_offline,
                    size: 48,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'No hay descargas offline',
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
            final bundle = bundles[index];
            return _BundleTile(
              bundle: bundle,
              onDelete: () => _confirmDelete(context, bundle),
            );
          }, childCount: bundles.length),
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, DownloadedBundle bundle) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar descarga'),
        content: Text(
          '¿Eliminar "${bundle.title}"? Se borrará toda la '
          'información offline asociada.',
        ),
        actions: [
          TextButton(
            onPressed: () => NavigationService.pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              NavigationService.pop();
              await _db.deleteBundle(bundle.id);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}

class _BundleTile extends StatelessWidget {
  final DownloadedBundle bundle;
  final VoidCallback onDelete;

  const _BundleTile({required this.bundle, required this.onDelete});

  String _formatSize(int bytes) {
    if (bytes >= 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / 1024).toStringAsFixed(0)} KB';
  }

  String _formatDate(int epochMs) {
    final date = DateTime.fromMillisecondsSinceEpoch(epochMs);
    return '${date.day}/${date.month}/${date.year}';
  }

  int _backupTrackCount() {
    try {
      final data = jsonDecode(bundle.payload) as Map<String, dynamic>;
      final backups = data['backup_tracks'] as List?;
      return backups?.length ?? 0;
    } catch (_) {
      return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final backupCount = _backupTrackCount();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: colorScheme.tertiaryContainer,
          child: Icon(
            Icons.download_done,
            color: colorScheme.onTertiaryContainer,
          ),
        ),
        title: Text(
          bundle.title,
          style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${_formatSize(bundle.sizeBytes)} · ${_formatDate(bundle.downloadedAt)}'
          '${backupCount > 0 ? ' · $backupCount tracks alternos' : ''}',
          style: textTheme.bodySmall,
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete_outline, color: colorScheme.error),
          tooltip: 'Eliminar',
          onPressed: onDelete,
        ),
      ),
    );
  }
}
