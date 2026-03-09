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
  // Indice della tab selezionata nel BottomNavigationBar
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // -------------------------------------------------------------
    // Lista delle schermate collegate alle 3 icone in basso
    // -------------------------------------------------------------
    final screens = [
      ChatListScreen(myId: widget.myId),          // Tab 0 → Social / Chat
      const Center(child: Text("Note (in arrivo)")), // Tab 1 → Note (placeholder)
      UserProfileScreen(userId: widget.myId),     // Tab 2 → Profilo utente
    ];

    return Scaffold(
      // Mostra la schermata corrispondente alla tab selezionata
      body: screens[_selectedIndex],

      // -------------------------------------------------------------
      // Barra di navigazione inferiore (BottomNavigationBar)
      // -------------------------------------------------------------
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,          // Tab attiva
        selectedItemColor: Colors.blueAccent,  // Colore icona attiva
        unselectedItemColor: Colors.grey,      // Colore icone inattive

        // Quando l’utente tocca una tab → aggiorna l’indice
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },

        // Icone e label delle 3 sezioni
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
