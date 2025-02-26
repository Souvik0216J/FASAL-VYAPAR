import 'dart:async';
import 'package:mongo_dart/mongo_dart.dart' as mongo;
import 'dart:developer' as devtools;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Database service class to handle MongoDB connections
class DatabaseService {
  static mongo.Db? _db;
  static bool _isInitializing = false;
  static DateTime? _lastConnectionTime;
  static const int _connectionTimeoutMinutes = 30;
  
  /// Get an active database connection
  static Future<mongo.Db> getDatabase() async {
    // Check if we have an active connection
    if (_db != null && _db!.isConnected) {
      // Check if connection is too old and should be refreshed
      if (_lastConnectionTime != null && 
          DateTime.now().difference(_lastConnectionTime!).inMinutes < _connectionTimeoutMinutes) {
        return _db!;
      } else {
        devtools.log("Refreshing old MongoDB connection");
        try {
          await _db!.close();
        } catch (e) {
          devtools.log("Error closing old connection: $e");
        }
      }
    }
    
    // Prevent multiple simultaneous initialization attempts
    if (_isInitializing) {
      // Wait for initialization to complete
      int attempts = 0;
      while (_isInitializing && attempts < 10) {
        await Future.delayed(const Duration(milliseconds: 500));
        attempts++;
      }
      
      if (_db != null && _db!.isConnected) {
        return _db!;
      } else {
        throw Exception("Database initialization timed out");
      }
    }
    
    try {
      _isInitializing = true;
      
      // Use direct connection string or from env variables if available
      String connectionString;
      try {
        await dotenv.load(fileName: ".env");
        connectionString = dotenv.env['MONGODB_URI']!;
        if (connectionString.isEmpty) {
          throw Exception("MONGODB_URI is empty in .env file");
        }
      } catch (e) {
        devtools.log("Error loading MongoDB URI: $e");
        throw Exception("Failed to load MongoDB configuration. Please check your .env file");
      }
      
      _db = mongo.Db(connectionString);
      try {
        await _db!.open().timeout(const Duration(seconds: 10));
        _lastConnectionTime = DateTime.now();
      } on TimeoutException catch (e) {
        devtools.log("Database connection timed out: $e");
        await _db!.close();
        _db = null;
        throw Exception("Database connection timed out. Please check your internet connection");
      } catch (e) {
        devtools.log("Error opening database connection: $e");
        await _db!.close();
        _db = null;
        throw Exception("Failed to connect to database: $e");
      }
      
      devtools.log("Connected to MongoDB");
      return _db!;
    } catch (e) {
      devtools.log("Error initializing database: $e");
      throw Exception("Failed to connect to database: $e");
    } finally {
      _isInitializing = false;
    }
  }

  /// Close the database connection
  static Future<void> close() async {
    try {
      if (_db != null && _db!.isConnected) {
        await _db!.close();
        devtools.log("Closed MongoDB connection");
      }
    } catch (e) {
      devtools.log("Error closing database connection: $e");
    } finally {
      _db = null;
      _lastConnectionTime = null;
    }
  }
  
  /// Check connection status
  static bool isConnected() {
    return _db != null && _db!.isConnected;
  }
  
  /// Get a collection from the database
  static Future<mongo.DbCollection> getCollection(String collectionName) async {
    try {
      final db = await getDatabase();
      if (!db.isConnected) {
        throw Exception("Database is not connected");
      }
      return db.collection(collectionName);
    } catch (e) {
      devtools.log("Error getting collection $collectionName: $e");
      rethrow;
    }
  }
  
  /// Ping the database to check connectivity
  // static Future<bool> ping() async {
  //   try {
  //     final db = await getDatabase();
  //     // Using the admin database for ping operation
  //     final adminDb = db.db('admin');
  //     final result = await adminDb.runCommand({'ping': 1});
  //     return result['ok'] == 1.0;
  //   } catch (e) {
  //     devtools.log("Error pinging database: $e");
  //     return false;
  //   }
  // }
  static Future<bool> ping() async {
  try {
    final db = await getDatabase();
    final result = await db.runCommand({'ping': 1}); // No need to switch to 'admin' DB
    return result['ok'] == 1.0;
  } catch (e) {
    devtools.log("Error pinging database: $e");
    return false;
  }
}

  
  /// Alternative ping method that doesn't rely on command
  static Future<bool> isAlive() async {
    try {
      final db = await getDatabase();
      // Simply try to access a collection - this will fail if connection is dead
      await db.getCollectionNames();
      return true;
    } catch (e) {
      devtools.log("Connection check failed: $e");
      return false;
    }
  }
  
  /// Reset the connection (force reconnect on next use)
  static Future<void> resetConnection() async {
    await close();
  }
}
