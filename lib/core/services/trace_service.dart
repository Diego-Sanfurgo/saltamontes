// trace_service.dart
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:saltamontes/data/models/trace_point.dart';
import 'package:saltamontes/data/providers/tracking_database.dart';

class TraceService {
  // Correct channel name from MainActivity.kt
  static const _platform = MethodChannel('app.saltamontes/location');

  final TrackingDatabase _db;

  TraceService({TrackingDatabase? db}) : _db = db ?? TrackingDatabase();

  /// Stream to listen for real-time location updates from the local database
  Stream<List<TracePoint>> get onLocationUpdates {
    return _db.watchAllPoints().map((points) {
      return points.map((p) => _mapToTracePoint(p)).toList();
    });
  }

  /// Single location stream (backward compatibility if needed, though list stream is better)
  /// Using the latest point from the DB
  Stream<TracePoint> get onLocation {
    return _db
        .watchAllPoints()
        .map((points) {
          if (points.isEmpty) {
            throw Exception("No points available");
          }
          return _mapToTracePoint(points.last);
        })
        .where((event) => true); // Ensure strictly stream behavior
  }

  Future<void> startTracking() async {
    try {
      await _platform.invokeMethod('startTracking');
    } on PlatformException catch (e) {
      print("Error starting tracking: ${e.message}");
      rethrow;
    }
  }

  Future<void> stopTracking() async {
    try {
      await _platform.invokeMethod('stopTracking');
    } on PlatformException catch (e) {
      print("Error stopping tracking: ${e.message}");
      rethrow;
    }
  }

  Future<List<TracePoint>> getAllTraces() async {
    final points = await _db.getAllPoints();
    return points.map((p) => _mapToTracePoint(p)).toList();
  }

  Future<void> forceUpload() async {
    // Implement force upload logic if applicable or keep as placeholder
    // await _platform.invokeMethod('forceUpload');
    print("Force upload not implemented yet in native layer");
  }

  TracePoint _mapToTracePoint(TrackingPoint p) {
    return TracePoint(
      lat: p.latitude,
      lon: p.longitude,
      altitude: p.altitude,
      speed: p.speed,
      bearing: p.bearing,
      accuracy: p.accuracy,
      timestamp: p.timestamp,
    );
  }
} // End of TraceService
