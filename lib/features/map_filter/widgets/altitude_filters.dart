import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saltamontes/features/home/bloc/map_bloc.dart';

const double _altMin = 0;
const double _altMax = 5000;

class AltitudeFilters extends StatefulWidget {
  const AltitudeFilters({super.key});

  @override
  State<AltitudeFilters> createState() => _AltitudeFiltersState();
}

class _AltitudeFiltersState extends State<AltitudeFilters> {
  late final TextEditingController _minController;
  late final TextEditingController _maxController;

  // Local slider values (updated live during drag)
  double _sliderMin = _altMin;
  double _sliderMax = _altMax;

  @override
  void initState() {
    super.initState();
    final state = context.read<MapBloc>().state;
    _sliderMin = state.altitudeMin ?? _altMin;
    _sliderMax = state.altitudeMax ?? _altMax;

    _minController = TextEditingController(
      text: state.altitudeMin != null
          ? state.altitudeMin!.round().toString()
          : '',
    );
    _maxController = TextEditingController(
      text: state.altitudeMax != null
          ? state.altitudeMax!.round().toString()
          : '',
    );
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  void _onSliderChanged(RangeValues values) {
    setState(() {
      _sliderMin = values.start;
      _sliderMax = values.end;
    });
    _minController.text = values.start == _altMin
        ? ''
        : values.start.round().toString();
    _maxController.text = values.end == _altMax
        ? ''
        : values.end.round().toString();
  }

  void _onSliderChangeEnd(RangeValues values) {
    final min = values.start == _altMin ? null : values.start;
    final max = values.end == _altMax ? null : values.end;
    context.read<MapBloc>().add(MapFilter(minAlt: min, maxAlt: max));
  }

  void _onTextFieldSubmitted() {
    final minText = _minController.text.trim();
    final maxText = _maxController.text.trim();

    final min = minText.isEmpty ? null : double.tryParse(minText);
    final max = maxText.isEmpty ? null : double.tryParse(maxText);

    // Clamp and update slider
    setState(() {
      _sliderMin = (min ?? _altMin).clamp(_altMin, _altMax);
      _sliderMax = (max ?? _altMax).clamp(_altMin, _altMax);
      // Ensure min <= max
      if (_sliderMin > _sliderMax) {
        _sliderMin = _sliderMax;
      }
    });

    context.read<MapBloc>().add(
      MapFilter(
        minAlt: min != null ? _sliderMin : null,
        maxAlt: max != null ? _sliderMax : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocListener<MapBloc, MapState>(
      listenWhen: (prev, curr) =>
          prev.altitudeMin != curr.altitudeMin ||
          prev.altitudeMax != curr.altitudeMax,
      listener: (context, state) {
        // Sync UI when filters are cleared externally
        setState(() {
          _sliderMin = state.altitudeMin ?? _altMin;
          _sliderMax = state.altitudeMax ?? _altMax;
        });
        _minController.text = state.altitudeMin != null
            ? state.altitudeMin!.round().toString()
            : '';
        _maxController.text = state.altitudeMax != null
            ? state.altitudeMax!.round().toString()
            : '';
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Altura', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            _buildSubtitle(),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 12),
          RangeSlider(
            values: RangeValues(_sliderMin, _sliderMax),
            min: _altMin,
            max: _altMax,
            divisions: 100,
            labels: RangeLabels(
              '${_sliderMin.round()} m',
              '${_sliderMax.round()} m',
            ),
            onChanged: _onSliderChanged,
            onChangeEnd: _onSliderChangeEnd,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _minController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Mínimo (m)',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onSubmitted: (_) => _onTextFieldSubmitted(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _maxController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    labelText: 'Máximo (m)',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  onSubmitted: (_) => _onTextFieldSubmitted(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _buildSubtitle() {
    final hasMin = _minController.text.trim().isNotEmpty;
    final hasMax = _maxController.text.trim().isNotEmpty;

    if (hasMin && hasMax) {
      return 'Entre ${_sliderMin.round()} m y ${_sliderMax.round()} m';
    } else if (hasMin) {
      return 'Mayor o igual a ${_sliderMin.round()} m';
    } else if (hasMax) {
      return 'Menor o igual a ${_sliderMax.round()} m';
    }
    return 'Todos (0 – 5000 m)';
  }
}
