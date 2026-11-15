import '../database/database_helper.dart';
import '../utils/password_helper.dart';

/// Classe singleton pour gérer les données avec persistance SQLite
class SharedData {
  static final SharedData _instance = SharedData._internal();
  factory SharedData() => _instance;
  SharedData._internal();

  final DatabaseHelper _db = DatabaseHelper.instance;

  // Cache mémoire (pour la rapidité)
  List<Map<String, dynamic>> tontines = [];
  List<Map<String, dynamic>> membres = [];
  List<Map<String, dynamic>> paiements = [];
  List<Map<String, dynamic>> historiqueTirages = [];

  bool _initialized = false;

  // ============================================================
  // 🚀 INITIALISATION DEPUIS SQLITE
  // ============================================================

  Future<void> init() async {
    if (_initialized) return;

    // Charger depuis SQLite
    tontines = await _db.getTontines();
    membres = await _db.getMembres();
    paiements = await _db.getPaiements();
    historiqueTirages = await _db.getTirages();

    // Si base vide → insérer données par défaut
    if (tontines.isEmpty) {
      await _initialiserDonneesParDefaut();
    }

    _initialized = true;
  }

  // ============================================================
  // 🔧 DONNÉES PAR DÉFAUT
  // ============================================================

  Future<void> _initialiserDonneesParDefaut() async {
    const reglementParDefaut =
        "1. Chaque membre s'engage à verser sa cotisation à la date prévue.\n"
        "2. Tout retard de paiement doit être signalé à l'administrateur.\n"
        "3. Le tirage de la cagnotte est effectué selon l'ordre ou le mode "
        "défini à la création de la tontine (ordre fixe ou tirage au sort).\n"
        "4. En cas de départ ou de décès d'un membre, les cotisations déjà "
        "versées lui sont restituées (ou à ses ayants droit), sauf accord "
        "contraire entre les membres.\n"
        "5. Toute décision importante concernant la tontine doit être "
        "validée collectivement par les membres.\n"
        "6. L'administrateur est responsable de la bonne tenue des comptes "
        "et de la transparence des opérations.";

    // Tontines
    final tontinesDefaut = [
      {
        "id": "t1",
        "nom": "Tontine Étudiantes Dakar",
        "montant": 10000,
        "frequence": "Mensuelle",
        "membres": 15,
        "statut": "Active",
        "dateDebut": "01/01/2025",
        "dateFin": "31/12/2025",
        "montantTotal": 150000,
        "tirageAleatoire": false,
        "description": "Tontine pour les étudiantes de Dakar",
        "reglement": reglementParDefaut,
        "commissionPourcentage": 0.0
      },
      {
        "id": "t2",
        "nom": "Tontine Famille Ndiaye",
        "montant": 5000,
        "frequence": "Hebdomadaire",
        "membres": 8,
        "statut": "Active",
        "dateDebut": "15/01/2025",
        "dateFin": "15/12/2025",
        "montantTotal": 40000,
        "tirageAleatoire": true,
        "description": "Tontine familiale",
        "reglement": reglementParDefaut,
        "commissionPourcentage": 0.0
      },
      {
        "id": "t3",
        "nom": "Tontine Marché Pikine",
        "montant": 20000,
        "frequence": "Mensuelle",
        "membres": 10,
        "statut": "Active",
        "dateDebut": "01/02/2025",
        "dateFin": "31/01/2026",
        "montantTotal": 200000,
        "tirageAleatoire": false,
        "description": "Tontine des commerçants du marché",
        "reglement": reglementParDefaut,
        "commissionPourcentage": 2.0
      },
    ];

    // Membres
    final membresDefaut = [
      {
        "id": "m1",
        "nom": "Awa Diop",
        "email": "awa@example.com",
        "telephone": "77 123 45 67",
        "tontineId": "t1",
        "tontine": "Tontine Étudiantes Dakar",
        "role": "membre",
        "statut": "Actif",
        "password": PasswordHelper.hashPassword("awa123")
      },
      {
        "id": "m2",
        "nom": "Fatou Ndiaye",
        "email": "fatou@example.com",
        "telephone": "77 234 56 78",
        "tontineId": "t1",
        "tontine": "Tontine Étudiantes Dakar",
        "role": "membre",
        "statut": "Actif",
        "password": PasswordHelper.hashPassword("fatou123")
      },
      {
        "id": "m3",
        "nom": "Marieme Sow",
        "email": "marieme@example.com",
        "telephone": "77 345 67 89",
        "tontineId": "t2",
        "tontine": "Tontine Famille Ndiaye",
        "role": "membre",
        "statut": "Actif",
        "password": PasswordHelper.hashPassword("marieme123")
      },
      {
        "id": "m4",
        "nom": "Jean Dupont",
        "email": "jean@example.com",
        "telephone": "77 456 78 90",
        "tontineId": "t3",
        "tontine": "Tontine Marché Pikine",
        "role": "membre",
        "statut": "Actif",
        "password": PasswordHelper.hashPassword("jean123")
      },
      {
        "id": "admin1",
        "nom": "Administrateur",
        "email": "admin@sentontine.sn",
        "telephone": "",
        "tontineId": "",
        "tontine": "",
        "role": "admin",
        "statut": "Actif",
        // ⚠️ Mot de passe par défaut à changer après la première connexion.
        "password": PasswordHelper.hashPassword("admin123")
      },
    ];

    // Paiements
    final paiementsDefaut = [
      {
        "id": "p1",
        "date": "01/11/2025",
        "membreId": "m1",
        "membreNom": "Awa Diop",
        "tontineId": "t1",
        "tontineNom": "Tontine Étudiantes Dakar",
        "montant": 10000,
        "statut": "Payé",
      },
      {
        "id": "p2",
        "date": "05/11/2025",
        "membreId": "m2",
        "membreNom": "Fatou Ndiaye",
        "tontineId": "t1",
        "tontineNom": "Tontine Étudiantes Dakar",
        "montant": 10000,
        "statut": "En attente",
      },
      {
        "id": "p3",
        "date": "10/11/2025",
        "membreId": "m3",
        "membreNom": "Marieme Sow",
        "tontineId": "t2",
        "tontineNom": "Tontine Famille Ndiaye",
        "montant": 5000,
        "statut": "Payé",
      },
    ];

    // Tirages
    final tiragesDefaut = [
      {
        "id": "tir1",
        "date": "15/01/2026",
        "tontineId": "t1",
        "tontineNom": "Tontine Étudiantes Dakar",
        "gagnantId": "m1",
        "gagnantNom": "Awa Diop",
        "montant": 150000,
        "mode": "Aléatoire",
      },
      {
        "id": "tir2",
        "date": "20/12/2025",
        "tontineId": "t2",
        "tontineNom": "Tontine Famille Ndiaye",
        "gagnantId": "m3",
        "gagnantNom": "Marieme Sow",
        "montant": 40000,
        "mode": "Ordre fixe",
      },
    ];

    // Insérer dans SQLite ET dans le cache
    for (var t in tontinesDefaut) {
      await _db.insertTontine(t);
      tontines.add(t);
    }
    for (var m in membresDefaut) {
      await _db.insertMembre(m);
      membres.add(m);
    }
    for (var p in paiementsDefaut) {
      await _db.insertPaiement(p);
      paiements.add(p);
    }
    for (var tir in tiragesDefaut) {
      await _db.insertTirage(tir);
      historiqueTirages.add(tir);
    }
  }

  // ============================================================
  // 🎲 MÉTHODES TIRAGES
  // ============================================================

  void ajouterTirage(Map<String, dynamic> tirage) {
    historiqueTirages.insert(0, tirage);
    _db.insertTirage(tirage);
  }

  List<Map<String, dynamic>> getMesGains(String membreId) {
    return historiqueTirages.where((t) => t['gagnantId'] == membreId).toList();
  }

  /// Retourne les identifiants des membres ayant déjà remporté un tirage
  /// dans une tontine donnée. Permet d'exclure ces membres des tirages
  /// suivants pour cette même tontine, afin que chaque membre ne
  /// bénéficie qu'une seule fois de la cagnotte au cours du cycle.
  List<String> getGagnantsPrecedents(String tontineId) {
    return historiqueTirages
        .where((t) => t['tontineId'] == tontineId)
        .map((t) => t['gagnantId'] as String)
        .toSet()
        .toList();
  }

  bool aGagneRecemment(String membreId) {
    if (historiqueTirages.isEmpty) return false;
    return historiqueTirages.first['gagnantId'] == membreId;
  }

  // ============================================================
  // 💰 MÉTHODES PAIEMENTS
  // ============================================================

  void ajouterPaiement(Map<String, dynamic> paiement) {
    paiements.add(paiement);
    _db.insertPaiement(paiement);
  }

  bool validerPaiement(String paiementId) {
    final index = paiements.indexWhere((p) => p['id'] == paiementId);
    if (index != -1) {
      paiements[index]['statut'] = 'Payé';
      _db.updatePaiement(paiementId, {'statut': 'Payé'});
      return true;
    }
    return false;
  }

  bool declarerPaiement(String paiementId) {
    final index = paiements.indexWhere((p) => p['id'] == paiementId);
    if (index != -1) {
      paiements[index]['statut'] = 'En attente';
      _db.updatePaiement(paiementId, {'statut': 'En attente'});
      return true;
    }
    return false;
  }

  List<Map<String, dynamic>> getPaiementsMembre(String membreId) {
    return paiements.where((p) => p['membreId'] == membreId).toList();
  }

  /// Calcule le total déjà cotisé (paiements "Payé") par un membre,
  /// toutes tontines confondues ou pour une tontine précise si
  /// [tontineId] est fourni.
  int calculerTotalCotiseMembre(String membreId, {String? tontineId}) {
    return paiements
        .where((p) =>
            p['membreId'] == membreId &&
            p['statut'] == 'Payé' &&
            (tontineId == null || p['tontineId'] == tontineId))
        .fold<int>(0, (total, p) => total + ((p['montant'] as num?)?.toInt() ?? 0));
  }

  /// Enregistre la sortie d'un membre (retrait volontaire ou décès) et le
  /// montant qui doit lui être restitué (ou à ses ayants droit). Le statut
  /// du membre passe à "Inactif" pour qu'il n'apparaisse plus comme membre
  /// actif de la tontine, sans pour autant supprimer son historique. La
  /// place ainsi libérée peut faire repasser une tontine "Complète" à
  /// "Active".
  Future<bool> enregistrerSortieMembre({
    required String membreId,
    required String typeSortie, // "Retrait" ou "Décès"
    required String dateSortie,
    required int montantARembourser,
    bool dejaRembourse = false,
  }) async {
    final index = membres.indexWhere((m) => m['id'] == membreId);
    if (index == -1) return false;

    final tontineId = membres[index]['tontineId'];

    final nouvelleDonnees = <String, dynamic>{
      "statut": "Inactif",
      "typeSortie": typeSortie,
      "dateSortie": dateSortie,
      "montantRembourse": montantARembourser,
      "rembourse": dejaRembourse,
    };

    membres[index] = {...membres[index], ...nouvelleDonnees};
    await _db.updateMembre(membreId, nouvelleDonnees);

    if (tontineId != null && tontineId.toString().isNotEmpty) {
      await verifierEtMettreAJourStatutTontine(tontineId);
    }
    return true;
  }

  /// Marque le remboursement d'un membre déjà sorti comme effectué.
  bool marquerRembourse(String membreId) {
    final index = membres.indexWhere((m) => m['id'] == membreId);
    if (index == -1) return false;

    membres[index]["rembourse"] = true;
    _db.updateMembre(membreId, {"rembourse": true});
    return true;
  }

  List<Map<String, dynamic>> getPaiementsTontine(String tontineId) {
    return paiements.where((p) => p['tontineId'] == tontineId).toList();
  }

  List<Map<String, dynamic>> getPaiementsEnAttente() {
    return paiements.where((p) => p['statut'] == 'En attente').toList();
  }

  // ✅ NOUVELLE MÉTHODE : Modifier un paiement (pour validation admin)
  bool modifierPaiement(String paiementId, Map<String, dynamic> nouvelleDonnees) {
    final index = paiements.indexWhere((p) => p['id'] == paiementId);
    if (index != -1) {
      paiements[index] = {...paiements[index], ...nouvelleDonnees};
      _db.updatePaiement(paiementId, nouvelleDonnees);
      return true;
    }
    return false;
  }

  // ============================================================
  // 👥 MÉTHODES MEMBRES
  // ============================================================

  void ajouterMembre(Map<String, dynamic> membre) {
    // Sécurité : on ne stocke jamais un mot de passe en clair.
    if (membre.containsKey("password") && membre["password"] != null) {
      membre["password"] = PasswordHelper.hashPassword(membre["password"]);
    }
    membres.add(membre);
    _db.insertMembre(membre);
  }

  Map<String, dynamic>? getMembre(String membreId) {
    try {
      return membres.firstWhere((m) => m['id'] == membreId);
    } catch (e) {
      return null;
    }
  }

  bool modifierMembre(String membreId, Map<String, dynamic> nouvelleDonnees) {
    final index = membres.indexWhere((m) => m['id'] == membreId);
    if (index != -1) {
      // Sécurité : si le champ "password" contient un nouveau mot de passe
      // en clair (et non le hash déjà stocké), on le hache avant sauvegarde.
      if (nouvelleDonnees.containsKey("password") &&
          nouvelleDonnees["password"] != null &&
          nouvelleDonnees["password"] != membres[index]["password"]) {
        nouvelleDonnees["password"] =
            PasswordHelper.hashPassword(nouvelleDonnees["password"]);
      }
      membres[index] = {...membres[index], ...nouvelleDonnees};
      _db.updateMembre(membreId, nouvelleDonnees);
      return true;
    }
    return false;
  }

  /// Compte le nombre de membres actuellement actifs et rattachés à une
  /// tontine donnée (statut "Actif" et tontineId correspondant).
  int compterMembresActifsTontine(String tontineId) {
    return membres
        .where((m) =>
            m['tontineId'] == tontineId &&
            m['statut'] == 'Actif' &&
            m['role'] == 'membre')
        .length;
  }

  /// Vérifie si une tontine a atteint son nombre cible de membres et, si
  /// c'est le cas, passe automatiquement son statut à "Complète" (elle ne
  /// peut alors plus recevoir de nouveaux membres). À l'inverse, si une
  /// place se libère (retrait/décès) sur une tontine "Complète", elle
  /// repasse automatiquement à "Active".
  Future<void> verifierEtMettreAJourStatutTontine(String tontineId) async {
    final index = tontines.indexWhere((t) => t['id'] == tontineId);
    if (index == -1) return;

    final tontine = tontines[index];
    final cible = (tontine['membres'] as num?)?.toInt() ?? 0;
    final actifs = compterMembresActifsTontine(tontineId);

    String? nouveauStatut;
    if (actifs >= cible && cible > 0 && tontine['statut'] == 'Active') {
      nouveauStatut = 'Complète';
    } else if (actifs < cible && tontine['statut'] == 'Complète') {
      nouveauStatut = 'Active';
    }

    if (nouveauStatut != null) {
      tontines[index]['statut'] = nouveauStatut;
      await _db.updateTontine(tontineId, tontines[index]);
    }
  }

  /// Vérifie si un membre peut être supprimé sans casser la traçabilité.
  /// Retourne null si la suppression est possible, sinon un message
  /// expliquant pourquoi elle est bloquée.
  String? verifierSuppressionMembre(String membreId) {
    final aDesPaiements = paiements.any((p) => p['membreId'] == membreId);
    final aDesGains =
        historiqueTirages.any((t) => t['gagnantId'] == membreId);

    if (aDesPaiements || aDesGains) {
      return "Ce membre a un historique de paiements et/ou de gains "
          "enregistré dans l'application. Le supprimer casserait la "
          "traçabilité des opérations. Utilisez plutôt l'option "
          "\"Retrait / Décès\" pour le marquer comme sorti tout en "
          "conservant son historique.";
    }
    return null;
  }

  bool supprimerMembre(String membreId) {
    if (verifierSuppressionMembre(membreId) != null) {
      return false;
    }
    final index = membres.indexWhere((m) => m['id'] == membreId);
    if (index != -1) {
      membres.removeAt(index);
      _db.deleteMembre(membreId);
      return true;
    }
    return false;
  }

  // ============================================================
  // 🏦 MÉTHODES TONTINES
  // ============================================================

  void ajouterTontine(Map<String, dynamic> tontine) {
    tontines.add(tontine);
    _db.insertTontine(tontine);
  }

  Map<String, dynamic>? getTontine(String tontineId) {
    try {
      return tontines.firstWhere((t) => t['id'] == tontineId);
    } catch (e) {
      return null;
    }
  }

  bool modifierTontine(String tontineId, Map<String, dynamic> nouvelleDonnees) {
    final index = tontines.indexWhere((t) => t['id'] == tontineId);
    if (index != -1) {
      tontines[index] = {...tontines[index], ...nouvelleDonnees};
      _db.updateTontine(tontineId, tontines[index]);
      return true;
    }
    return false;
  }

  /// Vérifie si une tontine peut être supprimée sans casser la
  /// traçabilité. Retourne null si la suppression est possible, sinon un
  /// message expliquant pourquoi elle est bloquée.
  String? verifierSuppressionTontine(String tontineId) {
    final aDesMembres = membres.any((m) => m['tontineId'] == tontineId);
    final aDesPaiements = paiements.any((p) => p['tontineId'] == tontineId);
    final aDesTirages =
        historiqueTirages.any((t) => t['tontineId'] == tontineId);

    if (aDesMembres || aDesPaiements || aDesTirages) {
      return "Cette tontine a des membres et/ou un historique de "
          "paiements/tirages enregistrés. La supprimer casserait la "
          "traçabilité des opérations. Vous pouvez plutôt la marquer "
          "comme \"Terminée\" pour la clôturer tout en conservant son "
          "historique.";
    }
    return null;
  }

  bool supprimerTontine(String tontineId) {
    if (verifierSuppressionTontine(tontineId) != null) {
      return false;
    }
    final index = tontines.indexWhere((t) => t['id'] == tontineId);
    if (index != -1) {
      tontines.removeAt(index);
      _db.deleteTontine(tontineId);
      return true;
    }
    return false;
  }

  // ============================================================
  // 📊 STATISTIQUES
  // ============================================================

  int getTontinesActives() {
    return tontines
        .where((t) => t['statut'] == 'Active' || t['statut'] == 'Complète')
        .length;
  }

  int getTotalMembres() {
    return membres.length;
  }

  int getTotalCotisations() {
    return paiements
        .where((p) => p['statut'] == 'Payé')
        .fold(0, (sum, p) => sum + (p['montant'] as int));
  }

  /// Calcule le total des commissions perçues par l'administrateur sur
  /// tous les tirages déjà effectués (montant figé au moment de chaque
  /// tirage, donc fiable même si le taux de commission a changé depuis).
  int getTotalCommissions() {
    return historiqueTirages.fold<int>(
        0, (sum, t) => sum + ((t['commission'] as num?)?.toInt() ?? 0));
  }

  int getPaiementsEnAttenteCount() {
    return paiements.where((p) => p['statut'] == 'En attente').length;
  }

  // ============================================================
  // 🔧 UTILITAIRES
  // ============================================================

  String genererIdUnique(String prefix) {
    return '${prefix}_${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> reinitialiser() async {
    await _db.clearAllTables();
    tontines.clear();
    membres.clear();
    paiements.clear();
    historiqueTirages.clear();
    _initialized = false;
    await init();
  }
}