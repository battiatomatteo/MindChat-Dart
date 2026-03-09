import 'package:flutter/material.dart';
import '../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final int myId;            // ID dell'utente loggato
  final int otherId;         // ID dell'altro utente
  final String otherUsername; // Nome dell'altro utente

  const ChatScreen({
    super.key,
    required this.myId,
    required this.otherId,
    required this.otherUsername,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // Controller per il campo di testo
  final TextEditingController _controller = TextEditingController();

  // Controller per scrollare automaticamente in basso
  final ScrollController _scrollController = ScrollController();

  // Lista dei messaggi caricati dal DB
  List<Map<String, dynamic>> messages = [];

  @override
  void initState() {
    super.initState();
    _markAsRead();   // Segna i messaggi come letti appena entri nella chat
    _loadMessages(); // Carica i messaggi dal database
  }

  // -------------------------------------------------------------
  // Segna i messaggi dell'altro utente come "letti"
  // -------------------------------------------------------------
  Future<void> _markAsRead() async {
    await ChatService.markAsRead(widget.myId, widget.otherId);
  }

  // -------------------------------------------------------------
  // Carica i messaggi dal database
  // -------------------------------------------------------------
  Future<void> _loadMessages() async {
    final data = await ChatService.getMessages(widget.myId, widget.otherId);

    setState(() {
      messages = data;
    });

    // Scroll automatico verso il basso dopo un breve delay
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  // -------------------------------------------------------------
  // Invia un messaggio
  // -------------------------------------------------------------
  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    // Salva il messaggio nel DB
    await ChatService.sendMessage(widget.myId, widget.otherId, text);

    _controller.clear();

    // Ricarica i messaggi per aggiornare la UI
    await _loadMessages();
  }

  // -------------------------------------------------------------
  // UI
  // -------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUsername),
        centerTitle: true,
      ),

      body: Column(
        children: [
          // ---------------------------------------------------------
          // Lista dei messaggi
          // ---------------------------------------------------------
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];

                // True se il messaggio è mio
                final isMine = msg['senderId'] == widget.myId;

                return Align(
                  alignment:
                      isMine ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isMine ? Colors.blueAccent : Colors.grey[300],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      msg['text'],
                      style: TextStyle(
                        color: isMine ? Colors.white : Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // ---------------------------------------------------------
          // Barra di input messaggio
          // ---------------------------------------------------------
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Campo di testo
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Scrivi un messaggio...",
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                // Pulsante invio
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.blueAccent,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
