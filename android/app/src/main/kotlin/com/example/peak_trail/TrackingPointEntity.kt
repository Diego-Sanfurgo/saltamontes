package app.saltamontes

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "tracking_points")
data class TrackingPointEntity(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    @ColumnInfo(name = "latitude") val latitude: Double,
    @ColumnInfo(name = "longitude") val longitude: Double,
    @ColumnInfo(name = "altitude") val altitude: Double?,
    @ColumnInfo(name = "speed") val speed: Double?,
    @ColumnInfo(name = "bearing") val bearing: Double?,
    @ColumnInfo(name = "accuracy") val accuracy: Double?,
    @ColumnInfo(name = "timestamp") val timestamp: Long // Unix ms
)