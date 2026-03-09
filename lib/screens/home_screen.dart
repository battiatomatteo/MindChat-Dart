import 'package:flutter/material.dart';
import 'chat_list_screen.dart';
import 'UserProfileScreen.dart';

class HomeScreen extends StatefulWidget {
  final int myId; // ID dell'utente loggato

  const HomeScreen({super.key, required this.myId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final screens = [
      ChatListScreen(myId: widget.myId),
      const Center(child: Text("Note (in arrivo)")),
      UserProfileScreen(userId: widget.myId),
    ];

    return Scaffold(
      body: screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: "Social",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.note_alt_outlined),
            label: "Note",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profilo",
          ),
        ],
      ),
    );
  }
}
