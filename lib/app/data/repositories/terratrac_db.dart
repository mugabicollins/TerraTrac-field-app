import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';


class TerraTracDataBaseHelper {
  ///define database for terra-trac App
  static const _databaseName = "terratrac.db";
  static const databaseVersion = 2;
  static final TerraTracDataBaseHelper dbInstance = TerraTracDataBaseHelper.internal();
  factory TerraTracDataBaseHelper() => dbInstance;
  static Database? database_;
  TerraTracDataBaseHelper.internal();

  Future<Database> get database async {
    if (database_ != null) return database_!;
    database_ = await initDatabase_();
    return database_!;
  }

  initDatabase_() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String dbpath = path.join(documentsDirectory.path, _databaseName);

    bool deletedatabase = false;

    // Open the database with onConfigure callback
    Database database = await openDatabase(
      dbpath,
      version: databaseVersion,
      onConfigure: (Database db) async {
        // Check the current database version
        int currentVersion = await db.getVersion();

        // Compare the current version with the expected version
        if (currentVersion != databaseVersion) {
          deletedatabase = true;
        }
      },
      onCreate: _onCreate,
    );

    // Close the database if it needs to be deleted
    if (deletedatabase) {
      await database.close();
      await deleteDatabase(dbpath);
      // Re-open the database after deletion
      database = await openDatabase(
        dbpath,
        version: databaseVersion,
        onCreate: _onCreate,
      );
    }

    return database;
  }
  static const polygonTable = 'polygon_table';
  static const id = 'id';
  static const polygonData = 'polygon_data';
  static const timestamp = 'timestamp';
  static const userEmail = 'user_email';
  static const phoneNumber = 'phone_number';
  static const deviceId = 'device_id';
  static const isSaved = 'is_saved';


  /// creating table here
  Future _onCreate(Database db, int version) async {
    await db.execute('''
    CREATE TABLE $polygonTable (
      $id INTEGER PRIMARY KEY AUTOINCREMENT,
      $polygonData TEXT NOT NULL,
      $timestamp TEXT NOT NULL,
      $userEmail TEXT NOT NULL,
      $phoneNumber TEXT NOT NULL,
      $deviceId TEXT NOT NULL,
      $isSaved INTEGER NOT NULL DEFAULT 0
    )
  ''');
  }

  Future<void> insertPolygonData(
      {String? polygons, String? email, String? phone, String? deviceID}) async {
    Database db = await dbInstance.database;

    // Get current timestamp
    String currentTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    await db.insert(polygonTable, {
      polygonData: polygons,
      timestamp: currentTime,
      userEmail: email,
      phoneNumber: phone,
      deviceId: deviceID,
      isSaved:0,
    });

    getUnsyncedPolygons();
  }

  // Get Unsynced Polygons (isSaved = 0)
  Future<List<Map<String, dynamic>>> getUnsyncedPolygons() async {
    final db = await database;
    return await db.query(polygonTable, where: 'is_saved = 0');
  }

  // Get Synced Polygons (isSaved = 1)
  Future<List<Map<String, dynamic>>> getSyncedPolygons() async {
    final db = await database;
    return await db.query(polygonTable, where: 'is_saved = 1');
  }

  // Update Polygon isSaved Status
  Future<void> updatePolygonStatus(int id, int isSaved) async {
    final db = await database;
    await db.update(
      polygonTable,
      {'is_saved': isSaved},
      where: 'id = ?',
      whereArgs: [id],
    );
  }


  Future<void> deletePolygonData(int polygonId) async {
    Database db = await dbInstance.database;
    await db.delete(polygonTable, where: '$id = ?', whereArgs: [polygonId]);
  }


  /// checke table exist or not
  Future<bool> doesTableExist(Database db, String tableName) async {
    try {
      List<Map<String, dynamic>> tables = await db.rawQuery(
          "SELECT name FROM sqlite_master WHERE type='table' AND name='$tableName'");
      return tables.isNotEmpty;
    } catch (e) {
      if (kDebugMode) {
        print('e: $e');
      }
      return false;
    }
  }

  /// clear specific table data
  Future<void> clearTableData(Database db, String tableName) async {
    await db.delete(tableName);
  }

  /// fetching specific data
  Future<List<Map<String, dynamic>>> getTableData(
      Database db, String tableName) async {
    List<Map<String, dynamic>> result = await db.query(tableName);
    return result;
  }




  Future<void> deleteTable(Database db, tableName) async {
    await db.execute("DROP TABLE IF EXISTS $tableName");

  }
}
