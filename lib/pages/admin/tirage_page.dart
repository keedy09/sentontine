import 'package:flutter/material.dart';
import 'dart:math';
import '../../data/shared_data.dart';
import '../../utils/audit_logger.dart';

class TiragePage extends StatefulWidget {
  const TiragePage({super.key});

  @override
  State<TiragePage> createState() => _TiragePageState();
}

class _TiragePageState extends State<TiragePage> {
  final SharedData _data = SharedData();
  String? _tontineSelectionnee;
  Map<String, dynamic>? _gagnant;
  bool _tirageEnCours = false;
  List<String> _membresEligibles = [];

  // Liste pour stocker l'historique des tirages
  List<Map<String, dynamic>> _historiqueTirages = [];

  @override
  void initState() {
    super.initState();
    _chargerHistorique();
  }

  // Charger l'historique des tirages
  void _chargerHistorique() {
    // Pour l'instant, on simule avec des données en mémoire
    // Dans une vraie app, on chargerait depuis SQLite
    setState(() {
      _historiqueTirages = _data.historiqueTirages;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          // Contenu principal avec tirage
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête
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
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.casino, color: Colors.white, size: 32),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                "Tirage de la Cagnotte",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Déterminez qui reçoit la cagnotte ce mois-ci",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Sélection de tontine
                  const Text(
                    "Sélectionner une tontine",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String?>(
                    initialValue: _tontineSelectionnee,
                    decoration: InputDecoration(
                      labelText: "Tontine",
                      prefixIcon: const Icon(Icons.group_work),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: _data.tontines
                        .where((t) =>
                            t['statut'] == 'Active' || t['statut'] == 'Complète')
                        .map<DropdownMenuItem<String?>>(
                            (t) => DropdownMenuItem<String?>(
                                  value: t['id'] as String?,
                                  child: Text(t['nom'] as String),
                                ))
                        .toList(),
                    onChanged: (val) {
                      setState(() {
                        _tontineSelectionnee = val;
                        _gagnant = null;
                        _membresEligibles = [];
                      });
                    },
                  ),

                  const SizedBox(height: 24),

                  // Bouton de tirage
                  if (_tontineSelectionnee != null &&
                      !_tirageEnCours &&
                      _gagnant == null)
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: _effectuerTirage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE30B17),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 8,
                        ),
                        icon: const Icon(Icons.casino, size: 28),
                        label: const Text(
                          "Effectuer le tirage",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  // Animation de tirage
                  if (_tirageEnCours)
                    const SizedBox(
                      height: 200,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 100,
                              height: 100,
                              child: CircularProgressIndicator(
                                color: Color(0xFF00853F),
                                strokeWidth: 8,
                              ),
                            ),
                            SizedBox(height: 24),
                            Text(
                              "Tirage en cours...",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Résultat du tirage
                  if (_gagnant != null) _buildResultatTirage(),

                  // Historique des tirages (toujours visible en bas)
                  const SizedBox(height: 30),
                  _buildHistoriqueTirages(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget pour le résultat du tirage
  Widget _buildResultatTirage() {
    return Column(
      children: [
        const SizedBox(height: 24),

        // Animation de confettis
        const Icon(
          Icons.celebration,
          size: 80,
          color: Color(0xFFE30B17),
        ),

        const SizedBox(height: 24),

        const Text(
          "🎉 GAGNANT 🎉",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Color(0xFF00853F),
          ),
        ),

        const SizedBox(height: 24),

        // Carte du gagnant
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.yellow[100]!,
                Colors.orange[100]!,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: const Color(0xFF00853F),
                child: Text(
                  _gagnant!['nom'][0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                _gagnant!['nom'],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                _gagnant!['email'],
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF00853F),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "Reçoit ${_calculerMontantNet(_getTontine()!)} FCFA",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if ((_getTontine()!['commissionPourcentage'] ?? 0.0) > 0) ...[
                const SizedBox(height: 8),
                Text(
                  "Cagnotte totale : ${_getTontine()!['montantTotal']} FCFA "
                  "— Commission (${_getTontine()!['commissionPourcentage']}%) : "
                  "${_calculerCommission(_getTontine()!)} FCFA",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Informations complémentaires
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Détails du tirage",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Divider(height: 24),
              _buildInfoRow("Tontine", _getTontine()!['nom']),
              const SizedBox(height: 8),
              _buildInfoRow("Date",
                  "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}"),
              const SizedBox(height: 8),
              _buildInfoRow(
                  "Mode",
                  _getTontine()!['tirageAleatoire']
                      ? "Aléatoire"
                      : "Ordre fixe"),
              const SizedBox(height: 8),
              _buildInfoRow(
                  "Participants", "${_membresEligibles.length} membres"),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // Boutons d'action
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _gagnant = null;
                    _membresEligibles = [];
                  });
                },
                icon: const Icon(Icons.refresh),
                label: const Text("Nouveau tirage"),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _enregistrerResultat,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00853F),
                ),
                icon: const Icon(Icons.check),
                label: const Text("Enregistrer"),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Widget pour l'historique des tirages
  Widget _buildHistoriqueTirages() {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.history, color: Color(0xFF00853F)),
              SizedBox(width: 12),
              Text(
                "Historique des tirages",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_historiqueTirages.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Center(
                child: Text(
                  "Aucun tirage effectué pour le moment",
                  style: TextStyle(color: Colors.black45),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _historiqueTirages.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final tirage = _historiqueTirages[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        const Color(0xFF00853F).withValues(alpha: 0.1),
                    child: const Icon(Icons.emoji_events,
                        color: Color(0xFF00853F)),
                  ),
                  title: Text(
                    tirage['gagnantNom'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    "${tirage['tontineNom']} • ${tirage['date']}",
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Text(
                    "${tirage['montant']} FCFA",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF00853F),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // Récupérer la tontine sélectionnée
  Map<String, dynamic>? _getTontine() {
    if (_tontineSelectionnee == null) return null;
    return _data.getTontine(_tontineSelectionnee!);
  }

  // Calculer le montant de la commission administrateur sur une cagnotte
  int _calculerCommission(Map<String, dynamic> tontine) {
    final pourcentage =
        (tontine['commissionPourcentage'] as num?)?.toDouble() ?? 0.0;
    final montantTotal = (tontine['montantTotal'] as num?)?.toInt() ?? 0;
    return (montantTotal * pourcentage / 100).round();
  }

  // Calculer le montant net reçu par le gagnant après commission
  int _calculerMontantNet(Map<String, dynamic> tontine) {
    final montantTotal = (tontine['montantTotal'] as num?)?.toInt() ?? 0;
    return montantTotal - _calculerCommission(tontine);
  }

  // Effectuer le tirage
  Future<void> _effectuerTirage() async {
    final tontine = _getTontine();
    if (tontine == null) return;

    setState(() {
      _tirageEnCours = true;
    });

    // Récupérer les membres de cette tontine, en excluant ceux ayant déjà
    // remporté un tirage dans cette même tontine.
    final gagnantsPrecedents =
        _data.getGagnantsPrecedents(_tontineSelectionnee!);

    _membresEligibles = _data.membres
        .where((m) =>
            m['tontineId'] == _tontineSelectionnee &&
            m['statut'] == 'Actif' &&
            !gagnantsPrecedents.contains(m['id']))
        .map((m) => m['id'] as String)
        .toList();

    if (_membresEligibles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "Tous les membres actifs de cette tontine ont déjà bénéficié d'un tirage."),
          backgroundColor: Colors.orange,
        ),
      );
      setState(() {
        _tirageEnCours = false;
      });
      return;
    }

    // Animation (3 secondes)
    await Future.delayed(const Duration(seconds: 3));

    // Sélectionner le gagnant
    String gagnantId;

    if (tontine['tirageAleatoire'] == true) {
      // Mode aléatoire
      final random = Random();
      gagnantId = _membresEligibles[random.nextInt(_membresEligibles.length)];
    } else {
      // Mode ordre fixe
      gagnantId = _membresEligibles[0];
    }

    final membreGagnant = _data.getMembre(gagnantId);

    setState(() {
      _gagnant = membreGagnant;
      _tirageEnCours = false;
    });
  }

  // Enregistrer le résultat
  Future<void> _enregistrerResultat() async {
    if (_gagnant == null || _tontineSelectionnee == null) return;

    final tontine = _getTontine()!;

    // Créer l'enregistrement du tirage
    final commission = _calculerCommission(tontine);
    final tirage = {
      'id': _data.genererIdUnique('tir'),
      'date':
          "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
      'tontineId': _tontineSelectionnee,
      'tontineNom': tontine['nom'],
      'gagnantId': _gagnant!['id'],
      'gagnantNom': _gagnant!['nom'],
      'montant': tontine['montantTotal'],
      'commission': commission,
      'mode': tontine['tirageAleatoire'] ? 'Aléatoire' : 'Ordre fixe',
    };

    // Ajouter à l'historique
    _data.ajouterTirage(tirage);
    await AuditLogger.logTirage(
      tontine['nom'],
      _gagnant!['nom'],
      tontine['montantTotal'],
      tontine['tirageAleatoire'] ? "Aléatoire" : "Ordre fixe",
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${_gagnant!['nom']} enregistré comme bénéficiaire"),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );

    // Réinitialiser et recharger
    setState(() {
      _gagnant = null;
      _tontineSelectionnee = null;
      _membresEligibles = [];
      _chargerHistorique();
    });
  }

  // Widget pour afficher une ligne d'information
  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
