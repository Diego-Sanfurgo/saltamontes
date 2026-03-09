import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:saltamontes/core/services/navigation_service.dart';

class CreateExcursionSheet extends StatefulWidget {
  final void Function({
    required String title,
    String? description,
    required DateTime scheduledStart,
    required bool isPublic,
    String? plannedTrackId,
  })
  onSubmit;

  const CreateExcursionSheet({super.key, required this.onSubmit});

  @override
  State<CreateExcursionSheet> createState() => _CreateExcursionSheetState();
}

class _CreateExcursionSheetState extends State<CreateExcursionSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _scheduledStart = DateTime.now().add(const Duration(days: 1));
  bool _isPublic = false;
  String? _plannedTrackId;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _scheduledStart,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_scheduledStart),
      );
      setState(() {
        _scheduledStart = DateTime(
          date.year,
          date.month,
          date.day,
          time?.hour ?? 8,
          time?.minute ?? 0,
        );
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSubmit(
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      scheduledStart: _scheduledStart,
      isPublic: _isPublic,
      plannedTrackId: _plannedTrackId,
    );
    NavigationService.pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Nueva Excursión',
                style: textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // Título
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Título',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.edit),
                ),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Ingresá un título' : null,
              ),
              const SizedBox(height: 16),

              // Descripción
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Descripción (opcional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Fecha
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: colorScheme.outline),
                ),
                leading: const Icon(Icons.calendar_today),
                title: const Text('Fecha y hora'),
                subtitle: Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(_scheduledStart),
                ),
                onTap: _pickDate,
              ),
              const SizedBox(height: 16),

              // Visibilidad
              SwitchListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: colorScheme.outline),
                ),
                title: const Text('Excursión pública'),
                subtitle: Text(
                  _isPublic
                      ? 'Visible para todos'
                      : 'Solo visible para participantes',
                ),
                value: _isPublic,
                onChanged: (v) => setState(() => _isPublic = v),
              ),
              const SizedBox(height: 16),

              // Track selector (placeholder — se llenará con tracks del usuario)
              ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: colorScheme.outline),
                ),
                leading: const Icon(Icons.route),
                title: const Text('Asociar track existente'),
                subtitle: Text(
                  _plannedTrackId != null
                      ? 'Track: ${_plannedTrackId!.substring(0, 8)}...'
                      : 'Seguir la ruta de otro usuario (opcional)',
                ),
                trailing: _plannedTrackId != null
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _plannedTrackId = null),
                      )
                    : const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: Abrir selector de tracks públicos
                },
              ),
              const SizedBox(height: 24),

              // Submit
              FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.hiking),
                label: const Text('Crear Excursión'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
