import 'package:flutter/material.dart';
import '../services/user_service.dart';
import 'chat_screen.dart';

class UserSearchScreen extends StatefulWidget {
  final int myId;

  const UserSearchScreen({super.key, required this.myId});

  @override
  State<UserSearchScreen> createState() => _UserSearchScreenState();
}

class _UserSearchScreenState extends State<UserSearchScreen> {
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> results = [];

  Future<void> _search(String text) async {
    if (text.isEmpty) {
      setState(() => results = []);
      return;
    }

    final data = await UserService.searchUsers(text, widget.myId);

    // Filtra righe incomplete o con username null
    final safeData = data.where((u) => u['username'] != null).toList();

    setState(() => results = safeData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cerca utente"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _controller,
              onChanged: _search,
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

          Expanded(
            child: results.isEmpty
                ? const Center(child: Text("Nessun utente trovato"))
                : ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final user = results[index];

                      final username = user['username'] ?? "Utente";

                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(username[0].toUpperCase()),
                        ),
                        title: Text(username),
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
