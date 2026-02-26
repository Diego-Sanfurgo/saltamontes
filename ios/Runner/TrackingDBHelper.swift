import Foundation
import SQLite3

class TrackingDBHelper {
    static let shared = TrackingDBHelper()
    var db: OpaquePointer?
    
    private init() {
        if let docDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let dbPath = docDir.appendingPathComponent("tracking.db").path
            
            if sqlite3_open(dbPath, &db) == SQLITE_OK {
                print("Swift: Base de datos abierta en \(dbPath)")
                enableWAL()
                createTableIfNotExists()
                migrateIfNeeded()
            } else {
                print("Swift: Error abriendo la DB")
            }
        }
    }
    
    private func enableWAL() {
        var error: UnsafeMutablePointer<Int8>?
        if sqlite3_exec(db, "PRAGMA journal_mode=WAL;", nil, nil, &error) != SQLITE_OK {
            print("Swift: Error habilitando WAL")
        }
    }
    
    private func createTableIfNotExists() {
        let createTableString = """
        CREATE TABLE IF NOT EXISTS tracking_points(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            altitude REAL,
            speed REAL,
            bearing REAL,
            accuracy REAL,
            timestamp INTEGER NOT NULL
        );
        """
        
        var createTableStatement: OpaquePointer?
        if sqlite3_prepare_v2(db, createTableString, -1, &createTableStatement, nil) == SQLITE_OK {
            if sqlite3_step(createTableStatement) == SQLITE_DONE {
                // Tabla creada o verificada
            } else {
                print("Swift: No se pudo crear la tabla.")
            }
        }
        sqlite3_finalize(createTableStatement)
    }
    
    /// Migración: agrega columna bearing si no existe
    private func migrateIfNeeded() {
        // Verificar si la columna bearing ya existe
        var stmt: OpaquePointer?
        let query = "PRAGMA table_info(tracking_points);"
        var hasBearing = false
        
        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            while sqlite3_step(stmt) == SQLITE_ROW {
                if let columnName = sqlite3_column_text(stmt, 1) {
                    let name = String(cString: columnName)
                    if name == "bearing" {
                        hasBearing = true
                        break
                    }
                }
            }
        }
        sqlite3_finalize(stmt)
        
        if !hasBearing {
            var error: UnsafeMutablePointer<Int8>?
            if sqlite3_exec(db, "ALTER TABLE tracking_points ADD COLUMN bearing REAL;", nil, nil, &error) == SQLITE_OK {
                print("Swift: Columna bearing agregada exitosamente")
            } else {
                print("Swift: Error agregando columna bearing")
            }
        }
    }
    
    func insertPoint(lat: Double, lng: Double, alt: Double?, speed: Double?, bearing: Double?, acc: Double?, timestamp: Int64) {
        let insertStatementString = "INSERT INTO tracking_points (latitude, longitude, altitude, speed, bearing, accuracy, timestamp) VALUES (?, ?, ?, ?, ?, ?, ?);"
        
        var insertStatement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, insertStatementString, -1, &insertStatement, nil) == SQLITE_OK {
            sqlite3_bind_double(insertStatement, 1, lat)
            sqlite3_bind_double(insertStatement, 2, lng)
            
            if let alt = alt { sqlite3_bind_double(insertStatement, 3, alt) } 
            else { sqlite3_bind_null(insertStatement, 3) }
            
            if let spd = speed { sqlite3_bind_double(insertStatement, 4, spd) }
            else { sqlite3_bind_null(insertStatement, 4) }
            
            if let brg = bearing { sqlite3_bind_double(insertStatement, 5, brg) }
            else { sqlite3_bind_null(insertStatement, 5) }
            
            if let acc = acc { sqlite3_bind_double(insertStatement, 6, acc) }
            else { sqlite3_bind_null(insertStatement, 6) }
            
            sqlite3_bind_int64(insertStatement, 7, timestamp)
            
            if sqlite3_step(insertStatement) == SQLITE_DONE {
                print("Swift: Punto insertado correctamente.")
            } else {
                print("Swift: Error al insertar punto.")
            }
        }
        sqlite3_finalize(insertStatement)
    }
    
    deinit {
        sqlite3_close(db)
    }
}