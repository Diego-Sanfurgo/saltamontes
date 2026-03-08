import 'dart:async';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

import 'package:saltamontes/data/models/trace_point.dart';

/// Servicio de rastreo GPS nativo (headless).
///
/// Comunica con el servicio nativo de Android/iOS a través de
/// MethodChannel (comandos) y EventChannel (stream de posiciones).
///
/// **Sin BuildContext ni dependencias de UI.**
@lazySingleton
class NativeTrackingService {
  static const _methodChannel = MethodChannel('app.saltamontes/tracking');
  static const _eventChannel = EventChannel('app.saltamontes/tracking_events');

  /// Stream continuo de posiciones desde el servicio nativo.
  ///
  /// Cada evento es un Map que se mapea a [TracePoint].
  Stream<TracePoint> get positionStream => _eventChannel
      .receiveBroadcastStream()
      .map(
        (event) => TracePoint.fromJson(Map<String, dynamic>.from(event as Map)),
      )
      .handleError((Object error) {
        log('❌ NativeTrackingService stream error: $error');
      });

  /// Iniciar el servicio de rastreo en segundo plano.
  Future<void> startService() async {
    try {
      await _methodChannel.invokeMethod('startService');
      log('✅ NativeTrackingService started');
    } on PlatformException catch (e) {
      log('❌ Error starting native tracking: ${e.message}');
      rethrow;
    }
  }

  /// Detener el servicio de rastreo en segundo plano.
  Future<void> stopService() async {
    try {
      await _methodChannel.invokeMethod('stopService');
      log('✅ NativeTrackingService stopped');
    } on PlatformException catch (e) {
      log('❌ Error stopping native tracking: ${e.message}');
      rethrow;
    }
  }

  /// Solicitar la última posición conocida al servicio nativo.
  Future<TracePoint?> getLastPosition() async {
    try {
      final result = await _methodChannel.invokeMethod<Map>('getLastPosition');
      if (result == null) return null;
      return TracePoint.fromJson(Map<String, dynamic>.from(result));
    } on PlatformException catch (e) {
      log('❌ Error getting last position: ${e.message}');
      return null;
    }
  }
}
