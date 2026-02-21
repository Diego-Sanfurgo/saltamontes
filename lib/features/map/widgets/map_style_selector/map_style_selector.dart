import 'package:bootstrap_icons/bootstrap_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:saltamontes/core/services/navigation_service.dart';
import 'package:saltamontes/core/utils/constant_and_variables.dart';
import 'package:saltamontes/features/home/bloc/map_bloc.dart';
import 'package:saltamontes/features/map/widgets/map_style_selector/cubit/map_style_cubit.dart';

// ── Data models ──

class _MapStyleOption {
  final String label;
  final String styleUri;
  final IconData icon;

  const _MapStyleOption({
    required this.label,
    required this.styleUri,
    required this.icon,
  });
}

class _OverlayOption {
  final String label;
  final String overlayId;
  final IconData icon;

  const _OverlayOption({
    required this.label,
    required this.overlayId,
    required this.icon,
  });
}

const _styles = [
  _MapStyleOption(
    label: 'Exterior',
    styleUri: MapboxStyles.OUTDOORS,
    icon: Icons.terrain,
  ),
  _MapStyleOption(
    label: 'Satélite',
    styleUri: MapboxStyles.SATELLITE_STREETS,
    icon: Icons.satellite_alt,
  ),
  _MapStyleOption(
    label: 'Calles',
    styleUri: MapboxStyles.STANDARD,
    icon: Icons.map_outlined,
  ),
  _MapStyleOption(
    label: 'Oscuro',
    styleUri: MapboxStyles.DARK,
    icon: Icons.dark_mode_outlined,
  ),
];

const _overlays = [
  _OverlayOption(
    label: 'Áreas de montaña',
    overlayId: MapConstants.mountainsSourceID,
    icon: Icons.landscape,
  ),
  _OverlayOption(
    label: 'Cuerpos de agua',
    overlayId: MapConstants.waterSourceID,
    icon: Icons.water_drop_outlined,
  ),
  _OverlayOption(
    label: 'Áreas protegidas',
    overlayId: MapConstants.parkSourceID,
    icon: Icons.park_outlined,
  ),
];

/// Shows a [DraggableScrollableSheet] with map style options and overlay toggles.
///
/// Returns a [MapStyleSelectorResult] or `null` if dismissed.
void showMapStyleSelector(BuildContext context) {
  final styleCubit = context.read<MapStyleCubit>();
  final mapBloc = context.read<MapBloc>();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => MultiBlocProvider(
      providers: [
        BlocProvider.value(value: styleCubit),
        BlocProvider.value(value: mapBloc),
      ],
      child: const _MapStyleSheet(),
    ),
  );
}

class _MapStyleSheet extends StatefulWidget {
  const _MapStyleSheet();

  @override
  State<_MapStyleSheet> createState() => _MapStyleSheetState();
}

class _MapStyleSheetState extends State<_MapStyleSheet> {
  late final MapStyleCubit cubit;
  @override
  void initState() {
    super.initState();
    cubit = BlocProvider.of<MapStyleCubit>(context);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocBuilder<MapStyleCubit, MapStyleState>(
      builder: (context, state) {
        return DraggableScrollableSheet(
          initialChildSize: 0.35,
          minChildSize: 0.2,
          maxChildSize: 0.5,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: ListView(
                controller: scrollController,
                padding: EdgeInsets.zero,
                children: [
                  // ── Header + close button ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
                    child: Row(
                      children: [
                        Text(
                          'Tipo de mapa',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(BootstrapIcons.x),
                          onPressed: () => NavigationService.pop(),
                        ),
                      ],
                    ),
                  ),

                  const Divider(),

                  // ── Style grid ──
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 4,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    children: _styles.map((style) {
                      final isSelected = style.styleUri == state.styleUri;
                      return _StyleCard(
                        label: style.label,
                        icon: style.icon,
                        isSelected: isSelected,
                        onTap: () {
                          final mapState = context.read<MapBloc>().state;
                          cubit.onChangeStyle(
                            style.styleUri,
                            placeTypes: mapState.placeTypeFilter,
                            altitudeMin: mapState.altitudeMin,
                            altitudeMax: mapState.altitudeMax,
                          );
                        },
                      );
                    }).toList(),
                  ),

                  // ── Overlays section ──
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                    child: Text(
                      'Capas',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),

                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 4,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                    children: _overlays.map((overlay) {
                      final isActive = state.activeOverlays.contains(
                        overlay.overlayId,
                      );
                      return _StyleCard(
                        label: overlay.label,
                        icon: overlay.icon,
                        isSelected: isActive,
                        onTap: () => cubit.onToggleOverlay(overlay.overlayId),
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _StyleCard extends StatelessWidget {
  const _StyleCard({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: colorScheme.primary, width: 2)
              : null,
        ),
        child: Column(
          spacing: 8,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurfaceVariant,
            ),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isSelected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
