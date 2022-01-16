import 'package:intl/date_symbol_data_file.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper {
  static Future<void> createmeetingidTables(sql.Database database) async {
    await database.execute("""CREATE TABLE meeting(
        id INTEGER PRIMARY KEY NOT NULL,
        meetingid TEXT,
        pass TEXT,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
      """);
  }
// id: the id of a item
// title, description: name and description of your activity
// created_at: the time that the item was created. It will be automatically handled by SQLite

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'Meeting.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createmeetingidTables(database);
      },
    );
  }

  // Create new item (journal)
  static Future<int> createmeetingid(int id, String meetingid, String pass) async {
    final db = await SQLHelper.db();

    final data = {'id': id, 'meetingid': meetingid, 'pass': pass};
    final reid = await db.insert('meeting', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return reid;
  }

  // Read all items (journals)
  static Future<List<Map<String, dynamic>>> getmeetingid() async {
    final db = await SQLHelper.db();
    return db.query('meeting', orderBy: "id");
  }

  // Read a single item by id
  // The app doesn't use this method but I put here in case you want to see it
  static Future<List<Map<String, dynamic>>> getItem(int id) async {
    final db = await SQLHelper.db();
    return db.query('meeting', where: "id = ?", whereArgs: [id], limit: 1);
  }

  // Update an item by id
  static Future<int> updatemeetingid(
      int id, String meetingid, String pass) async {
    final db = await SQLHelper.db();
    final data = {
      'meetingid': meetingid,
      'pass': pass,
      'createdAt': DateTime.now().toLocal().toString()
    };

    final result =
    await db.update('meeting', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  // Delete
  static Future<void> deletemeetingid(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete("meeting", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      print("Something went wrong when deleting an item: $err");
    }
  }
  //all delete
  static Future<void> deleteAllmeetingid() async {
    final db = await SQLHelper.db();
    try {
      await db.delete("meeting");
      print('deleteAllItems');
    } catch (err) {
      print("Something went wrong when deleting an item: $err");
    }
  }
}