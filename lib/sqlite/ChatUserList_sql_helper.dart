import 'package:intl/date_symbol_data_file.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper {
  static Future<void> createTables(sql.Database database) async {
    await database.execute("""CREATE TABLE ChatUserList(
        id INTEGER PRIMARY KEY NOT NULL,
        toChat TEXT,
        read TEXT,
        createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
      )
      """);
  }
// id: the id of a item
// title, description: name and description of your activity
// created_at: the time that the item was created. It will be automatically handled by SQLite

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'ChatUserList.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await createTables(database);
      },
    );
  }

  // Create new item (journal)
  static Future<int> createChatUserList(int id, String toChat, String? read) async {
    final db = await SQLHelper.db();

    final data = {'id': id, 'toChat': toChat, 'read': read};
    final reid = await db.insert('ChatUserList', data,
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
    return reid;
  }

  // Read all items (journals)
  static Future<List<Map<String, dynamic>>> getChatUserLists() async {
    final db = await SQLHelper.db();
    return db.query('ChatUserList', orderBy: "id");
  }

  // Read a single item by id
  // The app doesn't use this method but I put here in case you want to see it
  static Future<List<Map<String, dynamic>>> getChatUserList(int id) async {
    final db = await SQLHelper.db();
    return db.query('ChatUserList', where: "id = ?", whereArgs: [id], limit: 1);
  }

  // Update an item by id
  static Future<int> updateChatUserList(
      int id, String? toChat, String? read) async {
    final db = await SQLHelper.db();
    final data = {
      'toChat': toChat,
      'read': read,
      'createdAt': DateTime.now().toLocal().toString()
    };

    final result =
    await db.update('ChatUserList', data, where: "id = ?", whereArgs: [id]);
    return result;
  }

  // Delete
  static Future<void> deleteChatUserList(int id) async {
    final db = await SQLHelper.db();
    try {
      await db.delete("ChatUserList", where: "id = ?", whereArgs: [id]);
    } catch (err) {
      print("Something went wrong when deleting an item: $err");
    }
  }
  //all delete
  static Future<void> deleteAllItems() async {
    final db = await SQLHelper.db();
    try {
      await db.delete("ChatUserList");
      print('deleteAllItems');
    } catch (err) {
      print("Something went wrong when deleting an item: $err");
    }
  }
}