import 'package:flutter/material.dart';
import '../services/user_service.dart';
import 'login_screen.dart';
import 'SettingsScreen.dart';

class UserProfileScreen extends StatefulWidget {
  final int userId;

  const UserProfileScreen({super.key, required this.userId});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  Map<String, dynamic>? user;
  final TextEditingController _bioController = TextEditingController();

  bool _isEditingBio = false; // 🔥 DEVE STARE QUI, NON NEL WIDGET

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final data = await UserService.getUserById(widget.userId);

    if (data == null) return;

    setState(() {
      user = data;
      _bioController.text = data['bio'] ?? "";
    });
  }

  Future<void> _saveBio() async {
    final newBio = _bioController.text.trim();
    await UserService.updateBio(widget.userId, newBio);

    setState(() {
      _isEditingBio = false;
      user!['bio'] = newBio;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Bio aggiornata")),
    );
  }

  
  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profilo Utente"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => SettingsScreen(userId: widget.userId)),
              );
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // FOTO PROFILO
            CircleAvatar(
              radius: 60,
              backgroundColor: Colors.blueAccent,
              child: Text(
                user!['username'][0].toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // USERNAME
            Text(
              user!['username'],
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 6),

            // EMAIL
            Text(
              user!['email'],
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 30),

            // BOX INFO
            Container(
              width: double.infinity,
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

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Informazioni",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // BIO + ICONA PENNA
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Bio",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _isEditingBio = true;
                          });
                        },
                        child: const Icon(
                          Icons.edit,
                          size: 20,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // CAMPO BIO
                  _isEditingBio
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            TextField(
                              controller: _bioController,
                              maxLines: 3,
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: Colors.grey[200],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                                hintText: "Scrivi qualcosa su di te...",
                              ),
                            ),

                            const SizedBox(height: 6),

                            GestureDetector(
                              onTap: _saveBio,
                              child: const Text(
                                "Salva",
                                style: TextStyle(
                                  color: Colors.blueAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Text(
                          user!['bio']?.isNotEmpty == true
                              ? user!['bio']
                              : "Nessuna bio disponibile",
                          style: const TextStyle(fontSize: 16),
                        ),

                  const SizedBox(height: 20),

                  // STATISTICHE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _statBox(
                        icon: Icons.note_alt_outlined,
                        label: "Note",
                        value: (user!['noteCount'] ?? 0).toString(),
                        color: Colors.orange,
                      ),
                      _statBox(
                        icon: Icons.chat_bubble_outline,
                        label: "Interazioni",
                        value: (user!['chatCount'] ?? 0).toString(),
                        color: Colors.green,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // LOGOUT
            
          ],
        ),
      ),
    );
  }

  // BOX STATISTICHE
  Widget _statBox({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      width: 110,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
