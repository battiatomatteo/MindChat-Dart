import 'package:flutter/material.dart';
import '../services/user_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _showPassword = false;

  // Regex validazione email
  final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');

  // Regex password forte
  final passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}$'
  );

  // -------------------------------------------------------------
  // REGISTRAZIONE
  // -------------------------------------------------------------
  Future<void> _onRegisterPressed() async {
    if (_formKey.currentState!.validate()) {
      final username = _usernameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      final result = await UserService.registerUser(username, email, password);

      if (result == -1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email già registrata')),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registrazione completata!')),
      );

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
              Text('Crea un account', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              Text('Unisciti a noi', style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 40),

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

                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // USERNAME
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(labelText: 'Username'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Inserisci un username';
                          }
                          if (value.length < 3) {
                            return 'Minimo 3 caratteri';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // EMAIL
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Inserisci una email';
                          }
                          if (!emailRegex.hasMatch(value)) {
                            return 'Email non valida';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // PASSWORD
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_showPassword,
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
                          if (!passwordRegex.hasMatch(value)) {
                            return 'La password deve contenere:\n• 1 maiuscola\n• 1 minuscola\n• 1 numero\n• 1 simbolo\n• Minimo 8 caratteri';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 30),

                      // REGISTRAZIONE
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
