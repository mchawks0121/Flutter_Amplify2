import 'package:intl/date_symbol_data_file.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper {
  static Future<void> createlockstatusTables(sql.Database database) async {
    await database.execute("""CREATE TABLE secure(
        id INTEGER PRIMARY KEY NOT NULL,
        owner TEXT,
        pass TEXT,
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
      'LoginSecure.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createlockstatusTables(database);
      },
    );
  }

  // Create new item (journal)
  static Future<int> createlockstatus(int id, String owner, String pass, String? token) async {
    final db = await SQLHelper.db();

    final data = {'id': id, 'owner': owner, 'pass': pass, 'token': token};
    final reid = await db.insert('secure', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return reid;
  }

  // Read all items (journals)
  static Future<List<Map<String, dynamic>>> getlockstatus() async {
    final db = await SQLHelper.db();
    return db.query('secure', orderBy: "id");
  }

  // Read a single item by id
  // The app doesn't use this method but I put here in case you want to see it
  static Future<List<Map<String, dynamic>>> getItem(int id) async {
    final db = await SQLHelper.db();
    return db.query('secure', where: "id = ?", whereArgs: [id], limit: 1);
  }

  // Update an item by id
  static Future<int> updatelockstatus(
      int id, String owner, String pass, String? token) async {
    final db = await SQLHelper.db();
    final data = {
      'owner': owner,
      'pass': pass,
      'token': token,
      'createdAt': DateTime.now().toLocal().toString()
    };

    final result =
    await db.update('secure', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  // Delete
  static Future<void> deletelockstatus(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete("secure", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      print("Something went wrong when deleting an item: $err");
    }
  }
  //all delete
  static Future<void> deleteAlllockstatus() async {
    final db = await SQLHelper.db();
    try {
      await db.delete("secure");
      print('deleteAllItems');
    } catch (err) {
      print("Something went wrong when deleting an item: $err");
    }
  }
}