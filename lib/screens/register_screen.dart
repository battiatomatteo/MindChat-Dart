import 'package:flutter/material.dart';
import '../services/user_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Chiave per validare il form
  final _formKey = GlobalKey<FormState>();

  // Controller dei campi input
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // Gestisce la visibilità della password
  bool _showPassword = false;

  // -------------------------------------------------------------
  // Funzione chiamata quando premi "Registrati"
  // -------------------------------------------------------------
  Future<void> _onRegisterPressed() async {
    // Controlla se tutti i campi sono validi
    if (_formKey.currentState!.validate()) {
      final username = _usernameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      // Prova a registrare l’utente nel database
      final result = await UserService.registerUser(username, email, password);

      // -1 = email già esistente
      if (result == -1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email già registrata')),
        );
        return;
      }

      // Registrazione OK
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registrazione completata!')),
      );

      // Torna alla schermata precedente (login)
      Navigator.pop(context);
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
              // Titoli introduttivi
              Text('Crea un account', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text('Unisciti a noi', style: Theme.of(context).textTheme.bodyLarge),
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

                // FORM DI REGISTRAZIONE
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Campo username
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(labelText: 'Username'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Inserisci un username';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Campo email
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Inserisci una email';
                          }
                          if (!value.contains('@')) {
                            return 'Email non valida';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Campo password
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_showPassword, // mostra/nasconde password
                        decoration: InputDecoration(
                          labelText: 'Password',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _showPassword ? Icons.visibility_off : Icons.visibility,
                              color: Colors.blueAccent,
                            ),
                            onPressed: () {
                              setState(() {
                                _showPassword = !_showPassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Inserisci una password';
                          }
                          if (value.length < 6) {
                            return 'Minimo 6 caratteri';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),

                      // Pulsante REGISTRAZIONE
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _onRegisterPressed,
                          child: const Text('Registrati'),
                        ),
                      ),
                    ],
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
