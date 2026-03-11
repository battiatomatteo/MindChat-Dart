import 'package:sqflite/sqflite.dart';
import 'database_service.dart';
import 'user_service.dart';

class ChatService {
  // -------------------------------------------------------------
  // OTTIENI I MESSAGGI TRA DUE UTENTI
  // -------------------------------------------------------------
  static Future<List<Map<String, dynamic>>> getMessages(int myId, int otherId) async {
    final db = await DatabaseService.database;

    return await db.query(
      'messages',
      where: '(senderId = ? AND receiverId = ?) OR (senderId = ? AND receiverId = ?)',
      whereArgs: [myId, otherId, otherId, myId],
      orderBy: 'timestamp ASC',
    );
  }

  // -------------------------------------------------------------
  // INVIA MESSAGGIO
  // -------------------------------------------------------------
  static Future<void> sendMessage(int senderId, int receiverId, String text) async {
    final db = await DatabaseService.database;

    await db.insert('messages', {
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'isRead': 0,
    });
  }

  // -------------------------------------------------------------
  // SEGNA COME LETTI
  // -------------------------------------------------------------
  static Future<void> markAsRead(int myId, int otherId) async {
    final db = await DatabaseService.database;

    await db.update(
      'messages',
      {'isRead': 1},
      where: 'receiverId = ? AND senderId = ?',
      whereArgs: [myId, otherId],
    );
  }

  // -------------------------------------------------------------
  // ⭐ CONTROLLA SE È AMICO
  // -------------------------------------------------------------
  static Future<bool> isFriend(int myId, int otherId) async {
    final db = await DatabaseService.database;

    final res = await db.query(
      'friends',
      where: 'myId = ? AND friendId = ?',
      whereArgs: [myId, otherId],
      limit: 1,
    );

    return res.isNotEmpty;
  }

  // -------------------------------------------------------------
  // ⭐ AGGIUNGI AMICO + incrementa chatCount
  // -------------------------------------------------------------
  static Future<void> addFriend(int myId, int otherId) async {
    final db = await DatabaseService.database;

    await db.insert(
      'friends',
      {'myId': myId, 'friendId': otherId},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );

    await UserService.incrementChatCount(myId);
  }

  // -------------------------------------------------------------
  // ⭐ RIMUOVI AMICO + decrementa chatCount
  // -------------------------------------------------------------
  static Future<void> removeFriend(int myId, int otherId) async {
    final db = await DatabaseService.database;

    await db.delete(
      'friends',
      where: 'myId = ? AND friendId = ?',
      whereArgs: [myId, otherId],
    );

    await UserService.decrementChatCount(myId);
  }

  // -------------------------------------------------------------
  // 🔥 OTTIENI LISTA CONVERSAZIONI PER ChatListScreen
  // -------------------------------------------------------------
  static Future<List<Map<String, dynamic>>> getConversations(int myId) async {
    final db = await DatabaseService.database;

    return await db.rawQuery('''
      SELECT 
        u.id AS userId,
        u.username,
        m.text AS lastMessage,
        m.timestamp,
        CASE 
          WHEN m.isRead = 0 AND m.receiverId = ? THEN 1
          ELSE 0
        END AS hasUnread
      FROM users u
      JOIN messages m ON (
        (m.senderId = u.id AND m.receiverId = ?) OR
        (m.receiverId = u.id AND m.senderId = ?)
      )
      WHERE u.id != ?
      GROUP BY u.id
      ORDER BY m.timestamp DESC
    ''', [myId, myId, myId, myId]);
  }
}
