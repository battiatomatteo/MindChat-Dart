import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_social_notes.db');

    return await openDatabase(
      path,
      version: 7, // VERSIONE AGGIORNATA
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  // -------------------------------------------------------------
  //  CREATE DATABASE (tutte le tabelle)
  // -------------------------------------------------------------
  static Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        bio TEXT,
        noteCount INTEGER DEFAULT 0,
        chatCount INTEGER DEFAULT 0
      );
    ''');

    await db.execute('''
      CREATE TABLE messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        senderId INTEGER NOT NULL,
        receiverId INTEGER NOT NULL,
        text TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        isRead INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (senderId) REFERENCES users(id),
        FOREIGN KEY (receiverId) REFERENCES users(id)
      );
    ''');

    await db.execute('''
      CREATE TABLE notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ownerId INTEGER NOT NULL,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        isPublic INTEGER NOT NULL,
        timestamp INTEGER NOT NULL,
        FOREIGN KEY (ownerId) REFERENCES users(id)
      );
    ''');

    await db.execute('''
      CREATE TABLE comments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        noteId INTEGER NOT NULL,
        userId INTEGER NOT NULL,
        text TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        FOREIGN KEY (noteId) REFERENCES notes(id),
        FOREIGN KEY (userId) REFERENCES users(id)
      );
    ''');

    await db.execute('''
      CREATE TABLE devices (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        deviceId TEXT NOT NULL,
        isLogged INTEGER NOT NULL,
        lastLogin INTEGER NOT NULL,
        FOREIGN KEY (userId) REFERENCES users(id)
      );
    ''');

    await db.execute('''
      CREATE TABLE conversations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        myId INTEGER NOT NULL,
        userId INTEGER NOT NULL,
        lastMessage TEXT,
        timestamp INTEGER,
        hasUnread INTEGER DEFAULT 0,
        UNIQUE(myId, userId),
        FOREIGN KEY (myId) REFERENCES users(id),
        FOREIGN KEY (userId) REFERENCES users(id)
      );
    ''');

    await db.execute('''
      CREATE TABLE friends (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        myId INTEGER NOT NULL,
        friendId INTEGER NOT NULL,
        UNIQUE(myId, friendId)
      );
    ''');
  }

  // -------------------------------------------------------------
  //  UPGRADE DATABASE (quando aumenti version)
  // -------------------------------------------------------------
  static Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE devices (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userId INTEGER NOT NULL,
          deviceId TEXT NOT NULL,
          isLogged INTEGER NOT NULL,
          lastLogin INTEGER NOT NULL,
          FOREIGN KEY (userId) REFERENCES users(id)
        );
      ''');
    }

    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE conversations (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          myId INTEGER NOT NULL,
          userId INTEGER NOT NULL,
          lastMessage TEXT,
          timestamp INTEGER,
          hasUnread INTEGER DEFAULT 0,
          FOREIGN KEY (myId) REFERENCES users(id),
          FOREIGN KEY (userId) REFERENCES users(id)
        );
      ''');
    }

    if (oldVersion < 6) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS friends (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          myId INTEGER NOT NULL,
          friendId INTEGER NOT NULL,
          UNIQUE(myId, friendId)
        );
      ''');
    }

    // ⭐ AGGIUNTA COLONNA isRead
    if (oldVersion < 7) {
      await db.execute('ALTER TABLE messages ADD COLUMN isRead INTEGER NOT NULL DEFAULT 0;');
    }
  }
}
