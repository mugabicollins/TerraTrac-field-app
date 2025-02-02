import 'dart:io';
import 'package:flutter/foundation.dart';
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
  static const newFields = 'newFieldTable';
  ///name the column of productTable(table)
  static const barcode = 'barcode';
  static const name = 'name';
  static const image = 'image';
  static const brand = 'brand';

  /// creating table here
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $newFields (
            $barcode INTEGER PRIMARY KEY,
            $name TEXT NOT NULL,
            $name INTEGER NOT NULL,
            $name TEXT NOT NULL)''');

  }



  /// local product CRUD operations
  // Future<void> insertProduct(LocalProduct model) async {
  //   Database db = await dbInstance.database;
  //   Map<String, dynamic> row = {
  //     barcode: model.barcode.toString(),
  //     name: model.name,
  //     image: model.image,
  //     ingredientImage: model.ingredientImage,
  //     labelImage: model.labelImage,
  //     ingredients: model.ingredients,
  //     labels: model.labels,
  //     type: model.status,
  //     productUpdatedAt: DateTime.now().toString().split(' ').first,
  //   };
  //   try {
  //     Database db = await dbInstance.database;
  //     var result = await doesTableExist(db, productTable);
  //     if (result == false) {
  //       await db.execute('''
  //         CREATE TABLE $productTable (
  //           $barcode TEXT PRIMARY KEY,
  //           $name TEXT ,
  //           $image TEXT ,
  //           $ingredientImage TEXT ,
  //           $labelImage TEXT ,
  //           $ingredients TEXT ,
  //           $labels TEXT ,
  //           $type TEXT ,
  //           $productUpdatedAt TEXT)''');
  //     }
  //     await db.insert(
  //       productTable,
  //       row,
  //     );
  //   } catch (e, s) {
  //     log('Product add failed due to $e $s');
  //     //
  //   }
  // }

  Future<int> deleteProductAt(productBarcode) async {
    Database db = await dbInstance.database;
    return await db.delete(newFields,
        where: '$barcode = ?', whereArgs: [productBarcode]);
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
