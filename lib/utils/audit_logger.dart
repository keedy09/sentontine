import '../database/database_helper.dart';

/// Helper pour logger automatiquement les actions admin
class AuditLogger {
  static final DatabaseHelper _db = DatabaseHelper.instance;

  // Admin par défaut (à remplacer par l'admin connecté)
  static String currentAdminId = "admin";
  static String currentAdminNom = "Administrateur";

  /// Logger la création d'une tontine
  static Future<void> logCreationTontine(String tontineNom) async {
    await _db.logAction(
      adminId: currentAdminId,
      adminNom: currentAdminNom,
      action: "Créé la tontine \"$tontineNom\"",
      typeAction: "Tontine",
      cibleNom: tontineNom,
    );
  }

  /// Logger la modification d'une tontine
  static Future<void> logModificationTontine(String tontineNom) async {
    await _db.logAction(
      adminId: currentAdminId,
      adminNom: currentAdminNom,
      action: "Modifié la tontine \"$tontineNom\"",
      typeAction: "Tontine",
      cibleNom: tontineNom,
    );
  }

  /// Logger la suppression d'une tontine
  static Future<void> logSuppressionTontine(String tontineNom) async {
    await _db.logAction(
      adminId: currentAdminId,
      adminNom: currentAdminNom,
      action: "Supprimé la tontine \"$tontineNom\"",
      typeAction: "Tontine",
      cibleNom: tontineNom,
    );
  }

  /// Logger l'ajout d'un membre
  static Future<void> logAjoutMembre(String membreNom, String role) async {
    await _db.logAction(
      adminId: currentAdminId,
      adminNom: currentAdminNom,
      action: "Ajouté le $role \"$membreNom\"",
      typeAction: "Membre",
      cibleNom: membreNom,
      details: "Rôle : $role",
    );
  }

  /// Logger la modification d'un membre
  static Future<void> logModificationMembre(String membreNom) async {
    await _db.logAction(
      adminId: currentAdminId,
      adminNom: currentAdminNom,
      action: "Modifié le membre \"$membreNom\"",
      typeAction: "Membre",
      cibleNom: membreNom,
    );
  }

  /// Logger la suppression d'un membre
  static Future<void> logSuppressionMembre(String membreNom) async {
    await _db.logAction(
      adminId: currentAdminId,
      adminNom: currentAdminNom,
      action: "Supprimé le membre \"$membreNom\"",
      typeAction: "Membre",
      cibleNom: membreNom,
    );
  }

  /// Logger l'affectation d'un membre à une tontine
  static Future<void> logAffectationMembre(String membreNom, String tontineNom) async {
    await _db.logAction(
      adminId: currentAdminId,
      adminNom: currentAdminNom,
      action: "Affecté \"$membreNom\" à la tontine \"$tontineNom\"",
      typeAction: "Membre",
      cibleNom: membreNom,
      details: "Tontine : $tontineNom",
    );
  }

  /// Logger la validation d'un paiement
  static Future<void> logValidationPaiement(String membreNom, int montant) async {
    await _db.logAction(
      adminId: currentAdminId,
      adminNom: currentAdminNom,
      action: "Validé le paiement de \"$membreNom\"",
      typeAction: "Paiement",
      cibleNom: membreNom,
      details: "Montant : $montant FCFA",
    );
  }

  /// Logger un tirage
  static Future<void> logTirage(String tontineNom, String gagnantNom, int montant, String mode) async {
    await _db.logAction(
      adminId: currentAdminId,
      adminNom: currentAdminNom,
      action: "Effectué un tirage pour \"$tontineNom\"",
      typeAction: "Tirage",
      cibleNom: tontineNom,
      details: "Gagnant : $gagnantNom | Montant : $montant FCFA | Mode : $mode",
    );
  }

  /// Logger la sortie (retrait ou décès) d'un membre
  static Future<void> logSortieMembre(
      String membreNom, String typeSortie, int montantARembourser) async {
    await _db.logAction(
      adminId: currentAdminId,
      adminNom: currentAdminNom,
      action: "Enregistré la sortie ($typeSortie) de \"$membreNom\"",
      typeAction: "Membre",
      cibleNom: membreNom,
      details: "Type : $typeSortie | Montant à rembourser : $montantARembourser FCFA",
    );
  }

  /// Logger le remboursement d'un membre sorti
  static Future<void> logRemboursementMembre(String membreNom, int montant) async {
    await _db.logAction(
      adminId: currentAdminId,
      adminNom: currentAdminNom,
      action: "Marqué le remboursement de \"$membreNom\" comme effectué",
      typeAction: "Membre",
      cibleNom: membreNom,
      details: "Montant remboursé : $montant FCFA",
    );
  }

  /// Logger une connexion admin
  static Future<void> logConnexion(String adminNom) async {
    currentAdminNom = adminNom;
    await _db.logAction(
      adminId: currentAdminId,
      adminNom: adminNom,
      action: "Connexion au système",
      typeAction: "Connexion",
    );
  }

  /// Logger une déconnexion
  static Future<void> logDeconnexion() async {
    await _db.logAction(
      adminId: currentAdminId,
      adminNom: currentAdminNom,
      action: "Déconnexion du système",
      typeAction: "Déconnexion",
    );
  }
}