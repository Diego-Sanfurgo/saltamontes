import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubit/zoom_button_cubit.dart';

class ZoomButton extends StatelessWidget {
  const ZoomButton({super.key});

  @override
  Widget build(BuildContext context) {
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
            onTap: () => context.read<ZoomButtonCubit>().zoom(1),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
              bottom: Radius.zero,
            ),
          ),

          // Zoom Out Button
          _ZoomButton(
            icon: Icons.remove,
            onTap: () => context.read<ZoomButtonCubit>().zoom(-1),
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
