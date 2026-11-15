// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import '../../data/shared_data.dart';
import '../../utils/audit_logger.dart';
import '../../utils/receipt_generator.dart';

class PaiementsAdminPage extends StatefulWidget {
  const PaiementsAdminPage({super.key});

  @override
  State<PaiementsAdminPage> createState() => _PaiementsAdminPageState();
}

class _PaiementsAdminPageState extends State<PaiementsAdminPage> {
  final SharedData _data = SharedData();

  String? _tontineSelectionnee;
  String? _membreSelectionne;
  String _searchQuery = "";

  // ✅ NOUVELLE FONCTION : Valider un paiement
  void _validerPaiement(Map<String, dynamic> paiement) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Valider le paiement"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Membre : ${paiement["membreNom"]}"),
            const SizedBox(height: 8),
            Text("Montant : ${paiement["montant"]} FCFA"),
            const SizedBox(height: 8),
            Text("Tontine : ${paiement["tontineNom"]}"),
            const SizedBox(height: 16),
            const Text(
              "Confirmer que ce paiement a bien été reçu ?",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00853F),
            ),
            onPressed: () async {
              // Modifier le statut du paiement
              _data.modifierPaiement(paiement["id"], {"statut": "Payé"});

              // ✅ LOGGING : Validation paiement

              await AuditLogger.logValidationPaiement(
                paiement["membreNom"],
                paiement["montant"],

              );

              setState(() {});
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      "Paiement de ${paiement["membreNom"]} validé avec succès"),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text("Valider"),
          ),
        ],
      ),
    );
  }

  void _afficherDetailsPaiement(Map<String, dynamic> paiement) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[100],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.receipt_long,
                          color: Colors.blue, size: 32),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        "Détails du paiement",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Divider(height: 32),
                _buildDetailRow("Membre", paiement["membreNom"]),
                const SizedBox(height: 12),
                _buildDetailRow("Tontine", paiement["tontineNom"]),
                const SizedBox(height: 12),
                _buildDetailRow("Date", paiement["date"]),
                const SizedBox(height: 12),
                _buildDetailRow(
                  "Transaction ID",
                  "TXN${DateTime.now().millisecondsSinceEpoch}",
                  monospace: true,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Montant",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(
                        "${paiement["montant"]} FCFA",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00853F),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: paiement["statut"] == "Payé"
                        ? Colors.green[100]
                        : Colors.orange[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        paiement["statut"] == "Payé"
                            ? Icons.check_circle
                            : Icons.pending,
                        color: paiement["statut"] == "Payé"
                            ? Colors.green
                            : Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        paiement["statut"].toUpperCase(),
                        style: TextStyle(
                          color: paiement["statut"] == "Payé"
                              ? Colors.green
                              : Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                // ✅ NOUVEAU : Bouton valider si en attente
                if (paiement["statut"] == "En attente") ...[
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context); // Fermer le dialog de détails
                        _validerPaiement(paiement); // Ouvrir dialog de validation
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00853F),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.check_circle),
                      label: const Text("Valider ce paiement"),
                    ),
                  ),
                ],

                if (paiement["statut"] == "Payé") ...[
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            try {
                              await ReceiptGenerator.shareReceipt(paiement);
                            } catch (e) {
                              if (!context.mounted) return;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      "Erreur lors de la génération du reçu : $e"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                          icon: const Icon(Icons.download),
                          label: const Text("Reçu PDF"),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool monospace = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54)),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontFamily: monospace ? 'monospace' : null,
              fontSize: monospace ? 11 : 14,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var paiementsFiltres = _data.paiements.where((p) {
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!p["membreNom"].toLowerCase().contains(query) &&
            !p["tontineNom"].toLowerCase().contains(query)) {
          return false;
        }
      }
      if (_tontineSelectionnee != null &&
          p["tontineId"] != _tontineSelectionnee) {
        return false;
      }
      if (_membreSelectionne != null && p["membreId"] != _membreSelectionne) {
        return false;
      }
      return true;
    }).toList();

    final totalPayes =
        paiementsFiltres.where((p) => p["statut"] == "Payé").length;
    final totalEnAttente =
        paiementsFiltres.where((p) => p["statut"] == "En attente").length;
    final montantTotal = paiementsFiltres
        .where((p) => p["statut"] == "Payé")
        .fold(0, (sum, p) => sum + (p["montant"] as int));

    final nouveauxPaiements =
    paiementsFiltres.where((p) => p["statut"] == "Payé").take(3).toList();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00853F), Color(0xFF006930)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
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
                        const Text(
                          "Gestion des Paiements",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatBadge("Payés", totalPayes, Colors.white),
                            _buildStatBadge("En attente", totalEnAttente,
                                Colors.orange[100]!),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "Total collecté: ${montantTotal.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]} ')} FCFA",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  if (nouveauxPaiements.isNotEmpty) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.notifications_active,
                                  color: Colors.blue),
                              SizedBox(width: 8),
                              Text(
                                "Derniers paiements reçus",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...nouveauxPaiements.map(
                                (p) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  const Icon(Icons.check_circle,
                                      size: 16, color: Colors.green),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "${p["membreNom"]} - ${p["montant"]} FCFA",
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        _afficherDetailsPaiement(p),
                                    child: const Text("Voir",
                                        style: TextStyle(fontSize: 12)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  TextField(
                    decoration: InputDecoration(
                      hintText: "Rechercher par membre ou tontine...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) => setState(() => _searchQuery = value),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String?>(
                          initialValue: _tontineSelectionnee,
                          decoration: InputDecoration(
                            labelText: "Tontine",
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                          items: [
                            const DropdownMenuItem(
                                value: null, child: Text("Toutes")),
                            ..._data.tontines.map<DropdownMenuItem<String?>>(
                                    (t) => DropdownMenuItem<String?>(
                                  value: t["id"] as String?,
                                  child: Text(t["nom"],
                                      overflow: TextOverflow.ellipsis),
                                )),
                          ],
                          onChanged: (val) =>
                              setState(() => _tontineSelectionnee = val),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<String?>(
                          initialValue: _membreSelectionne,
                          decoration: InputDecoration(
                            labelText: "Membre",
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                          items: [
                            const DropdownMenuItem(
                                value: null, child: Text("Tous")),
                            ..._data.membres.map<DropdownMenuItem<String?>>(
                                    (m) => DropdownMenuItem<String?>(
                                  value: m["id"] as String?,
                                  child: Text(m["nom"],
                                      overflow: TextOverflow.ellipsis),
                                )),
                          ],
                          onChanged: (val) =>
                              setState(() => _membreSelectionne = val),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),

            paiementsFiltres.isEmpty
                ? const SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      "Aucun paiement trouvé",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            )
                : SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final p = paiementsFiltres[index];
                  final isPaye = p["statut"] == "Payé";
                  final couleurStatut =
                  isPaye ? Colors.green : Colors.orange;

                  return Card(
                    elevation: 3,
                    margin: EdgeInsets.only(
                      bottom:
                      index == paiementsFiltres.length - 1 ? 16 : 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _afficherDetailsPaiement(p),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor:
                              couleurStatut.withValues(alpha: 0.15),
                              child: Icon(
                                isPaye
                                    ? Icons.check_circle
                                    : Icons.pending,
                                color: couleurStatut,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p["membreNom"],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    p["tontineNom"],
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontSize: 13,
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
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "${p["montant"]} FCFA",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: couleurStatut.withValues(
                                        alpha: 0.1),
                                    borderRadius:
                                    BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    p["statut"],
                                    style: TextStyle(
                                      color: couleurStatut,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.chevron_right,
                                color: Colors.grey),
                          ],
                        ),
                      ),
                    ),
                  );
                },
                childCount: paiementsFiltres.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBadge(String label, int count, Color bgColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00853F),
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF00853F),
            ),
          ),
        ],
      ),
    );
  }
}