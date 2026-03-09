import 'package:flutter/material.dart';
import '../services/user_service.dart';
import 'chat_screen.dart';

class UserSearchScreen extends StatefulWidget {
  final int myId; // ID dell’utente loggato

  const UserSearchScreen({super.key, required this.myId});

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final TextEditingController _controller = TextEditingController();

  // Risultati della ricerca
  List<Map<String, dynamic>> results = [];

  // -------------------------------------------------------------
  // Funzione di ricerca utenti
  // -------------------------------------------------------------
  Future<void> _search(String text) async {
    // Se il campo è vuoto → svuota risultati
    if (text.isEmpty) {
      setState(() => results = []);
      return;
    }

    // Chiamata al database per cercare utenti
    final data = await UserService.searchUsers(text, widget.myId);

    // Filtra eventuali righe incomplete (username null)
    final safeData = data.where((u) => u['username'] != null).toList();

    // Aggiorna la UI
    setState(() => results = safeData);
  }

  // -------------------------------------------------------------
  // UI
  // -------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cerca utente"),
      ),

      body: Column(
        children: [
          // ---------------------------------------------------------
          // Barra di ricerca
          // ---------------------------------------------------------
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _controller,
              onChanged: _search, // ricerca in tempo reale
              decoration: InputDecoration(
                hintText: "Cerca username...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // ---------------------------------------------------------
          // Lista risultati
          // ---------------------------------------------------------
          Expanded(
            child: results.isEmpty
                ? const Center(child: Text("Nessun utente trovato"))
                : ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final user = results[index];

                      // Username sicuro
                      final username = user['username'] ?? "Utente";

                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(username[0].toUpperCase()),
                        ),
                        title: Text(username),

                        // Apri la chat con l’utente selezionato
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ChatScreen(
                                myId: widget.myId,
                                otherId: user['id'],
                                otherUsername: username,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
