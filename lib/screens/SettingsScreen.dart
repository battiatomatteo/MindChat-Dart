import 'package:flutter/material.dart';
import '../services/user_service.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  final int userId;

  const SettingsScreen({super.key, required this.userId});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;
  bool darkModeEnabled = false;

  bool showEmailForm = false;
  bool showPasswordForm = false;

  final TextEditingController _newEmailController = TextEditingController();
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();

  // VALIDAZIONI
  final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w+$');
  final passwordRegex = RegExp(
    r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{8,}$'
  );

  Future<void> _logout() async {
    await UserService.logout(widget.userId);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  // TILE BASE
  Widget _settingsTile({
    required String label,
    required bool expanded,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        margin: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            AnimatedRotation(
              turns: expanded ? 0.25 : 0,
              duration: const Duration(milliseconds: 200),
              child: const Icon(Icons.arrow_forward_ios, size: 18),
            ),
          ],
        ),
      ),
    );
  }

  // FORM A SCOMPARSA
  Widget _animatedForm({required Widget child, required bool visible}) {
    return AnimatedCrossFade(
      firstChild: const SizedBox.shrink(),
      secondChild: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(14),
        ),
        child: child,
      ),
      crossFadeState:
          visible ? CrossFadeState.showSecond : CrossFadeState.showFirst,
      duration: const Duration(milliseconds: 250),
    );
  }

  // AGGIORNA EMAIL
  Future<void> _updateEmail() async {
    final newEmail = _newEmailController.text.trim();

    if (!emailRegex.hasMatch(newEmail)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Inserisci una email valida")),
      );
      return;
    }

    final success = await UserService.updateEmail(widget.userId, newEmail);

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email già in uso")),
      );
      return;
    }

    setState(() => showEmailForm = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Email aggiornata")),
    );
  }

  // AGGIORNA PASSWORD
  Future<void> _updatePassword() async {
    final oldPass = _oldPasswordController.text.trim();
    final newPass = _newPasswordController.text.trim();

    if (!passwordRegex.hasMatch(newPass)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("La password non rispetta i requisiti")),
      );
      return;
    }

    if (oldPass == newPass) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("La nuova password non può essere uguale alla precedente")),
      );
      return;
    }

    final success = await UserService.updatePassword(
      widget.userId,
      oldPass,
      newPass,
    );

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password attuale errata")),
      );
      return;
    }

    setState(() => showPasswordForm = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Password aggiornata")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Impostazioni"),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // NOTIFICHE
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Notifiche", style: TextStyle(fontSize: 16)),
                Switch(
                  value: notificationsEnabled,
                  activeColor: Colors.blueAccent,
                  onChanged: (v) => setState(() => notificationsEnabled = v),
                ),
              ],
            ),

            // TEMA SCURO
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Tema scuro", style: TextStyle(fontSize: 16)),
                Switch(
                  value: darkModeEnabled,
                  activeColor: Colors.blueAccent,
                  onChanged: (v) => setState(() => darkModeEnabled = v),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // CAMBIA EMAIL
            _settingsTile(
              label: "Cambia email",
              expanded: showEmailForm,
              onTap: () {
                setState(() {
                  showEmailForm = !showEmailForm;
                  showPasswordForm = false;
                });
              },
            ),

            _animatedForm(
              visible: showEmailForm,
              child: Column(
                children: [
                  TextField(
                    controller: _newEmailController,
                    decoration: const InputDecoration(
                      labelText: "Nuova email",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _updateEmail,
                    child: const Text("Aggiorna email"),
                  ),
                ],
              ),
            ),

            // CAMBIA PASSWORD
            _settingsTile(
              label: "Cambia password",
              expanded: showPasswordForm,
              onTap: () {
                setState(() {
                  showPasswordForm = !showPasswordForm;
                  showEmailForm = false;
                });
              },
            ),

            _animatedForm(
              visible: showPasswordForm,
              child: Column(
                children: [
                  TextField(
                    controller: _oldPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Password attuale",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _newPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Nuova password",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _updatePassword,
                    child: const Text("Aggiorna password"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // LOGOUT
            ElevatedButton(
              onPressed: _logout,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: const Text(
                "Esci",
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
