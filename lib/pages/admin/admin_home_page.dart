import 'package:flutter/material.dart';
import '../../data/shared_data.dart';
import '../login_page.dart';
import 'admin_tontines_page.dart';
import 'admin_members_page.dart';
import 'paiements_admin_page.dart';
import 'tirage_page.dart';
import 'historique_actions_page.dart'; // ✅ NOUVEAU

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  final SharedData _data = SharedData();
  int _selectedIndex = 0;

  final List<String> _titles = [
    "Tableau de bord",
    "Tontines",
    "Membres",
    "Paiements",
    "Tirage",
    "Historique", // ✅ NOUVEAU
  ];

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Déconnexion"),
        content: const Text("Voulez-vous vraiment vous déconnecter ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE30B17),
            ),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
            },
            child: const Text("Déconnexion"),
          ),
        ],
      ),
    );
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
        backgroundColor: const Color(0xFF00853F),
        elevation: 5,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: _logout,
          ),
        ],
      ),

      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildDashboard(),
          const AdminTontinesPage(),
          const AdminMembersPage(),
          const PaiementsAdminPage(),
          const TiragePage(),
          const HistoriqueActionsPage(), // ✅ NOUVEAU
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF00853F),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 10,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: "Accueil"),
          BottomNavigationBarItem(
              icon: Icon(Icons.group_work), label: "Tontines"),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: "Membres"),
          BottomNavigationBarItem(
              icon: Icon(Icons.payments), label: "Paiements"),
          BottomNavigationBarItem(icon: Icon(Icons.casino), label: "Tirage"),
          BottomNavigationBarItem(
              icon: Icon(Icons.history), label: "Historique"), // ✅ NOUVEAU
        ],
      ),
    );
  }

  Widget _buildDashboard() {
    final tontinesActives = _data.getTontinesActives();
    final totalMembres = _data.getTotalMembres();
    final totalCotise = _data.getTotalCotisations();
    final paiementsEnAttente = _data.getPaiementsEnAttenteCount();
    final totalCommissions = _data.getTotalCommissions();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Bienvenue, Administrateur 👋",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Voici un aperçu de l'activité de vos tontines :",
            style: TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatCard(
                "Tontines actives",
                tontinesActives.toString(),
                Icons.group_work,
                Colors.green,
              ),
              _buildStatCard(
                "Membres inscrits",
                totalMembres.toString(),
                Icons.people,
                Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatCard(
                "Total cotisé",
                "${totalCotise.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} FCFA",
                Icons.attach_money,
                Colors.blue,
              ),
              _buildStatCard(
                "En attente",
                paiementsEnAttente.toString(),
                Icons.access_time,
                Colors.red,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatCard(
                "Commissions perçues",
                "${totalCommissions.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} FCFA",
                Icons.account_balance_wallet,
                const Color(0xFF00853F),
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
          const SizedBox(height: 30),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFE30B17), Color(0xFFB00913)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedIndex = 4;
                });
              },
              child: const Row(
                children: [
                  Icon(Icons.casino, color: Colors.white, size: 32),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Effectuer un tirage",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          "Déterminez le bénéficiaire de la cagnotte",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios, color: Colors.white),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Activités récentes",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                if (_data.paiements.isNotEmpty) ...[
                  ..._data.paiements.take(5).map((p) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Icon(
                          p["statut"] == "Payé"
                              ? Icons.check_circle
                              : Icons.pending,
                          color: p["statut"] == "Payé"
                              ? Colors.green
                              : Colors.orange,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p["membreNom"],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                "${p["tontineNom"]} - ${p["montant"]} FCFA",
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          p["date"],
                          style: const TextStyle(
                            color: Colors.black45,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )),
                ] else
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        "Aucune activité récente",
                        style: TextStyle(color: Colors.black45),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 30),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Évolution des cotisations",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Center(
                  child: Icon(Icons.show_chart,
                      size: 100, color: Color(0xFF00853F)),
                ),
                SizedBox(height: 10),
                Text(
                  "Graphique à venir - Intégration future",
                  style: TextStyle(color: Colors.black45),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}