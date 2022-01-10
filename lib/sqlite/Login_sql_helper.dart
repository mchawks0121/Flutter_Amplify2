import 'package:intl/date_symbol_data_file.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE status(
        id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,
        owner TEXT,
        token TEXT,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
      """);
  }
// id: the id of a item
// title, description: name and description of your activity
// created_at: the time that the item was created. It will be automatically handled by SQLite

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'LoginStatus.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  // Create new item (journal)
  static Future<int> createItem(String owner, String? token) async {
    final db = await SQLHelper.db();

    final data = {'owner': owner, 'token': token};
    final id = await db.insert('status', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return id;
  }

  // Read all items (journals)
  static Future<List<Map<String, dynamic>>> getItems() async {
    final db = await SQLHelper.db();
    return db.query('status', orderBy: "id");
  }

  // Read a single item by id
  // The app doesn't use this method but I put here in case you want to see it
  static Future<List<Map<String, dynamic>>> getItem(int id) async {
    final db = await SQLHelper.db();
    return db.query('status', where: "id = ?", whereArgs: [id], limit: 1);
  }

  // Update an item by id
  static Future<int> updateItem(
      int id, String? owner, String? token) async {
    final db = await SQLHelper.db();
    final data = {
      'owner': owner,
      'token': token,
      'createdAt': DateTime.now().toLocal().toString()
    };

    final result =
    await db.update('status', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  // Delete
  static Future<void> deleteItem(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete("status", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      print("Something went wrong when deleting an item: $err");
    }
  }
  //all delete
  static Future<void> deleteAllItem() async {
    final db = await SQLHelper.db();
    try {
      await db.delete("status");
    } catch (err) {
      print("Something went wrong when deleting an item: $err");
    }
  }
}