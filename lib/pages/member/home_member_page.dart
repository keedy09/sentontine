import 'package:flutter/material.dart';
import '../../data/shared_data.dart';

class HomeMemberPage extends StatefulWidget {
  final String? membreId;

  const HomeMemberPage({super.key, this.membreId});

  @override
  State<HomeMemberPage> createState() => _HomeMemberPageState();
}

class _HomeMemberPageState extends State<HomeMemberPage> {
  final SharedData data = SharedData();

  @override
  Widget build(BuildContext context) {
    // Récupérer les infos du membre
    Map<String, dynamic>? membre;
    if (widget.membreId != null) {
      try {
        membre = data.membres.firstWhere((m) => m["id"] == widget.membreId);
      } catch (e) {
        membre = null;
      }
    }

    // ✅ STATISTIQUES RÉELLES DU MEMBRE
    final mesPaiementsPayes = data.paiements
        .where((p) => p["membreId"] == widget.membreId && p["statut"] == "Payé")
        .length;

    final mesPaiementsEnAttente = data.paiements
        .where((p) =>
    p["membreId"] == widget.membreId && p["statut"] == "En attente")
        .length;

    final monTotalCotise = data.paiements
        .where((p) => p["membreId"] == widget.membreId && p["statut"] == "Payé")
        .fold(0, (sum, p) => sum + (p["montant"] as int));

    final mesGainsCount = data.getMesGains(widget.membreId ?? "").length;

    final maTontine = membre?['tontineId'] != null
        ? data.tontines
        .where((t) => t['id'] == membre?['tontineId'])
        .toList()
        : <Map<String, dynamic>>[];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête de bienvenue
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF00853F), Color(0xFF005C2E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.groups, color: Colors.white, size: 32),
                      SizedBox(width: 12),
                      Text(
                        "SenTontine",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Bienvenue, ${membre?["nom"] ?? "Membre"}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    membre?['tontine'] ?? "Aucune tontine assignée",
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ✅ Notification de gain (si gagné récemment)
            if (widget.membreId != null &&
                data.aGagneRecemment(widget.membreId!))
              _buildNotificationGain(),

            const SizedBox(height: 24),

            // Tableau de bord
            const Text(
              "Mon tableau de bord",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // ✅ STATS RÉELLES DU MEMBRE (4 cartes)
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStatCard(
                  "Paiements Payés",
                  mesPaiementsPayes.toString(),
                  Icons.check_circle,
                  Colors.green,
                ),
                _buildStatCard(
                  "En Attente",
                  mesPaiementsEnAttente.toString(),
                  Icons.schedule,
                  Colors.orange,
                ),
                _buildStatCard(
                  "Total Cotisé",
                  "${monTotalCotise.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} F",
                  Icons.attach_money,
                  Colors.blue,
                ),
                _buildStatCard(
                  "Mes Gains",
                  mesGainsCount.toString(),
                  Icons.emoji_events,
                  Colors.amber,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ✅ MA TONTINE (seulement celle du membre)
            const Text(
              "Ma tontine",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            if (maTontine.isNotEmpty)
              ...maTontine.map((t) => _buildTontineCard(t))
            else
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange[700]),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Vous n'êtes pas encore affecté à une tontine. Contactez l'administrateur.",
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),

            // ✅ MES DERNIERS PAIEMENTS
            const Text(
              "Mes derniers paiements",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: data.paiements
                  .where((p) => p["membreId"] == widget.membreId)
                  .isEmpty
                  ? const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    "Aucun paiement enregistré",
                    style: TextStyle(color: Colors.black45),
                  ),
                ),
              )
                  : Column(
                children: data.paiements
                    .where((p) => p["membreId"] == widget.membreId)
                    .take(5)
                    .map((p) => Padding(
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
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              p["tontineNom"],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              "${p["montant"]} FCFA",
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.end,
                        children: [
                          Text(
                            p["date"],
                            style: const TextStyle(
                              color: Colors.black45,
                              fontSize: 12,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: p["statut"] == "Payé"
                                  ? Colors.green.withValues(
                                  alpha: 0.1)
                                  : Colors.orange.withValues(
                                  alpha: 0.1),
                              borderRadius:
                              BorderRadius.circular(8),
                            ),
                            child: Text(
                              p["statut"],
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: p["statut"] == "Payé"
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ))
                    .toList(),
              ),
            ),

            const SizedBox(height: 24),

            // Infos utiles
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info, color: Colors.blue[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Assurez-vous de respecter les dates de paiement pour éviter des pénalités.",
                      style: TextStyle(
                        color: Colors.blue[900],
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title,
      String value,
      IconData icon,
      Color color,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTontineCard(Map<String, dynamic> tontine) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.savings, color: Colors.green),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tontine["nom"],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        "Fréquence: ${tontine["frequence"]}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              tontine["description"],
              style: const TextStyle(fontSize: 13, color: Colors.black87),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Cotisation: ${tontine["montant"]} FCFA",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    tontine["statut"],
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationGain() {
    final mesGains = data.getMesGains(widget.membreId ?? "");
    if (mesGains.isEmpty) return const SizedBox.shrink();

    final dernierGain = mesGains.first;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.yellow[100]!, Colors.orange[100]!],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.3),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(Icons.emoji_events, size: 60, color: Color(0xFFE30B17)),
          const SizedBox(height: 12),
          const Text(
            "🎉 FÉLICITATIONS ! 🎉",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            "Vous avez gagné le tirage !",
            style: TextStyle(fontSize: 16, color: Colors.orange[900]),
          ),
          const SizedBox(height: 8),
          Text(
            "${dernierGain["montant"].toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} FCFA",
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE30B17),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Tontine: ${dernierGain["tontineNom"]}",
            style: const TextStyle(color: Colors.black54, fontSize: 13),
          ),
          Text(
            "Le ${dernierGain["date"]}",
            style: const TextStyle(color: Colors.black45, fontSize: 12),
          ),
        ],
      ),
    );
  }
}