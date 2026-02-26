package app.saltamontes

import app.saltamontes.TrackingPointEntity

import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Intent
import android.os.Build
import android.os.IBinder
import android.os.Looper
import androidx.core.app.NotificationCompat
import com.google.android.gms.location.*
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

class LocationService : Service() {

    private lateinit var fusedLocationClient: FusedLocationProviderClient
    private lateinit var locationCallback: LocationCallback

    companion object {
        const val CHANNEL_ID = "hiking_tracking_channel"
        const val ACTION_START = "ACTION_START"
        const val ACTION_STOP = "ACTION_STOP"
    }

    override fun onCreate() {
        super.onCreate()
        fusedLocationClient = LocationServices.getFusedLocationProviderClient(this)

        // Definimos qué hacer cuando llega una ubicación
        locationCallback = object : LocationCallback() {
            override fun onLocationResult(locationResult: LocationResult) {
                locationResult.locations.forEach { location ->
                    // Insertar en BD en un hilo secundario (IO)
                    CoroutineScope(Dispatchers.IO).launch {
                        val db = TrackingDatabase.getDatabase(applicationContext)
                        val point = TrackingPointEntity(
                            latitude = location.latitude,
                            longitude = location.longitude,
                            altitude = location.altitude,
                            speed = if (location.hasSpeed()) location.speed.toDouble() else null,
                            bearing = if (location.hasBearing()) location.bearing.toDouble() else null,
                            accuracy = if (location.hasAccuracy()) location.accuracy.toDouble() else null,
                            timestamp = location.time
                        )
                        db.trackingDao().insertPoint(point)
                        println("Android Service: Punto guardado: ${location.latitude}, ${location.longitude}")
                    }
                }
            }
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        when (intent?.action) {
            ACTION_START -> startTracking()
            ACTION_STOP -> stopTracking()
        }
        return START_STICKY
    }

    private fun startTracking() {
        createNotificationChannel()
        
        // La notificación es obligatoria para el Foreground Service
        val notificationIntent = Intent(this, MainActivity::class.java)
        val pendingIntent = PendingIntent.getActivity(this, 0, notificationIntent, PendingIntent.FLAG_IMMUTABLE)

        val notification = NotificationCompat.Builder(this, CHANNEL_ID)
            .setContentTitle("Senderismo App")
            .setContentText("Grabando ruta en segundo plano...")
            .setSmallIcon(android.R.drawable.ic_menu_mylocation) // Cambia por tu icono
            .setContentIntent(pendingIntent)
            .build()

        startForeground(1, notification)

        // Configuración de GPS para Senderismo (Alta precisión, update cada 5s o 10m)
        val locationRequest = LocationRequest.Builder(Priority.PRIORITY_HIGH_ACCURACY, 5000)
            .setMinUpdateDistanceMeters(5f) // No guardar si se mueve menos de 5 metros
            .setWaitForAccurateLocation(false)
            .build()

        try {
            fusedLocationClient.requestLocationUpdates(
                locationRequest,
                locationCallback,
                Looper.getMainLooper()
            )
            println("Android Service: Tracking iniciado")
        } catch (e: SecurityException) {
            println("Android Service: Error de permisos: ${e.message}")
        }
    }

    private fun stopTracking() {
        fusedLocationClient.removeLocationUpdates(locationCallback)
        stopForeground(STOP_FOREGROUND_REMOVE)
        stopSelf()
        println("Android Service: Tracking detenido")
    }

    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val serviceChannel = NotificationChannel(
                CHANNEL_ID,
                "Hiking Tracking Channel",
                NotificationManager.IMPORTANCE_LOW
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(serviceChannel)
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null
}