import 'package:sqflite/sqflite.dart';
import 'database_service.dart';

class DeviceService {
  static Future<Map<String, dynamic>?> getLoggedDevice(String deviceId) async {
    final db = await DatabaseService.database;

    final result = await db.query(
      'devices',
      where: 'deviceId = ? AND isLogged = 1',
      whereArgs: [deviceId],
    );

    if (result.isEmpty) return null;
    return result.first;
  }


  static Future<void> registerDevice(int userId, String deviceId) async {
    final db = await DatabaseService.database;

    final existing = await db.query(
      'devices',
      where: 'deviceId = ?',
      whereArgs: [deviceId],
    );

    if (existing.isEmpty) {
      await db.insert('devices', {
        'userId': userId,
        'deviceId': deviceId,
        'isLogged': 1,
        'lastLogin': DateTime.now().millisecondsSinceEpoch,
      });
    } else {
      await db.update(
        'devices',
        {
          'userId': userId,
          'isLogged': 1,
          'lastLogin': DateTime.now().millisecondsSinceEpoch,
        },
        where: 'deviceId = ?',
        whereArgs: [deviceId],
      );
    }
  }

  static Future<void> logoutDevice(String deviceId) async {
    final db = await DatabaseService.database;

    await db.update(
      'devices',
      {'isLogged': 0},
      where: 'deviceId = ?',
      whereArgs: [deviceId],
    );
  }
}
