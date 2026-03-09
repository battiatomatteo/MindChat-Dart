import 'package:flutter/material.dart';
import 'package:mindchat/services/device_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/user_service.dart';
import 'register_screen.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controller dei campi input
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Gestisce la visibilità della password
  bool _showPassword = false;

  // -------------------------------------------------------------
  // Funzione chiamata quando premi "Accedi"
  // -------------------------------------------------------------
  Future<void> _onLoginPressed() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    // Controllo credenziali nel database
    final user = await UserService.login(email, password);

    if (user != null) {
      // Recupero deviceId salvato nel main
      final prefs = await SharedPreferences.getInstance();
      final deviceId = prefs.getString('deviceId');

      // Registra il dispositivo come "loggato"
      await DeviceService.registerDevice(user['id'], deviceId!);

      // Naviga alla Home
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(myId: user['id']),
        ),
      );
    } else {
      // Credenziali errate → mostra errore
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Credenziali errate')),
      );
    }
  }

  // -------------------------------------------------------------
  // UI
  // -------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titolo principale
              Text(
                'Bentornato',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),

              // Sottotitolo
              Text(
                'Accedi per continuare',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 40),

              // Card bianca con il form
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),

                // FORM DI LOGIN
                child: Column(
                  children: [
                    // Campo email
                    TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                    ),
                    const SizedBox(height: 20),

                    // Campo password
                    TextField(
                      controller: _passwordController,
                      obscureText: !_showPassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _showPassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.blueAccent,
                          ),
                          onPressed: () {
                            setState(() {
                              _showPassword = !_showPassword;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Pulsante ACCEDI
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _onLoginPressed,
                        child: const Text('Accedi'),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // Link alla registrazione
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const RegisterScreen()),
                    );
                  },
                  child: const Text(
                    'Non hai un account? Registrati',
                    style: TextStyle(
                      fontSize: 17,
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
