import 'package:flutter/material.dart';
import '../../data/shared_data.dart';
import '../../widgets/stripe_payment_simulation.dart';
import '../../utils/receipt_generator.dart';

class PaiementsPage extends StatefulWidget {
  final String? membreId;

  const PaiementsPage({super.key, this.membreId});

  @override
  State<PaiementsPage> createState() => _PaiementsPageState();
}

class _PaiementsPageState extends State<PaiementsPage> {
  final SharedData data = SharedData();

  // Ouvrir l'interface de paiement Stripe (simulation)
  void _ouvrirPaiementStripe(Map<String, dynamic> paiement) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StripePaymentSimulation(
        paiement: paiement,
        onPaymentSuccess: () {
          // Fermer le dialog
          Navigator.pop(context);

          // Marquer le paiement comme payé directement
          final success = data.validerPaiement(paiement['id']);

          if (success) {
            setState(() {});

            // Afficher un message de succès
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Paiement effectué avec succès !\nL'admin a été notifié.",
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 4),
                behavior: SnackBarBehavior.floating,
                action: SnackBarAction(
                  label: "Voir le reçu",
                  textColor: Colors.white,
                  onPressed: () {
                    _afficherRecu(paiement);
                  },
                ),
              ),
            );
          }
        },
        onPaymentCancel: () {
          Navigator.pop(context);

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Paiement annulé"),
              backgroundColor: Colors.orange,
            ),
          );
        },
      ),
    );
  }

  // Créer un nouveau paiement (bouton "Faire un paiement")
  void _creerNouveauPaiement() {
    // Récupérer le membre connecté
    if (widget.membreId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erreur : Membre non identifié"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final membre = data.getMembre(widget.membreId!);
    if (membre == null ||
        membre['tontineId'] == null ||
        membre['tontineId'].isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vous n'êtes affecté à aucune tontine"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final tontine = data.getTontine(membre['tontineId']);
    if (tontine == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Erreur : Tontine introuvable"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Afficher le dialog de sélection de mois
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.payment,
                      color: Colors.blue,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      "Nouveau paiement",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Informations de la tontine
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.group_work, color: Color(0xFF00853F)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            tontine['nom'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Cotisation :"),
                        Text(
                          "${tontine['montant']} FCFA",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00853F),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Fréquence :"),
                        Text(
                          tontine['frequence'],
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Message d'information
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 20, color: Colors.blue[700]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "Vous allez effectuer un paiement de ${tontine['montant']} FCFA",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue[900],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Boutons d'action
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Annuler"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _confirmerNouveauPaiement(membre, tontine);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00853F),
                      ),
                      icon: const Icon(Icons.payment),
                      label: const Text("Continuer"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Confirmer et créer le paiement
  void _confirmerNouveauPaiement(
      Map<String, dynamic> membre, Map<String, dynamic> tontine) {
    // Créer le nouveau paiement
    final nouveauPaiement = {
      "id": data.genererIdUnique("p"),
      "date":
          "${DateTime.now().day.toString().padLeft(2, '0')}/${DateTime.now().month.toString().padLeft(2, '0')}/${DateTime.now().year}",
      "membreId": membre['id'],
      "membreNom": membre['nom'],
      "tontineId": tontine['id'],
      "tontineNom": tontine['nom'],
      "montant": tontine['montant'],
      "statut":
          "À payer", // Le paiement sera "À payer" jusqu'à ce qu'il paie via Stripe
    };

    // Ajouter le paiement aux données
    data.ajouterPaiement(nouveauPaiement);

    // Rafraîchir l'interface
    setState(() {});

    // Ouvrir automatiquement l'interface de paiement Stripe
    Future.delayed(const Duration(milliseconds: 300), () {
      _ouvrirPaiementStripe(nouveauPaiement);
    });
  }

  // Afficher le reçu de paiement
  void _afficherRecu(Map<String, dynamic> paiement) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(24),
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // En-tête
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.receipt_long,
                        color: Color(0xFF00853F),
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        "Reçu de paiement",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),

                const Divider(height: 32),

                // Logo SenTontine
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.groups, color: Color(0xFF00853F), size: 32),
                      SizedBox(width: 12),
                      Text(
                        "SenTontine",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00853F),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Détails du paiement
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      _buildRecuLine("Tontine", paiement["tontineNom"]),
                      const Divider(height: 24),
                      _buildRecuLine("Membre", paiement["membreNom"]),
                      const Divider(height: 24),
                      _buildRecuLine("Date", paiement["date"]),
                      const Divider(height: 24),
                      _buildRecuLine(
                        "Transaction ID",
                        "TXN${DateTime.now().millisecondsSinceEpoch}",
                        monospace: true,
                      ),
                      const Divider(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Montant",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
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
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Statut
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 20),
                      SizedBox(width: 8),
                      Text(
                        "PAYÉ",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Text(
                  "Merci d'utiliser SenTontine",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),

                const SizedBox(height: 16),

                SizedBox(
                  width: double.infinity,
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
                    label: const Text("Télécharger le reçu PDF"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecuLine(String label, String value, {bool monospace = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.black54),
        ),
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
    final List<Map<String, dynamic>> paiements = widget.membreId != null
        ? data.getPaiementsMembre(widget.membreId!)
        : data.paiements;

    final paiementsPayes =
        paiements.where((p) => p["statut"] == "Payé").toList();
    final paiementsEnAttente =
        paiements.where((p) => p["statut"] == "En attente").toList();
    final paiementsAPayer = paiements
        .where((p) => p["statut"] != "Payé" && p["statut"] != "En attente")
        .toList();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Mes paiements",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF00853F),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Gérez vos cotisations en toute simplicité",
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 20),

            // Indicateurs rapides
            Row(
              children: [
                _buildStatCard("Payés", paiementsPayes.length, Colors.green),
                const SizedBox(width: 10),
                _buildStatCard(
                    "En attente", paiementsEnAttente.length, Colors.orange),
                const SizedBox(width: 10),
                _buildStatCard("À payer", paiementsAPayer.length, Colors.red),
              ],
            ),

            const SizedBox(height: 20),

            // Actions rapides
            const Text(
              "Actions rapides",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildActionButton(
                    Icons.payment,
                    "Faire un paiement",
                    Colors.blue,
                    _creerNouveauPaiement, // Appel de la fonction
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Liste des paiements
            Expanded(
              child: ListView(
                children: [
                  // Section "À payer"
                  if (paiementsAPayer.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        "Cotisations à payer",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                    ...paiementsAPayer
                        .map((p) => _buildPaiementCard(p, peutPayer: true)),
                  ],

                  // Section "En attente"
                  if (paiementsEnAttente.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        "En cours de traitement",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                    ...paiementsEnAttente
                        .map((p) => _buildPaiementCard(p, peutPayer: false)),
                  ],

                  // Section "Payés"
                  if (paiementsPayes.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        "Historique des paiements",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ),
                    ...paiementsPayes
                        .map((p) => _buildPaiementCard(p, peutPayer: false)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Carte de statistique
  Widget _buildStatCard(String titre, int nombre, Color couleur) {
    return Expanded(
      child: Card(
        color: couleur.withValues(alpha: 0.1),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(
                nombre.toString(),
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: couleur,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                titre,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: couleur,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Carte de paiement
  Widget _buildPaiementCard(Map<String, dynamic> p, {required bool peutPayer}) {
    Color couleurStatut;
    if (p["statut"] == "Payé") {
      couleurStatut = Colors.green;
    } else if (p["statut"] == "En attente") {
      couleurStatut = Colors.orange;
    } else {
      couleurStatut = Colors.red;
    }

    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: p["statut"] == "Payé" ? () => _afficherRecu(p) : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: couleurStatut.withValues(alpha: 0.15),
                    child: Icon(Icons.payments, color: couleurStatut),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p["tontineNom"],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          "Date : ${p["date"]}",
                          style: const TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (p["statut"] == "Payé")
                    IconButton(
                      onPressed: () => _afficherRecu(p),
                      icon: const Icon(Icons.receipt_long),
                      tooltip: "Voir le reçu",
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Montant
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${p["montant"]} FCFA",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (peutPayer)
                    ElevatedButton.icon(
                      onPressed: () => _ouvrirPaiementStripe(p),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF635BFF),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      icon: const Icon(Icons.payment, size: 20),
                      label: const Text(
                        "Payer",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: couleurStatut.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: couleurStatut),
                      ),
                      child: Text(
                        p["statut"],
                        style: TextStyle(
                          color: couleurStatut,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
      IconData icon, String label, Color color, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Icon(icon, color: color, size: 28),
                const SizedBox(height: 8),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
