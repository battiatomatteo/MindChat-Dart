import 'package:sqflite/sqflite.dart';
import 'database_service.dart';

class UserService {
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
    });
  }

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

  static Future<List<Map<String, dynamic>>> searchUsers(String query, int myId) async {
    final db = await DatabaseService.database;

    return await db.query(
      'users',
      where: 'username LIKE ? AND id != ?',
      whereArgs: ['%$query%', myId],
    );
  }
  
  static Future<Map<String, dynamic>?> getUserById(int id) async {
    final db = await DatabaseService.database;
    final res = await db.query("users", where: "id = ?", whereArgs: [id]);
    return res.isNotEmpty ? res.first : null;
  }

  static Future<void> logout(int userId) async {
    final db = await DatabaseService.database;
    await db.update(
      "devices",
      {"isLogged": 0},
      where: "userId = ?",
      whereArgs: [userId],
    );
  }


}
