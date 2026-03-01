import 'package:flutter/material.dart';

class MetricsGridWidget extends StatelessWidget {
  const MetricsGridWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _MetricColumn("Tiempo", "00:00:00", "Restante (aprox)", "00:45:00"),
          _MetricColumn("Velocidad", "5.2 km/h", "Ritmo", "11:30 /km"),
          _MetricColumn("Distancia", "3.45 km", "Desnivel", "120 m"),
        ],
      ),
    );
  }
}

class _MetricColumn extends StatelessWidget {
  const _MetricColumn(this.label1, this.value1, this.label2, this.value2);

  final String label1;
  final String value1;
  final String label2;
  final String value2;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MetricItem(label1, value1, isPrimary: true),
        const SizedBox(height: 16),
        _MetricItem(label2, value2, isPrimary: false),
      ],
    );
  }
}

class _MetricItem extends StatelessWidget {
  const _MetricItem(this.label, this.value, {required this.isPrimary});

  final String label;
  final String value;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: isPrimary ? 18 : 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
