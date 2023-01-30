import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../model/note_model.dart';

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance =
      DatabaseHelper._privateConstructor(); //Singleton

  static final _dbName = "notes.db";
  static final _dbVersion = 1;
  static final _tableName = "notes";
  static final columnPin = 'pin';
  static final columnTrash = 'trash';

  static Database? _database;

  Future<Database?> get database async {
    if (_database != null) return _database;
    _database = await _initiateDatabase();
    return _database;
  }

  _initiateDatabase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String path = join(directory.path, _dbName);
    return await openDatabase(path, version: _dbVersion, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) {
    return db.execute('''
      CREATE TABLE $_tableName(
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        dateTimeEdited TEXT NOT NULL,
        dateTimeCreated TEXT NOT NULL
      )
      ''');
  }

  // Add Note
  Future<int> addNote(Note note) async {
    Database? db = await instance.database;
    return await db!.insert(_tableName, note.toMap());
  }

  // Delete Note
  Future<int> deleteNote(Note note) async {
    Database? db = await instance.database;
    return await db!.delete(
      _tableName,
      where: "id = ?",
      whereArgs: [note.id],
    );
  }

  // Delete All Notes
  Future<int> deleteAllNotes() async {
    Database? db = await instance.database;
    return await db!.delete(_tableName);
  }

  Future<int> updateNote(Note note) async {
    Database? db = await instance.database;
    return await db!.update(
      _tableName,
      note.toMap(),
      where: "id = ?",
      whereArgs: [note.id],
    );
  }
  // Future<int> updateNote(Note note) async {
  //   final db = await instance.database;

  //   return await db!.update(_tableName, note.toMap(),
  //       where: "id = ?", whereArgs: [note.id]);
  // }

  Future<List<Note>> getNoteList() async {
    Database? db = await instance.database;
    final List<Map<String, dynamic>> maps = await db!.query(_tableName);

    return List.generate(
      maps.length,
      (index) {
        return Note(
          id: maps[index]["id"],
          title: maps[index]["title"],
          content: maps[index]["content"],
          // pin: maps[index] == 1 ? true : false,
          // trash: maps[index] == 1 ? true : false,
          dateTimeEdited: maps[index]["dateTimeEdited"],
          dateTimeCreated: maps[index]["dateTimeCreated"],
        );
      },
    );
  }

  // Query by Trashed
  Future<List<Note>> queryTrashedNotes() async {
    final db = await instance.database;

    final List<Map<String, dynamic>> maps =
        await db!.query(_tableName, where: '$columnTrash = ?', whereArgs: [1]);

    return List.generate(maps.length, (i) {
      return Note.fromMap(maps[i]);
    });
  }

  Future<List<Note>> queryPinnedNotes() async {
    final db = await instance.database;

    final List<Map<String, dynamic>> maps =
        await db!.query(_tableName, where: '$columnPin = ?', whereArgs: [1]);

    return List.generate(maps.length, (i) {
      return Note.fromMap(maps[i]);
    });
  }
  // Future<int> trashNote(Note note) async {
  //   final db = await instance.database;
  //   return await db!.update(
  //     _tableName,
  //     {'isTrashed': 1},
  //     where: 'id = ?',
  //     whereArgs: [note.id],
  //   );
  // }

  // Future<int> untrashNote(Note note) async {
  //   final db = await instance.database;
  //   return await db!.update(
  //     _tableName,
  //     {'isTrashed': 0},
  //     where: 'id = ?',
  //     whereArgs: [note.id],
  //   );
  // }

//  Future <int> pinNote() async{
//   final db = await instance.database;

//    await db!.update(Note.TableName, {Note.pin : !note!.pin ? 1 : 0}, where:  '${Note.id} = ?' ,whereArgs: [note.id] );
//  }
}
