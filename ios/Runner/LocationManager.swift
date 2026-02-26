import Foundation
import CoreLocation

class NativeLocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = NativeLocationManager()
    private let locationManager = CLLocationManager()
    private var isTracking = false
    
    override private init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // O kCLLocationAccuracyNearestTenMeters para ahorrar batería
        locationManager.distanceFilter = 5 // Metros mínimos para update
        
        // Configuraciones CLAVE para Background
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false // IMPORTANTE para senderismo: evita que iOS mate el GPS si paras a descansar
        locationManager.showsBackgroundLocationIndicator = true // Pill azul en la barra de estado
    }
    
    func startTracking() {
        if !isTracking {
            // Asegurarse de tener permisos antes
            locationManager.startUpdatingLocation()
            // startMonitoringSignificantLocationChanges() // Opcional: Ahorra batería pero es menos preciso
            isTracking = true
            print("iOS: Tracking iniciado")
        }
    }
    
    func stopTracking() {
        if isTracking {
            locationManager.stopUpdatingLocation()
            isTracking = false
            print("iOS: Tracking detenido")
        }
    }
    
    // Delegate Method: Aquí llega la ubicación
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        // Insertar usando el Helper que creamos antes
        let timestamp = Int64(location.timestamp.timeIntervalSince1970 * 1000)
        
        TrackingDBHelper.shared.insertPoint(
            lat: location.coordinate.latitude,
            lng: location.coordinate.longitude,
            alt: location.altitude,
            speed: location.speed >= 0 ? location.speed : nil,
            bearing: location.course >= 0 ? location.course : nil,
            acc: location.horizontalAccuracy,
            timestamp: timestamp
        )
    }
}