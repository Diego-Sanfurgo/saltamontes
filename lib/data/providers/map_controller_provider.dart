import 'package:flutter/foundation.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

/// Solicitud de cambio de viewport con transición animada opcional.
class ViewportRequest {
  final ViewportState viewport;
  final ViewportTransition? transition;

  const ViewportRequest(this.viewport, {this.transition});
}

/// Centraliza la referencia al [MapboxMap] controller activo y los canales
/// de comunicación entre cubits/blocs y el widget del mapa.
///
/// Al llamar a [setController], notifica automáticamente a todos los
/// listeners (cubits/blocs) para que actualicen su referencia interna.
class MapControllerProvider extends ChangeNotifier {
  MapboxMap? _controller;

  /// Controller del mapa activo. Puede ser `null` si el mapa aún no fue
  /// creado o si fue destruido.
  MapboxMap? get controller => _controller;

  /// Actualiza el controller y notifica a todos los listeners.
  void setController(MapboxMap controller) {
    _controller = controller;
    notifyListeners();
  }

  /// Limpia la referencia al controller (e.g. al destruir el widget del mapa).
  void clearController() {
    _controller = null;
    notifyListeners();
  }

  // ─── Viewport Animation Channel ───

  /// Notifier para solicitudes de animación de viewport.
  /// El widget del mapa escucha este notifier y ejecuta
  /// `setStateWithViewportAnimation` cuando recibe un nuevo valor.
  final viewportNotifier = ValueNotifier<ViewportRequest?>(null);

  /// Solicita un cambio de viewport animado al widget del mapa.
  void requestViewport(
    ViewportState viewport, {
    ViewportTransition? transition,
  }) {
    viewportNotifier.value = ViewportRequest(viewport, transition: transition);
  }

  // ─── User Interaction Channel ───

  /// Callback que el widget del mapa invoca al detectar un gesto del usuario
  /// (pointer down). Los cubits interesados (e.g. LocationCubit) registran
  /// su handler aquí.
  VoidCallback? onUserInteraction;

  @override
  void dispose() {
    viewportNotifier.dispose();
    super.dispose();
  }
}
