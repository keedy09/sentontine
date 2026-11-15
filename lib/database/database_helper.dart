import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Helper pour gérer la base de données SQLite AVEC audit trail
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  static const String tableTontines = 'tontines';
  static const String tableMembres = 'membres';
  static const String tablePaiements = 'paiements';
  static const String tableTirages = 'tirages';
  static const String tableActionsLog = 'actions_log'; // ✅ NOUVEAU

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('sentontine.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 6, onCreate: _createDB, onUpgrade: _upgradeDB); // ✅ Version 6
  }

  Future _createDB(Database db, int version) async {
    // Table tontines
    await db.execute('''
      CREATE TABLE $tableTontines (
        id TEXT PRIMARY KEY,
        nom TEXT NOT NULL,
        montant INTEGER NOT NULL,
        frequence TEXT NOT NULL,
        membres INTEGER NOT NULL,
        statut TEXT NOT NULL,
        dateDebut TEXT NOT NULL,
        dateFin TEXT NOT NULL,
        description TEXT,
        montantTotal INTEGER NOT NULL,
        tirageAleatoire INTEGER NOT NULL,
        reglement TEXT,
        commissionPourcentage REAL
      )
    ''');

    // Table membres
    await db.execute('''
      CREATE TABLE $tableMembres (
        id TEXT PRIMARY KEY,
        nom TEXT NOT NULL,
        email TEXT NOT NULL,
        telephone TEXT NOT NULL,
        password TEXT NOT NULL,
        role TEXT NOT NULL,
        statut TEXT NOT NULL,
        tontineId TEXT,
        tontine TEXT,
        typeSortie TEXT,
        dateSortie TEXT,
        montantRembourse INTEGER,
        rembourse INTEGER
      )
    ''');

    // Table paiements
    await db.execute('''
      CREATE TABLE $tablePaiements (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        membreId TEXT NOT NULL,
        membreNom TEXT NOT NULL,
        tontineId TEXT NOT NULL,
        tontineNom TEXT NOT NULL,
        montant INTEGER NOT NULL,
        statut TEXT NOT NULL
      )
    ''');

    // Table tirages
    await db.execute('''
      CREATE TABLE $tableTirages (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        tontineId TEXT NOT NULL,
        tontineNom TEXT NOT NULL,
        gagnantId TEXT NOT NULL,
        gagnantNom TEXT NOT NULL,
        montant INTEGER NOT NULL,
        mode TEXT NOT NULL,
        commission INTEGER
      )
    ''');

    // ✅ NOUVELLE TABLE : Actions Log (Audit Trail)
    await db.execute('''
      CREATE TABLE $tableActionsLog (
        id TEXT PRIMARY KEY,
        date TEXT NOT NULL,
        adminId TEXT NOT NULL,
        adminNom TEXT NOT NULL,
        action TEXT NOT NULL,
        typeAction TEXT NOT NULL,
        cibleId TEXT,
        cibleNom TEXT,
        details TEXT
      )
    ''');
  }

  // ✅ MIGRATION pour ajouter la table si elle n'existe pas
  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $tableActionsLog (
          id TEXT PRIMARY KEY,
          date TEXT NOT NULL,
          adminId TEXT NOT NULL,
          adminNom TEXT NOT NULL,
          action TEXT NOT NULL,
          typeAction TEXT NOT NULL,
          cibleId TEXT,
          cibleNom TEXT,
          details TEXT
        )
      ''');
    }
    if (oldVersion < 3) {
      await db.execute('''
        ALTER TABLE $tableTontines ADD COLUMN reglement TEXT
      ''');
    }
    if (oldVersion < 4) {
      await db.execute('''
        ALTER TABLE $tableMembres ADD COLUMN typeSortie TEXT
      ''');
      await db.execute('''
        ALTER TABLE $tableMembres ADD COLUMN dateSortie TEXT
      ''');
      await db.execute('''
        ALTER TABLE $tableMembres ADD COLUMN montantRembourse INTEGER
      ''');
      await db.execute('''
        ALTER TABLE $tableMembres ADD COLUMN rembourse INTEGER
      ''');
    }
    if (oldVersion < 5) {
      await db.execute('''
        ALTER TABLE $tableTontines ADD COLUMN commissionPourcentage REAL
      ''');
    }
    if (oldVersion < 6) {
      await db.execute('''
        ALTER TABLE $tableTirages ADD COLUMN commission INTEGER
      ''');
    }
  }

  // ==================== ACTIONS LOG (NOUVEAU) ====================

  /// Enregistrer une action admin dans l'historique
  Future<void> logAction({
    required String adminId,
    required String adminNom,
    required String action,
    required String typeAction,
    String? cibleId,
    String? cibleNom,
    String? details,
  }) async {
    final db = await database;
    final now = DateTime.now();
    final dateStr = "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year} ${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

    await db.insert(
      tableActionsLog,
      {
        'id': 'log_${now.millisecondsSinceEpoch}',
        'date': dateStr,
        'adminId': adminId,
        'adminNom': adminNom,
        'action': action,
        'typeAction': typeAction,
        'cibleId': cibleId ?? '',
        'cibleNom': cibleNom ?? '',
        'details': details ?? '',
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Récupérer tout l'historique (plus récent en premier)
  Future<List<Map<String, dynamic>>> getActionsLog() async {
    final db = await database;
    final rows = await db.query(tableActionsLog, orderBy: 'id DESC', limit: 100);
    return rows.map((r) => {
      'id': r['id'],
      'date': r['date'],
      'adminId': r['adminId'],
      'adminNom': r['adminNom'],
      'action': r['action'],
      'typeAction': r['typeAction'],
      'cibleId': r['cibleId'],
      'cibleNom': r['cibleNom'],
      'details': r['details'],
    }).toList();
  }

  /// Filtrer par type d'action
  Future<List<Map<String, dynamic>>> getActionsLogByType(String typeAction) async {
    final db = await database;
    final rows = await db.query(
      tableActionsLog,
      where: 'typeAction = ?',
      whereArgs: [typeAction],
      orderBy: 'id DESC',
      limit: 50,
    );
    return rows.map((r) => {
      'id': r['id'],
      'date': r['date'],
      'adminId': r['adminId'],
      'adminNom': r['adminNom'],
      'action': r['action'],
      'typeAction': r['typeAction'],
      'cibleId': r['cibleId'],
      'cibleNom': r['cibleNom'],
      'details': r['details'],
    }).toList();
  }

  // ==================== TONTINES ====================

  Future<void> insertTontine(Map<String, dynamic> t) async {
    final db = await database;
    await db.insert(
        tableTontines,
        {
          'id': t['id'],
          'nom': t['nom'],
          'montant': t['montant'],
          'frequence': t['frequence'],
          'membres': t['membres'],
          'statut': t['statut'],
          'dateDebut': t['dateDebut'],
          'dateFin': t['dateFin'],
          'description': t['description'] ?? '',
          'montantTotal': t['montantTotal'],
          'tirageAleatoire': (t['tirageAleatoire'] == true) ? 1 : 0,
          'reglement': t['reglement'] ?? '',
          'commissionPourcentage': t['commissionPourcentage'] ?? 0.0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getTontines() async {
    final db = await database;
    final rows = await db.query(tableTontines);
    return rows
        .map((r) => {
      'id': r['id'],
      'nom': r['nom'],
      'montant': r['montant'],
      'frequence': r['frequence'],
      'membres': r['membres'],
      'statut': r['statut'],
      'dateDebut': r['dateDebut'],
      'dateFin': r['dateFin'],
      'description': r['description'],
      'montantTotal': r['montantTotal'],
      'tirageAleatoire': r['tirageAleatoire'] == 1,
      'reglement': r['reglement'] ?? '',
      'commissionPourcentage': r['commissionPourcentage'] ?? 0.0,
    })
        .toList();
  }

  Future<void> updateTontine(String id, Map<String, dynamic> t) async {
    final db = await database;
    await db.update(
        tableTontines,
        {
          'nom': t['nom'],
          'montant': t['montant'],
          'frequence': t['frequence'],
          'membres': t['membres'],
          'statut': t['statut'],
          'dateDebut': t['dateDebut'],
          'dateFin': t['dateFin'],
          'description': t['description'] ?? '',
          'montantTotal': t['montantTotal'],
          'tirageAleatoire': (t['tirageAleatoire'] == true) ? 1 : 0,
          'reglement': t['reglement'] ?? '',
          'commissionPourcentage': t['commissionPourcentage'] ?? 0.0,
        },
        where: 'id = ?',
        whereArgs: [id]);
  }

  Future<void> deleteTontine(String id) async {
    final db = await database;
    await db.delete(tableTontines, where: 'id = ?', whereArgs: [id]);
  }

  // ==================== MEMBRES ====================

  Future<void> insertMembre(Map<String, dynamic> m) async {
    final db = await database;
    await db.insert(
        tableMembres,
        {
          'id': m['id'],
          'nom': m['nom'],
          'email': m['email'],
          'telephone': m['telephone'],
          'password': m['password'],
          'role': m['role'],
          'statut': m['statut'],
          'tontineId': m['tontineId'] ?? '',
          'tontine': m['tontine'] ?? '',
          'typeSortie': m['typeSortie'],
          'dateSortie': m['dateSortie'],
          'montantRembourse': m['montantRembourse'],
          'rembourse': (m['rembourse'] == true) ? 1 : 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getMembres() async {
    final db = await database;
    final rows = await db.query(tableMembres);
    return rows
        .map((r) => {
      'id': r['id'],
      'nom': r['nom'],
      'email': r['email'],
      'telephone': r['telephone'],
      'password': r['password'],
      'role': r['role'],
      'statut': r['statut'],
      'tontineId': r['tontineId'],
      'tontine': r['tontine'],
      'typeSortie': r['typeSortie'],
      'dateSortie': r['dateSortie'],
      'montantRembourse': r['montantRembourse'],
      'rembourse': r['rembourse'] == 1,
    })
        .toList();
  }

  Future<void> updateMembre(String id, Map<String, dynamic> updates) async {
    final db = await database;
    await db.update(tableMembres, updates, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deleteMembre(String id) async {
    final db = await database;
    await db.delete(tableMembres, where: 'id = ?', whereArgs: [id]);
  }

  // ==================== PAIEMENTS ====================

  Future<void> insertPaiement(Map<String, dynamic> p) async {
    final db = await database;
    await db.insert(
        tablePaiements,
        {
          'id': p['id'],
          'date': p['date'],
          'membreId': p['membreId'],
          'membreNom': p['membreNom'],
          'tontineId': p['tontineId'],
          'tontineNom': p['tontineNom'],
          'montant': p['montant'],
          'statut': p['statut'],
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getPaiements() async {
    final db = await database;
    final rows = await db.query(tablePaiements);
    return rows
        .map((r) => {
      'id': r['id'],
      'date': r['date'],
      'membreId': r['membreId'],
      'membreNom': r['membreNom'],
      'tontineId': r['tontineId'],
      'tontineNom': r['tontineNom'],
      'montant': r['montant'],
      'statut': r['statut'],
    })
        .toList();
  }

  Future<void> updatePaiement(String id, Map<String, dynamic> updates) async {
    final db = await database;
    await db.update(tablePaiements, updates, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> deletePaiement(String id) async {
    final db = await database;
    await db.delete(tablePaiements, where: 'id = ?', whereArgs: [id]);
  }

  // ==================== TIRAGES ====================

  Future<void> insertTirage(Map<String, dynamic> t) async {
    final db = await database;
    await db.insert(
        tableTirages,
        {
          'id': t['id'],
          'date': t['date'],
          'tontineId': t['tontineId'],
          'tontineNom': t['tontineNom'],
          'gagnantId': t['gagnantId'],
          'gagnantNom': t['gagnantNom'],
          'montant': t['montant'],
          'mode': t['mode'],
          'commission': t['commission'] ?? 0,
        },
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Map<String, dynamic>>> getTirages() async {
    final db = await database;
    final rows = await db.query(tableTirages, orderBy: 'date DESC');
    return rows
        .map((r) => {
      'id': r['id'],
      'date': r['date'],
      'tontineId': r['tontineId'],
      'tontineNom': r['tontineNom'],
      'gagnantId': r['gagnantId'],
      'gagnantNom': r['gagnantNom'],
      'montant': r['montant'],
      'mode': r['mode'],
      'commission': r['commission'] ?? 0,
    })
        .toList();
  }

  // ==================== UTILITAIRES ====================

  Future<void> clearAllTables() async {
    final db = await database;
    await db.delete(tableTontines);
    await db.delete(tableMembres);
    await db.delete(tablePaiements);
    await db.delete(tableTirages);
    await db.delete(tableActionsLog); // ✅ NOUVEAU
  }

  Future<void> resetDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'sentontine.db');
    await deleteDatabase(path);
    _database = null;
    await database;
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}