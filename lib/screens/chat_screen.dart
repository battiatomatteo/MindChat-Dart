import 'package:flutter/material.dart';
import '../services/chat_service.dart';

class ChatScreen extends StatefulWidget {
  final int myId;             // ID dell'utente loggato
  final int otherId;          // ID dell'altro utente
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
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, dynamic>> messages = [];

  bool isFriend = false; // ⭐ stato locale

  @override
  void initState() {
    super.initState();
    _markAsRead();
    _loadMessages();
    _loadFriendStatus();
  }

  Future<void> _loadFriendStatus() async {
    final result = await ChatService.isFriend(widget.myId, widget.otherId);
    setState(() {
      isFriend = result;
    });
  }

  Future<void> _toggleFriend() async {
    if (isFriend) {
      await ChatService.removeFriend(widget.myId, widget.otherId);
    } else {
      await ChatService.addFriend(widget.myId, widget.otherId);
    }

    setState(() {
      isFriend = !isFriend;
    });
  }

  Future<void> _markAsRead() async {
    await ChatService.markAsRead(widget.myId, widget.otherId);
  }

  Future<void> _loadMessages() async {
    final data = await ChatService.getMessages(widget.myId, widget.otherId);

    setState(() {
      messages = data;
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    await ChatService.sendMessage(widget.myId, widget.otherId, text);
    _controller.clear();
    await _loadMessages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text(
          widget.otherUsername,
          style: const TextStyle(color: Colors.white), // testo bianco
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              isFriend ? Icons.star : Icons.star_border,
              color: isFriend ? Colors.yellow[700] : Colors.white, // icona visibile sul blu
            ),
            onPressed: _toggleFriend,
          ),
        ],
      ),

      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                final mine = msg['senderId'] == widget.myId;

                return Align(
                  alignment:
                      mine ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: mine ? Colors.blueAccent : Colors.grey[300],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      msg['text'],
                      style: TextStyle(
                        color: mine ? Colors.white : Colors.black87,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
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
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: "Scrivi un messaggio...",
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
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
