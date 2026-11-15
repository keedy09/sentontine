import 'package:flutter/material.dart';
import '../login_page.dart'; // ✅ AJOUT OBLIGATOIRE
import 'home_member_page.dart';
import 'tontines_page.dart';
import 'paiements_page.dart';
import 'mes_gains_page.dart';

class HomePage extends StatefulWidget {
  final bool isAdmin;
  final String? membreId;

  const HomePage({
    super.key,
    required this.isAdmin,
    this.membreId,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<String> _titles = [
    "Accueil",
    "Mes Tontines",
    "Paiements",
    "Mes Gains",
  ];

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeMemberPage(membreId: widget.membreId),
      TontinesPage(membreId: widget.membreId),
      PaiementsPage(membreId: widget.membreId),
      MesGainsPage(membreId: widget.membreId!),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF00853F),
        elevation: 6,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              // Confirmer la déconnexion
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Déconnexion"),
                  content:
                  const Text("Voulez-vous vraiment vous déconnecter ?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Annuler"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Fermer le dialog
                        // ✅ CORRECTION : pushReplacement au lieu de pop
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE30B17),
                      ),
                      child: const Text("Déconnexion"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
        },
        selectedItemColor: const Color(0xFF00853F),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        elevation: 10,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Accueil"),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: "Tontines"),
          BottomNavigationBarItem(
              icon: Icon(Icons.payments), label: "Paiements"),
          BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events), label: "Mes Gains"),
        ],
      ),
    );
  }
}