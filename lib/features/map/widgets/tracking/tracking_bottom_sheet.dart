import 'package:flutter/material.dart';

import 'metrics_grid.dart';

class TrackingBottomSheet extends StatelessWidget {
  const TrackingBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SafeArea(
      child: DraggableScrollableSheet(
        initialChildSize: 0.15,
        minChildSize: 0.15,
        maxChildSize: 1.0,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              child: Column(
                children: [
                  // Handle indicator
                  Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  // Metrics Grid
                  const MetricsGridWidget(),

                  // Action List
                  const _ActionsListWidget(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ActionsListWidget extends StatelessWidget {
  const _ActionsListWidget();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ListItem(Icons.directions_run, "Actividad", onTap: () {}),
        _ListItem(Icons.share_location, "Compartir en vivo", onTap: () {}),
        _ListItem(Icons.terrain, "Condiciones de la ruta", onTap: () {}),
        _ListItem(Icons.add_road, "Añadir ruta", onTap: () {}),
      ],
    );
  }
}

class _ListItem extends StatelessWidget {
  const _ListItem(this.icon, this.text, {this.onTap});

  final IconData icon;
  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueGrey),
      title: Text(text),
      onTap: onTap,
    );
  }
}
