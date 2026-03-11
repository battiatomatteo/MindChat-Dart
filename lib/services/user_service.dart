import 'database_service.dart';

class UserService {
  // -------------------------------------------------------------
  // REGISTRAZIONE
  // -------------------------------------------------------------
  static Future<int> registerUser(String username, String email, String password) async {
    final db = await DatabaseService.database;

    // Controllo se email esiste già
    final existing = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (existing.isNotEmpty) {
      return -1; // email già registrata
    }

    return await db.insert('users', {
      'username': username,
      'email': email,
      'password': password,
      'bio': "",
      'noteCount': 0,
      'chatCount': 0,
    });
  }

  // -------------------------------------------------------------
  // LOGIN
  // -------------------------------------------------------------
  static Future<Map<String, dynamic>?> login(String email, String password) async {
    final db = await DatabaseService.database;

    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (result.isEmpty) return null;
    return result.first;
  }

  // -------------------------------------------------------------
  // CERCA UTENTI
  // -------------------------------------------------------------
  static Future<List<Map<String, dynamic>>> searchUsers(String query, int myId) async {
    final db = await DatabaseService.database;

    return await db.query(
      'users',
      where: 'username LIKE ? AND id != ?',
      whereArgs: ['%$query%', myId],
    );
  }

  // -------------------------------------------------------------
  // RECUPERA DATI UTENTE COMPLETI
  // -------------------------------------------------------------
  static Future<Map<String, dynamic>?> getUserById(int id) async {
    final db = await DatabaseService.database;
    final res = await db.query("users", where: "id = ?", whereArgs: [id]);
    return res.isNotEmpty ? res.first : null;
  }

  // -------------------------------------------------------------
  // AGGIORNA BIO
  // -------------------------------------------------------------
  static Future<void> updateBio(int userId, String bio) async {
    final db = await DatabaseService.database;
    await db.update(
      "users",
      {"bio": bio},
      where: "id = ?",
      whereArgs: [userId],
    );
  }

  // -------------------------------------------------------------
  // INCREMENTA NOTE CREATE
  // -------------------------------------------------------------
  static Future<void> incrementNoteCount(int userId) async {
    final db = await DatabaseService.database;
    await db.rawUpdate(
      "UPDATE users SET noteCount = noteCount + 1 WHERE id = ?",
      [userId],
    );
  }

  // -------------------------------------------------------------
  // LOGOUT
  // -------------------------------------------------------------
  static Future<void> logout(int userId) async {
    final db = await DatabaseService.database;
    await db.update(
      "devices",
      {"isLogged": 0},
      where: "userId = ?",
      whereArgs: [userId],
    );
  }

  // -------------------------------------------------------------
  // UPDATEMAIL
  // -------------------------------------------------------------
  static Future<bool> updateEmail(int userId, String newEmail) async {
    final db = await DatabaseService.database;

    // Controllo se email esiste già
    final existing = await db.query(
      'users',
      where: 'email = ? AND id != ?',
      whereArgs: [newEmail, userId],
    );

    if (existing.isNotEmpty) {
      return false; // email già in uso
    }

    await db.update(
      'users',
      {'email': newEmail},
      where: 'id = ?',
      whereArgs: [userId],
    );

    return true;
  }

  // -------------------------------------------------------------
  // UPDATEPASSWORD
  // -------------------------------------------------------------
  static Future<bool> updatePassword(int userId, String oldPassword, String newPassword) async {
    final db = await DatabaseService.database;

    // Recupero utente
    final user = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [userId],
    );

    if (user.isEmpty) return false;

    final currentPassword = user.first['password'];

    // Controllo password attuale
    if (currentPassword != oldPassword) {
      return false; // password attuale errata
    }

    // Aggiorno password
    await db.update(
      'users',
      {'password': newPassword},
      where: 'id = ?',
      whereArgs: [userId],
    );

    return true;
  }

  static Future<void> incrementChatCount(int userId) async {
    final db = await DatabaseService.database;

    await db.rawUpdate('''
      UPDATE users
      SET chatCount = chatCount + 1
      WHERE id = ?
    ''', [userId]);
  }

  static Future<void> decrementChatCount(int userId) async {
    final db = await DatabaseService.database;

    await db.rawUpdate('''
      UPDATE users
      SET chatCount = CASE 
        WHEN chatCount > 0 THEN chatCount - 1
        ELSE 0
      END
      WHERE id = ?
    ''', [userId]);
  }


}
