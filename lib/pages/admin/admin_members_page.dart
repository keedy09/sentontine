import 'package:flutter/material.dart';
import '../../data/shared_data.dart';
import '../../utils/audit_logger.dart';
import '../../utils/member_card_generator.dart';

class AdminMembersPage extends StatefulWidget {
  const AdminMembersPage({super.key});

  @override
  State<AdminMembersPage> createState() => _AdminMembersPageState();
}

class _AdminMembersPageState extends State<AdminMembersPage> {
  final SharedData _data = SharedData();
  String _searchQuery = "";
  bool _showPassword = false;

  // Afficher les détails d'un membre
  void _afficherDetails(Map<String, dynamic> membre) {
    final aUneSortie =
        membre["typeSortie"] != null && membre["typeSortie"].toString().isNotEmpty;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            title: Text(membre["nom"]),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("📧 Email : ${membre["email"]}"),
                  Text("📞 Téléphone : ${membre["telephone"]}"),
                  Text("🏦 Tontine : ${membre["tontine"]}"),
                  Text("🛂 Rôle : ${membre["role"]}"),
                  Text("🟢 Statut : ${membre["statut"]}"),
                  if (aUneSortie) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "⚠️ Sortie : ${membre["typeSortie"]}",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text("Date : ${membre["dateSortie"] ?? "—"}"),
                          Text(
                              "Montant à rembourser : ${membre["montantRembourse"] ?? 0} FCFA"),
                          Text(
                            (membre["rembourse"] == true)
                                ? "✅ Remboursement effectué"
                                : "⏳ Remboursement en attente",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: (membre["rembourse"] == true)
                                  ? Colors.green
                                  : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (membre["rembourse"] != true) ...[
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF00853F)),
                          onPressed: () async {
                            _data.marquerRembourse(membre["id"]);
                            await AuditLogger.logRemboursementMembre(
                              membre["nom"],
                              membre["montantRembourse"] ?? 0,
                            );
                            setStateDialog(() => membre["rembourse"] = true);
                            setState(() {});
                          },
                          icon: const Icon(Icons.check_circle),
                          label: const Text("Marquer comme remboursé"),
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Fermer"),
              ),
              if (membre["role"] == "membre")
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00853F)),
                  onPressed: () async {
                    try {
                      final tontine = _data.getTontine(membre["tontineId"]);
                      await MemberCardGenerator.shareCard(membre, tontine);
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
                  label: const Text("Carte membre"),
                ),
            ],
          );
        },
      ),
    );
  }

  // Affecter une tontine
  void _affecterTontine(Map<String, dynamic> membre) {
    String? tontineChoisie;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text("Affecter ${membre["nom"]}"),
        content: DropdownButtonFormField<String>(
          decoration: const InputDecoration(labelText: "Choisir une tontine"),
          items: _data.tontines
              .map((t) => DropdownMenuItem<String>(
                    value: t["id"] as String,
                    child: Text(t["nom"]),
                  ))
              .toList(),
          onChanged: (val) => tontineChoisie = val,
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
              if (tontineChoisie != null && tontineChoisie!.isNotEmpty) {
                final tontine = _data.getTontine(tontineChoisie!);
                if (tontine != null) {
                  // Empêcher l'affectation si la tontine est déjà complète
                  final actifs =
                      _data.compterMembresActifsTontine(tontineChoisie!);
                  final cible = (tontine['membres'] as num?)?.toInt() ?? 0;
                  if (tontine['statut'] == 'Complète' || (cible > 0 && actifs >= cible)) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            "Impossible d'affecter ce membre : la tontine \"${tontine["nom"]}\" a déjà atteint son nombre maximal de membres ($cible)."),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }

                  _data.modifierMembre(membre["id"], {
                    "tontineId": tontineChoisie!,
                    "tontine": tontine["nom"],
                    "statut": "Actif",
                  });
                  await AuditLogger.logAffectationMembre(
                    membre["nom"],
                    tontine["nom"],
                  );
                  await _data
                      .verifierEtMettreAJourStatutTontine(tontineChoisie!);

                  setState(() {});
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content:
                          Text("${membre["nom"]} affecté à ${tontine["nom"]}"),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              }
            },
            child: const Text("Affecter"),
          ),
        ],
      ),
    );
  }

  // Modifier un membre
  void _modifierMembre(Map<String, dynamic> membre) {
    final nomController = TextEditingController(text: membre["nom"]);
    final emailController = TextEditingController(text: membre["email"]);
    final telephoneController =
        TextEditingController(text: membre["telephone"]);
    final passwordController = TextEditingController();

    String role = membre["role"];
    String statut = membre["statut"];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text("Modifier le membre"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: nomController,
                    decoration: const InputDecoration(labelText: "Nom"),
                  ),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: "Email"),
                  ),
                  TextField(
                    controller: telephoneController,
                    decoration: const InputDecoration(labelText: "Téléphone"),
                  ),
                  TextField(
                    controller: passwordController,
                    obscureText: !_showPassword,
                    decoration: InputDecoration(
                      labelText: "Nouveau mot de passe",
                      helperText:
                          "Laisser vide pour conserver le mot de passe actuel",
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setStateDialog(() => _showPassword = !_showPassword);
                        },
                      ),
                    ),
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: role,
                    decoration: const InputDecoration(labelText: "Rôle"),
                    items: const [
                      DropdownMenuItem(value: "membre", child: Text("Membre")),
                      DropdownMenuItem(value: "admin", child: Text("Admin")),
                    ],
                    onChanged: (val) => role = val!,
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: statut,
                    decoration: const InputDecoration(labelText: "Statut"),
                    items: const [
                      DropdownMenuItem(value: "Actif", child: Text("Actif")),
                      DropdownMenuItem(
                          value: "Inactif", child: Text("Inactif")),
                    ],
                    onChanged: (val) => statut = val!,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Annuler"),
              ),
              ElevatedButton(
                onPressed: () async {
                  final nouvellesDonnees = <String, dynamic>{
                    "nom": nomController.text,
                    "email": emailController.text,
                    "telephone": telephoneController.text,
                    "role": role,
                    "statut": statut,
                  };
                  // On ne touche au mot de passe que si l'admin a saisi
                  // une nouvelle valeur ; sinon on garde l'ancien hash.
                  if (passwordController.text.isNotEmpty) {
                    nouvellesDonnees["password"] = passwordController.text;
                  }
                  _data.modifierMembre(membre["id"], nouvellesDonnees);
                  await AuditLogger.logModificationMembre(nomController.text);

                  setState(() {});
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Membre modifié avec succès"),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00853F),
                ),
                child: const Text("Enregistrer"),
              ),
            ],
          );
        },
      ),
    );
  }

  // Gérer le retrait ou le décès d'un membre, avec remboursement
  void _gererSortieMembre(Map<String, dynamic> membre) {
    final totalCotise =
        _data.calculerTotalCotiseMembre(membre["id"], tontineId: membre["tontineId"]);

    String typeSortie = "Retrait";
    bool dejaRembourse = false;
    final montantController =
        TextEditingController(text: totalCotise.toString());

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text("Retrait / Décès d'un membre"),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Membre : ${membre["nom"]}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text("Tontine : ${membre["tontine"]}"),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "Total déjà cotisé dans cette tontine : $totalCotise FCFA",
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: typeSortie,
                    decoration: const InputDecoration(
                      labelText: "Motif de la sortie",
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: "Retrait", child: Text("Retrait volontaire")),
                      DropdownMenuItem(value: "Décès", child: Text("Décès")),
                    ],
                    onChanged: (v) => setStateDialog(() => typeSortie = v!),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: montantController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Montant à rembourser (FCFA)",
                      helperText:
                          "Pré-rempli avec le total cotisé, modifiable selon "
                          "l'accord entre les membres",
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Checkbox(
                        value: dejaRembourse,
                        onChanged: (v) =>
                            setStateDialog(() => dejaRembourse = v ?? false),
                      ),
                      const Expanded(
                        child: Text("Le remboursement a déjà été effectué"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Annuler"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE30B17)),
                onPressed: () async {
                  final montant = int.tryParse(montantController.text) ?? 0;
                  final aujourdHui = DateTime.now();
                  final dateSortie =
                      "${aujourdHui.day.toString().padLeft(2, '0')}/${aujourdHui.month.toString().padLeft(2, '0')}/${aujourdHui.year}";

                  await _data.enregistrerSortieMembre(
                    membreId: membre["id"],
                    typeSortie: typeSortie,
                    dateSortie: dateSortie,
                    montantARembourser: montant,
                    dejaRembourse: dejaRembourse,
                  );

                  await AuditLogger.logSortieMembre(
                      membre["nom"], typeSortie, montant);

                  setState(() {});
                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          "Sortie de ${membre["nom"]} enregistrée ($typeSortie)"),
                      backgroundColor: const Color(0xFF00853F),
                    ),
                  );
                },
                child: const Text("Enregistrer la sortie"),
              ),
            ],
          );
        },
      ),
    );
  }

  // Supprimer un membre
  void _supprimerMembre(Map<String, dynamic> membre) {
    final raisonBlocage = _data.verifierSuppressionMembre(membre["id"]);

    if (raisonBlocage != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Suppression impossible"),
          content: Text(raisonBlocage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Compris"),
            ),
          ],
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Supprimer le membre"),
        content: Text("Voulez-vous vraiment supprimer ${membre["nom"]} ?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Annuler"),
          ),
          TextButton(
            onPressed: () async {
              _data.supprimerMembre(membre["id"]);
              final nomMembre = membre["nom"];
              await AuditLogger.logSuppressionMembre(nomMembre);
              setState(() {});
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("${membre["nom"]} supprimé"),
                  backgroundColor: Colors.red,
                ),
              );
            },
            child: const Text("Supprimer", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // Ajouter un membre
  void _ajouterMembre() {
    final nomController = TextEditingController();
    final emailController = TextEditingController();
    final telephoneController = TextEditingController();
    final passwordController = TextEditingController();

    String role = "membre";
    String statut = "Actif";

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text("Ajouter un membre"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: nomController,
                    decoration: const InputDecoration(labelText: "Nom complet"),
                  ),
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: "Email"),
                  ),
                  TextField(
                    controller: telephoneController,
                    decoration: const InputDecoration(labelText: "Téléphone"),
                  ),
                  TextField(
                    controller: passwordController,
                    obscureText: !_showPassword,
                    decoration: InputDecoration(
                      labelText: "Mot de passe",
                      suffixIcon: IconButton(
                        icon: Icon(
                          _showPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setStateDialog(() => _showPassword = !_showPassword);
                        },
                      ),
                    ),
                  ),
                  DropdownButtonFormField<String>(
                    initialValue: role,
                    decoration: const InputDecoration(labelText: "Rôle"),
                    items: const [
                      DropdownMenuItem(value: "membre", child: Text("Membre")),
                      DropdownMenuItem(value: "admin", child: Text("Admin")),
                    ],
                    onChanged: (val) => role = val!,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Annuler"),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (nomController.text.isNotEmpty &&
                      emailController.text.isNotEmpty &&
                      telephoneController.text.isNotEmpty &&
                      passwordController.text.isNotEmpty) {
                    _data.ajouterMembre({
                      "id": _data.genererIdUnique("m"),
                      "nom": nomController.text,
                      "email": emailController.text,
                      "telephone": telephoneController.text,
                      "password": passwordController.text,
                      "role": role,
                      "statut": statut,
                      "tontineId": "",
                      "tontine": "Non affecté",
                    });
                    await AuditLogger.logAjoutMembre(
                      nomController.text,
                      role,
                    );

                    setState(() {});
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text("${nomController.text} ajouté avec succès"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Veuillez remplir tous les champs"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00853F),
                ),
                child: const Text("Ajouter"),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final membresFiltres = _data.membres
        .where(
            (m) => m["nom"].toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Barre de recherche
            TextField(
              decoration: InputDecoration(
                hintText: "Rechercher un membre...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),

            const SizedBox(height: 20),

            // Liste des membres
            Expanded(
              child: membresFiltres.isEmpty
                  ? const Center(child: Text("Aucun membre trouvé."))
                  : ListView.builder(
                      itemCount: membresFiltres.length,
                      itemBuilder: (context, index) {
                        final membre = membresFiltres[index];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Titre + Badge rôle
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      membre["nom"],
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF00853F),
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: membre["role"] == "admin"
                                          ? Colors.red[100]
                                          : Colors.blue[100],
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          membre["role"] == "admin"
                                              ? Icons.admin_panel_settings
                                              : Icons.person,
                                          size: 16,
                                          color: membre["role"] == "admin"
                                              ? Colors.red
                                              : Colors.blue,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          membre["role"] == "admin"
                                              ? "Admin"
                                              : "Membre",
                                          style: TextStyle(
                                            fontSize: 13,
                                            color: membre["role"] == "admin"
                                                ? Colors.red
                                                : Colors.blue,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // Email + Téléphone
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        const Icon(Icons.email,
                                            size: 18, color: Colors.black54),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            membre["email"],
                                            style:
                                                const TextStyle(fontSize: 14),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Row(
                                    children: [
                                      const Icon(Icons.phone,
                                          size: 18, color: Colors.black54),
                                      const SizedBox(width: 6),
                                      Text(
                                        membre["telephone"],
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ],
                              ),

                              const SizedBox(height: 10),

                              // Tontine + Statut
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        const Icon(Icons.group,
                                            size: 18, color: Colors.black54),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            membre["tontine"],
                                            style:
                                                const TextStyle(fontSize: 14),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: membre["statut"] == "Actif"
                                          ? Colors.green[100]
                                          : Colors.grey[200],
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      membre["statut"],
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: membre["statut"] == "Actif"
                                            ? Colors.green
                                            : Colors.grey,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 12),

                              // Actions
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    onPressed: () => _afficherDetails(membre),
                                    icon: const Icon(Icons.info_outline,
                                        color: Colors.blue),
                                  ),
                                  if (membre["role"] == "membre")
                                    IconButton(
                                      onPressed: () => _affecterTontine(membre),
                                      icon: const Icon(Icons.group_add,
                                          color: Colors.orange),
                                    ),
                                  if (membre["role"] == "membre" &&
                                      membre["statut"] == "Actif")
                                    IconButton(
                                      onPressed: () =>
                                          _gererSortieMembre(membre),
                                      icon: const Icon(
                                          Icons.person_remove,
                                          color: Colors.deepOrange),
                                      tooltip: "Retrait / Décès",
                                    ),
                                  IconButton(
                                    onPressed: () => _modifierMembre(membre),
                                    icon: const Icon(Icons.edit,
                                        color: Colors.green),
                                  ),
                                  IconButton(
                                    onPressed: () => _supprimerMembre(membre),
                                    icon: const Icon(Icons.delete,
                                        color: Colors.red),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _ajouterMembre,
        backgroundColor: const Color(0xFFE30B17),
        icon: const Icon(Icons.person_add),
        label: const Text("Nouveau membre"),
      ),
    );
  }
}
