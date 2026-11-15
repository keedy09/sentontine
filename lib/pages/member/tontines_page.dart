import 'package:flutter/material.dart';
import '../../data/shared_data.dart';
import '../../utils/member_card_generator.dart';

class TontinesPage extends StatelessWidget {
  final String? membreId;

  const TontinesPage({super.key, this.membreId});

  @override
  Widget build(BuildContext context) {
    final SharedData data = SharedData();

    // Récupérer la tontine du membre
    List<Map<String, dynamic>> mesTontines = [];
    if (membreId != null) {
      final membre = data.getMembre(membreId!);
      if (membre != null &&
          membre['tontineId'] != null &&
          membre['tontineId'].isNotEmpty) {
        final tontine = data.getTontine(membre['tontineId']);
        if (tontine != null) {
          mesTontines.add(tontine);
        }
      }
    }

    // Pour la démo, on peut aussi afficher toutes les tontines actives
    final tontinesActives =
        data.tontines.where((t) => t['statut'] == 'Active').toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Mes Tontines 💰",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00853F),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Consultez vos tontines actives et leur progression.",
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 20),

              // Ma tontine
              if (mesTontines.isNotEmpty) ...[
                const Text(
                  "Ma tontine",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00853F),
                  ),
                ),
                const SizedBox(height: 10),
                ...mesTontines
                    .map((t) => _buildTontineCard(context, t, estMembre: true))
                    .toList(),
                const SizedBox(height: 20),
              ],

              // Autres tontines disponibles
              const Text(
                "Tontines disponibles",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 10),

              // Liste scrollable
              SizedBox(
                height: 400,
                child: tontinesActives.isEmpty
                    ? const Center(
                        child: Text(
                          "Aucune tontine disponible pour le moment",
                          style: TextStyle(color: Colors.black54),
                        ),
                      )
                    : ListView(
                        children: tontinesActives
                            .where((t) =>
                                !mesTontines.any((mt) => mt['id'] == t['id']))
                            .map((t) =>
                                _buildTontineCard(context, t, estMembre: false))
                            .toList(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTontineCard(BuildContext context, Map<String, dynamic> t,
      {required bool estMembre}) {
    // Déterminer la couleur selon le statut
    Color couleur;
    if (t["statut"] == "Active") {
      couleur = Colors.green;
    } else if (t["statut"] == "Complète") {
      couleur = Colors.orange;
    } else if (t["statut"] == "En attente") {
      couleur = Colors.orange;
    } else {
      couleur = Colors.red;
    }

    return Card(
      elevation: 5,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [couleur.withValues(alpha: 0.15), Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec nom et badge
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: couleur.withValues(alpha: 0.2),
                          child: Icon(Icons.savings, color: couleur),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t["nom"],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              if (estMembre)
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[100],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text(
                                    "Membre",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: couleur.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      t["statut"],
                      style: TextStyle(
                        color: couleur,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Informations principales
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      Icons.attach_money,
                      "Cotisation",
                      "${t["montant"]} FCFA",
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      Icons.calendar_month,
                      "Fréquence",
                      t["frequence"],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      Icons.group,
                      "Membres",
                      "${t["membres"]} personnes",
                    ),
                  ),
                  Expanded(
                    child: _buildInfoItem(
                      Icons.account_balance_wallet,
                      "Total",
                      "${t["montantTotal"]} FCFA",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Période
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.play_arrow,
                            size: 16, color: Colors.black54),
                        const SizedBox(width: 4),
                        Text(
                          t["dateDebut"],
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    const Icon(Icons.arrow_forward,
                        size: 16, color: Colors.black54),
                    Row(
                      children: [
                        Text(
                          t["dateFin"],
                          style: const TextStyle(fontSize: 12),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.stop, size: 16, color: Colors.black54),
                      ],
                    ),
                  ],
                ),
              ),

              // Bouton voir détails
              const SizedBox(height: 12),
              Center(
                child: TextButton.icon(
                  onPressed: () {
                    _afficherDetails(context, t, membreId);
                  },
                  icon: const Icon(Icons.info_outline, size: 18),
                  label: const Text("Voir les détails"),
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF00853F),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.black54),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.black54,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _afficherDetails(
      BuildContext context, Map<String, dynamic> t, String? membreId) {
    final SharedData data = SharedData();
    final membre = membreId != null ? data.getMembre(membreId) : null;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          t["nom"],
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow("💰 Cotisation", "${t["montant"]} FCFA"),
              _buildDetailRow("📅 Fréquence", t["frequence"]),
              _buildDetailRow("👥 Membres", "${t["membres"]} personnes"),
              _buildDetailRow("🎯 Statut", t["statut"]),
              _buildDetailRow("📍 Début", t["dateDebut"]),
              _buildDetailRow("🏁 Fin", t["dateFin"]),
              _buildDetailRow("💵 Total", "${t["montantTotal"]} FCFA"),
              _buildDetailRow("🎲 Tirage",
                  t["tirageAleatoire"] ? "Aléatoire" : "Ordre fixe"),
              const SizedBox(height: 12),
              const Text(
                "Description :",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                t["description"].toString().isNotEmpty
                    ? t["description"]
                    : "Aucune description disponible",
                style: const TextStyle(color: Colors.black87),
              ),
              const SizedBox(height: 16),
              const Text(
                "📜 Règlement intérieur :",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  (t["reglement"]?.toString().isNotEmpty ?? false)
                      ? t["reglement"]
                      : "Aucun règlement intérieur défini pour cette tontine.",
                  style: const TextStyle(color: Colors.black87, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Fermer"),
          ),
          if (membre != null)
            ElevatedButton.icon(
              style:
                  ElevatedButton.styleFrom(backgroundColor: const Color(0xFF00853F)),
              onPressed: () async {
                try {
                  await MemberCardGenerator.shareCard(membre, t);
                } catch (e) {
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Erreur lors de la génération : $e"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.badge),
              label: const Text("Ma carte membre"),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
