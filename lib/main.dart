import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/device_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    final prefs = await SharedPreferences.getInstance();

    String? deviceId = prefs.getString('deviceId');
    if (deviceId == null) {
      deviceId = const Uuid().v4();
      prefs.setString('deviceId', deviceId);
    }

    final device = await DeviceService.getLoggedDevice(deviceId);

    print("MAIN STARTED");
    print("DEVICE ID: $deviceId");
    print("DEVICE FOUND: $device");



    runApp(MyApp(autoLoginUserId: device?['userId']));
  } catch (e) {
    print("ERRORE MAIN: $e");
    runApp(const MyApp(autoLoginUserId: null));
  }
  
}


class MyApp extends StatelessWidget {
  final int? autoLoginUserId;

  const MyApp({super.key, this.autoLoginUserId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
          brightness: Brightness.light,
        ),

        scaffoldBackgroundColor: const Color(0xFFF5F7FA),

        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          bodyLarge: TextStyle(
            fontSize: 18,
            color: Colors.black54,
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.black26, width: 1.2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
          ),
          labelStyle: const TextStyle(fontSize: 16),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
            elevation: 3,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
      title: 'MindChat',
      home: autoLoginUserId != null
          ? HomeScreen(myId: autoLoginUserId!)
          : const LoginScreen(),
    );
  }
}
