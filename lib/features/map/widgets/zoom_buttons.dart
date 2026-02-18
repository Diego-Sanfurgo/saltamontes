import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saltamontes/features/home/bloc/map_bloc.dart';

class ZoomButtons extends StatelessWidget {
  const ZoomButtons({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Zoom In Button
          _ZoomButton(
            icon: Icons.add,
            onTap: () => context.read<MapBloc>().add(MapZoom(1.0)),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
              bottom: Radius.zero,
            ),
          ),

          // Divider
          Divider(height: 1, thickness: 1, color: colorScheme.outlineVariant),

          // Zoom Out Button
          _ZoomButton(
            icon: Icons.remove,
            onTap: () => context.read<MapBloc>().add(MapZoom(-1.0)),
            borderRadius: const BorderRadius.vertical(
              top: Radius.zero,
              bottom: Radius.circular(16),
            ),
          ),
        ],
      ),
    );
  }
}

class _ZoomButton extends StatelessWidget {
  const _ZoomButton({
    required this.icon,
    required this.onTap,
    required this.borderRadius,
  });

  final IconData icon;
  final VoidCallback onTap;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surfaceContainerHigh,
      child: InkWell(
        onTap: onTap,
        borderRadius: borderRadius,
        child: SizedBox(
          width: 48, // Standard FAB size-ish
          height: 48,
          child: Icon(icon, color: colorScheme.onSurface),
        ),
      ),
    );
  }
}
