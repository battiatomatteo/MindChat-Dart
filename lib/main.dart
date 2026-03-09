import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/device_service.dart';

void main() async {
  // Necessario per usare plugin async PRIMA di runApp()
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Otteniamo l'istanza delle SharedPreferences
    final prefs = await SharedPreferences.getInstance();

    // Recuperiamo l'ID univoco del dispositivo (se esiste)
    String? deviceId = prefs.getString('deviceId');

    // Se non esiste, lo creiamo e lo salviamo
    if (deviceId == null) {
      deviceId = const Uuid().v4(); // genera UUID univoco
      prefs.setString('deviceId', deviceId);
    }

    // Cerchiamo nel database se questo device risulta loggato
    final device = await DeviceService.getLoggedDevice(deviceId);

    print("MAIN STARTED");
    print("DEVICE ID: $deviceId");
    print("DEVICE FOUND: $device");

    // Se device contiene un userId → login automatico
    runApp(MyApp(autoLoginUserId: device?['userId']));
  } catch (e) {
    // In caso di errore, avviamo comunque l'app senza auto-login
    print("ERRORE MAIN: $e");
    runApp(const MyApp(autoLoginUserId: null));
  }
}

class MyApp extends StatelessWidget {
  final int? autoLoginUserId;

  // autoLoginUserId = null → mostra LoginScreen
  // autoLoginUserId = valore → entra direttamente nella Home
  const MyApp({super.key, this.autoLoginUserId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // Tema generale dell'app
      theme: ThemeData(
        useMaterial3: true,

        // Colori principali
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blueAccent,
          brightness: Brightness.light,
        ),

        // Colore di sfondo globale
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),

        // Stile dei testi
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

        // Stile dei TextField
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

        // Stile dei pulsanti
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

      // Se autoLoginUserId è presente → vai alla Home
      // Altrimenti → mostra LoginScreen
      home: autoLoginUserId != null
          ? HomeScreen(myId: autoLoginUserId!)
          : const LoginScreen(),
    );
  }
}

