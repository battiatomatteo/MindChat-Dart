import 'package:flutter/material.dart';
import 'package:mindchat/screens/user_search_screen.dart';
import '../services/chat_service.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  final int myId; // ID dell’utente loggato

  const ChatListScreen({super.key, required this.myId});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  // Lista delle conversazioni recuperate dal database
  List<Map<String, dynamic>> conversations = [];

  @override
  void initState() {
    super.initState();
    _loadConversations(); // Carica le conversazioni all’avvio
  }

  // -------------------------------------------------------------
  // Carica tutte le conversazioni dell’utente loggato
  // -------------------------------------------------------------
  Future<void> _loadConversations() async {
    try {
      final data = await ChatService.getConversations(widget.myId);

      // Filtra eventuali righe incomplete per evitare crash
      final safeData = data.where((c) =>
          c['username'] != null &&
          c['timestamp'] != null &&
          c['lastMessage'] != null).toList();

      setState(() {
        conversations = safeData;
      });
    } catch (e) {
      print("ERRORE CHAT LIST: $e");
    }
  }

  // -------------------------------------------------------------
  // UI
  // -------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: const Text("Chat", style: TextStyle(
          color: Colors.white,   // 🔥 colore del testo
          fontWeight: FontWeight.w600,
        ),),
        centerTitle: true,
        actions: [
          // Pulsante per cercare nuovi utenti e iniziare nuove chat
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => UserSearchScreen(myId: widget.myId),
                ),
              ).then((_) {
                _loadConversations(); // 🔥 aggiorna la lista quando torni
              });
            },
          ),
        ],
      ),

      // ---------------------------------------------------------
      // Lista conversazioni
      // ---------------------------------------------------------
      body: conversations.isEmpty
          ? const Center(child: Text("Nessuna conversazione"))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: conversations.length,
              itemBuilder: (context, index) {
                final chat = conversations[index];

                final username = chat['username'] ?? "Utente";
                final lastMessage = chat['lastMessage'] ?? "";
                final timestamp = chat['timestamp'] ?? 0;
                final hasUnread = chat['hasUnread'] ?? 0; // 🔥 badge "new"

                return GestureDetector(
                  onTap: () {
                    // Apri la chat selezionata
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatScreen(
                          myId: widget.myId,
                          otherId: chat['userId'],
                          otherUsername: username,
                        ),
                      ),
                    ).then((_) {
                      _loadConversations(); // 🔥 aggiorna quando torni
                    });
                  },

                  // -----------------------------------------------------
                  // Card della conversazione
                  // -----------------------------------------------------
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12.withOpacity(0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),

                    child: Row(
                      children: [
                        // Avatar con iniziale dell’utente
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.blueAccent,
                          child: Text(
                            username[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Nome utente + ultimo messaggio
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                username,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                lastMessage,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 15,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 10),

                        // 🔥 Badge "new" se ci sono messaggi non letti
                        if (hasUnread == 1)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              "new",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),

                        const SizedBox(width: 10),

                        // Orario dell’ultimo messaggio
                        Text(
                          _formatTimestamp(timestamp),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  // -------------------------------------------------------------
  // Formatta timestamp in HH:MM
  // -------------------------------------------------------------
  String _formatTimestamp(int ts) {
    if (ts == 0) return "";
    final dt = DateTime.fromMillisecondsSinceEpoch(ts);
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }
}
