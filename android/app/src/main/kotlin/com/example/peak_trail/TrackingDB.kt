package app.saltamontes

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import androidx.room.migration.Migration
import androidx.sqlite.db.SupportSQLiteDatabase
import java.io.File

val MIGRATION_1_2 = object : Migration(1, 2) {
    override fun migrate(db: SupportSQLiteDatabase) {
        db.execSQL("ALTER TABLE tracking_points ADD COLUMN bearing REAL")
    }
}

@Database(entities = [TrackingPointEntity::class], version = 2, exportSchema = false)
abstract class TrackingDatabase : RoomDatabase() {
    abstract fun trackingDao(): TrackingDao

    companion object {
        @Volatile
        private var INSTANCE: TrackingDatabase? = null

        fun getDatabase(context: Context): TrackingDatabase {
            return INSTANCE ?: synchronized(this) {
                val flutterDir = File(context.filesDir.parent, "app_flutter")
                if (!flutterDir.exists()) flutterDir.mkdirs()
                val dbFile = File(flutterDir, "tracking.db")

                val instance = Room.databaseBuilder(
                    context.applicationContext,
                    TrackingDatabase::class.java,
                    dbFile.absolutePath
                )
                .addMigrations(MIGRATION_1_2)
                .enableMultiInstanceInvalidation()
                .addCallback(object : RoomDatabase.Callback() {
                    override fun onOpen(db: SupportSQLiteDatabase) {
                        super.onOpen(db)
                        db.query("PRAGMA journal_mode=WAL;").close()
                    }
                })
                .build()
                INSTANCE = instance
                instance
            }
        }
    }
}