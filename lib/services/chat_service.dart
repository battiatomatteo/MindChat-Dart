import 'package:sqflite/sqflite.dart';
import 'database_service.dart';

class ChatService {

  // -------------------------------------------------------------
  //  GET MESSAGES
  // -------------------------------------------------------------
  static Future<List<Map<String, dynamic>>> getMessages(int myId, int otherId) async {
    final db = await DatabaseService.database;

    return await db.rawQuery('''
      SELECT * FROM messages
      WHERE (senderId = ? AND receiverId = ?)
         OR (senderId = ? AND receiverId = ?)
      ORDER BY timestamp ASC;
    ''', [myId, otherId, otherId, myId]);
  }

  // -------------------------------------------------------------
  //  SEND MESSAGE  (setta hasUnread = 1 per l'altro utente)
  // -------------------------------------------------------------
  static Future<void> sendMessage(int senderId, int receiverId, String text) async {
    final db = await DatabaseService.database;

    final timestamp = DateTime.now().millisecondsSinceEpoch;

    // Inserisci messaggio
    await db.insert('messages', {
      'senderId': senderId,
      'receiverId': receiverId,
      'text': text,
      'timestamp': timestamp,
    });

    // 🔥 CREA CONVERSAZIONE SE NON ESISTE (per il mittente)
    await db.rawInsert('''
      INSERT OR IGNORE INTO conversations (myId, userId, lastMessage, timestamp, hasUnread)
      VALUES (?, ?, ?, ?, 0)
    ''', [senderId, receiverId, text, timestamp]);

    // 🔥 CREA CONVERSAZIONE SE NON ESISTE (per il ricevente)
    await db.rawInsert('''
      INSERT OR IGNORE INTO conversations (myId, userId, lastMessage, timestamp, hasUnread)
      VALUES (?, ?, ?, ?, 1)
    ''', [receiverId, senderId, text, timestamp]);

    // 🔥 Aggiorna conversazione del mittente
    await db.rawUpdate('''
      UPDATE conversations
      SET lastMessage = ?, timestamp = ?, hasUnread = 0
      WHERE myId = ? AND userId = ?
    ''', [text, timestamp, senderId, receiverId]);

    // 🔥 Aggiorna conversazione del ricevente
    await db.rawUpdate('''
      UPDATE conversations
      SET lastMessage = ?, timestamp = ?, hasUnread = 1
      WHERE myId = ? AND userId = ?
    ''', [text, timestamp, receiverId, senderId]);
  }


  // -------------------------------------------------------------
  //  GET CONVERSATIONS (include hasUnread)
  // -------------------------------------------------------------
  static Future<List<Map<String, dynamic>>> getConversations(int myId) async {
    final db = await DatabaseService.database;

    final result = await db.rawQuery('''
      SELECT 
        c.userId,
        u.username,
        c.lastMessage,
        c.timestamp,
        c.hasUnread
      FROM conversations c
      JOIN users u ON u.id = c.userId
      WHERE c.myId = ?
      ORDER BY c.timestamp DESC;
    ''', [myId]);

    return result;
  }

  // -------------------------------------------------------------
  //  MARK AS READ (reset hasUnread = 0)
  // -------------------------------------------------------------
  static Future<void> markAsRead(int myId, int otherId) async {
    final db = await DatabaseService.database;

    await db.rawUpdate('''
      UPDATE conversations
      SET hasUnread = 0
      WHERE userId = ? AND myId = ?
    ''', [otherId, myId]);
  }
}
