import 'package:flutter/material.dart';
import '../../data/shared_data.dart';
import '../../utils/audit_logger.dart';
class AdminTontinesPage extends StatefulWidget {
  const AdminTontinesPage({super.key});

  @override
  State<AdminTontinesPage> createState() => _AdminTontinesPageState();
}

class _AdminTontinesPageState extends State<AdminTontinesPage> {
  final SharedData _data = SharedData();
  String _searchQuery = "";

  // Widget : Detail Box
  Widget _detailBox(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // Widget : Champ de saisie
  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    IconData? icon,
    bool readOnly = false,
    VoidCallback? onTap,
    TextInputType type = TextInputType.text,
    int maxLines = 1,
    Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: type,
      maxLines: maxLines,
      onChanged: onChanged,
      onTap: onTap,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, color: Colors.green[700]) : null,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // Widget : Bouton rond (+ / -)
  Widget _roundButton({required IconData icon, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.green[100],
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 18, color: Colors.green[900]),
      ),
    );
  }

  // Afficher les détails d'une tontine
  void _afficherDetails(Map<String, dynamic> t) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(t["nom"],
              style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SizedBox(
            width: double.maxFinite,
            height: 520,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  _detailBox("Montant", "${t["montant"]} FCFA"),
                  _detailBox("Fréquence", t["frequence"]),
                  _detailBox("Membres", t["membres"].toString()),
                  _detailBox("Statut", t["statut"]),
                  _detailBox("Début", t["dateDebut"]),
                  _detailBox("Fin", t["dateFin"]),
                  _detailBox("Total", "${t["montantTotal"]} FCFA"),
                  _detailBox(
                      "Tirage aléatoire", t["tirageAleatoire"] ? "Oui" : "Non"),
                  const SizedBox(height: 12),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Description",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      t["description"].toString().isNotEmpty
                          ? t["description"]
                          : "— Aucune description —",
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text("📜 Règlement intérieur",
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      (t["reglement"]?.toString().isNotEmpty ?? false)
                          ? t["reglement"]
                          : "— Aucun règlement intérieur défini —",
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Fermer"),
            )
          ],
        );
      },
    );
  }

  // Ajouter une tontine
  void _ajouterTontine() {
    final nom = TextEditingController();
    final montant = TextEditingController();
    final dateDebut = TextEditingController();
    final description = TextEditingController();
    final reglement = TextEditingController(
      text: "1. Chaque membre s'engage à verser sa cotisation à la date "
          "prévue.\n"
          "2. Tout retard de paiement doit être signalé à l'administrateur.\n"
          "3. Le tirage de la cagnotte est effectué selon l'ordre ou le "
          "mode défini ci-dessus.\n"
          "4. En cas de départ ou de décès d'un membre, les cotisations "
          "déjà versées lui sont restituées (ou à ses ayants droit), sauf "
          "accord contraire entre les membres.\n"
          "5. Toute décision importante concernant la tontine doit être "
          "validée collectivement par les membres.",
    );
    final commissionController = TextEditingController(text: "0");

    int membres = 0;
    bool tirage = false;
    String frequence = "Mensuelle";

    int total = 0;
    String dateFin = "";

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, update) {
            void recalculer() {
              final m = int.tryParse(montant.text) ?? 0;
              if (m > 0 && membres > 0 && dateDebut.text.isNotEmpty) {
                total = m * membres;
                try {
                  final p = dateDebut.text.split("/");
                  final debut = DateTime(
                      int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
                  Duration d;
                  if (frequence == "Mensuelle") {
                    d = Duration(days: 30 * membres);
                  } else if (frequence == "Hebdomadaire") {
                    d = Duration(days: 7 * membres);
                  } else {
                    d = Duration(days: 90 * membres);
                  }
                  final fin = debut.add(d);
                  dateFin =
                      "${fin.day.toString().padLeft(2, '0')}/${fin.month.toString().padLeft(2, '0')}/${fin.year}";
                } catch (_) {
                  dateFin = "";
                }
              } else {
                total = 0;
                dateFin = "";
              }
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: const Text("Nouvelle Tontine",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              content: SizedBox(
                height: 680,
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildInputField(
                        label: "Nom de la tontine",
                        controller: nom,
                        icon: Icons.group,
                      ),
                      const SizedBox(height: 12),
                      _buildInputField(
                        label: "Montant (FCFA)",
                        controller: montant,
                        type: TextInputType.number,
                        icon: Icons.payments,
                        onChanged: (_) => update(() => recalculer()),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(border: InputBorder.none),
                          initialValue: frequence,
                          items: const [
                            DropdownMenuItem(
                                value: "Hebdomadaire",
                                child: Text("Hebdomadaire")),
                            DropdownMenuItem(
                                value: "Mensuelle", child: Text("Mensuelle")),
                            DropdownMenuItem(
                                value: "Trimestrielle",
                                child: Text("Trimestrielle")),
                          ],
                          onChanged: (v) {
                            frequence = v!;
                            update(() => recalculer());
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Nombre de membres",
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          Row(
                            children: [
                              _roundButton(
                                icon: Icons.remove,
                                onTap: () {
                                  if (membres > 0) {
                                    membres--;
                                    update(() => recalculer());
                                  }
                                },
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: Text("$membres",
                                    style: const TextStyle(fontSize: 18)),
                              ),
                              _roundButton(
                                icon: Icons.add,
                                onTap: () {
                                  if (membres < 50) {
                                    membres++;
                                    update(() => recalculer());
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        label: "Date de début",
                        controller: dateDebut,
                        icon: Icons.calendar_today,
                        readOnly: true,
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2024),
                            lastDate: DateTime(2030),
                          );
                          if (date != null) {
                            dateDebut.text =
                                "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
                            update(() => recalculer());
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Tirage aléatoire",
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          Switch(
                            value: tirage,
                            activeThumbColor: Colors.green,
                            onChanged: (v) => update(() => tirage = v),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        label: "Description",
                        controller: description,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        label: "Règlement intérieur",
                        controller: reglement,
                        maxLines: 6,
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        label: "Commission administrateur (%)",
                        controller: commissionController,
                        type: const TextInputType.numberWithOptions(decimal: true),
                        icon: Icons.percent,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Text("Total: $total FCFA",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            Text("Date de fin: $dateFin"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Annuler"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00853F)),
                  onPressed: () async {
                    if (nom.text.isNotEmpty &&
                        montant.text.isNotEmpty &&
                        membres > 0) {
                      _data.ajouterTontine({
                        "id": _data.genererIdUnique("t"),
                        "nom": nom.text,

                        "montant": int.tryParse(montant.text) ?? 0,
                        "frequence": frequence,
                        "membres": membres,
                        "statut": "Active",
                        "dateDebut": dateDebut.text,
                        "dateFin": dateFin,
                        "description": description.text,
                        "montantTotal": total,
                        "tirageAleatoire": tirage,
                        "reglement": reglement.text,
                        "commissionPourcentage":
                            double.tryParse(commissionController.text) ?? 0.0,
                      });
                      await AuditLogger.logCreationTontine(nom.text);
                      setState(() {});
                      Navigator.pop(context);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("${nom.text} créée avec succès"),
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
                  child: const Text("Créer"),
                )
              ],
            );
          },
        );
      },
    );
  }

  // Modifier une tontine
  void _modifierTontine(Map<String, dynamic> t) {
    final nomController = TextEditingController(text: t["nom"]);
    final montantController =
        TextEditingController(text: t["montant"].toString());
    final descriptionController = TextEditingController(text: t["description"]);
    final reglementController =
        TextEditingController(text: t["reglement"]?.toString() ?? "");
    final commissionController = TextEditingController(
        text: (t["commissionPourcentage"] ?? 0.0).toString());
    final dateDebutController = TextEditingController(text: t["dateDebut"]);
    String frequence = t["frequence"];
    bool tirageAleatoire = t["tirageAleatoire"];
    int membresCount = t["membres"];
    int montantTotal = t["montantTotal"];
    String dateFinCalculee = t["dateFin"];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            void recalculer() {
              final montant = int.tryParse(montantController.text) ?? 0;

              if (montant <= 0 ||
                  membresCount <= 0 ||
                  dateDebutController.text.isEmpty) {
                montantTotal = 0;
                dateFinCalculee = "";
                return;
              }

              montantTotal = montant * membresCount;

              try {
                final p = dateDebutController.text.split("/");
                final debut =
                    DateTime(int.parse(p[2]), int.parse(p[1]), int.parse(p[0]));
                Duration d;

                if (frequence == "Mensuelle") {
                  d = Duration(days: 30 * membresCount);
                } else if (frequence == "Hebdomadaire") {
                  d = Duration(days: 7 * membresCount);
                } else {
                  d = Duration(days: 90 * membresCount);
                }

                final fin = debut.add(d);
                dateFinCalculee =
                    "${fin.day.toString().padLeft(2, '0')}/${fin.month.toString().padLeft(2, '0')}/${fin.year}";
              } catch (_) {}
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              title: const Text("Modifier Tontine",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              content: SizedBox(
                height: 680,
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildInputField(
                        label: "Nom de la tontine",
                        controller: nomController,
                        icon: Icons.group,
                      ),
                      const SizedBox(height: 12),
                      _buildInputField(
                        label: "Montant (FCFA)",
                        controller: montantController,
                        type: TextInputType.number,
                        icon: Icons.payments,
                        onChanged: (_) => setStateDialog(() => recalculer()),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(border: InputBorder.none),
                          initialValue: frequence,
                          items: const [
                            DropdownMenuItem(
                                value: "Hebdomadaire",
                                child: Text("Hebdomadaire")),
                            DropdownMenuItem(
                                value: "Mensuelle", child: Text("Mensuelle")),
                            DropdownMenuItem(
                                value: "Trimestrielle",
                                child: Text("Trimestrielle")),
                          ],
                          onChanged: (v) {
                            frequence = v!;
                            setStateDialog(() => recalculer());
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Nombre de membres",
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          Row(
                            children: [
                              _roundButton(
                                icon: Icons.remove,
                                onTap: () {
                                  if (membresCount > 0) {
                                    membresCount--;
                                    setStateDialog(() => recalculer());
                                  }
                                },
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                child: Text("$membresCount",
                                    style: const TextStyle(fontSize: 18)),
                              ),
                              _roundButton(
                                icon: Icons.add,
                                onTap: () {
                                  if (membresCount < 50) {
                                    membresCount++;
                                    setStateDialog(() => recalculer());
                                  }
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        label: "Date de début",
                        controller: dateDebutController,
                        icon: Icons.calendar_today,
                        readOnly: true,
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2024),
                            lastDate: DateTime(2030),
                          );
                          if (date != null) {
                            dateDebutController.text =
                                "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
                            setStateDialog(() => recalculer());
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Tirage aléatoire",
                              style: TextStyle(fontWeight: FontWeight.w600)),
                          Switch(
                            value: tirageAleatoire,
                            activeThumbColor: Colors.green,
                            onChanged: (v) =>
                                setStateDialog(() => tirageAleatoire = v),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        label: "Description",
                        controller: descriptionController,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        label: "Règlement intérieur",
                        controller: reglementController,
                        maxLines: 6,
                      ),
                      const SizedBox(height: 16),
                      _buildInputField(
                        label: "Commission administrateur (%)",
                        controller: commissionController,
                        type: const TextInputType.numberWithOptions(decimal: true),
                        icon: Icons.percent,
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          children: [
                            Text("Total: $montantTotal FCFA",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            Text("Date de fin: $dateFinCalculee"),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Annuler"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00853F)),
                  onPressed: () async {
                    _data.modifierTontine(t["id"], {
                      "nom": nomController.text,
                      "montant": int.tryParse(montantController.text) ?? 0,
                      "frequence": frequence,
                      "membres": membresCount,
                      "dateDebut": dateDebutController.text,
                      "dateFin": dateFinCalculee,
                      "description": descriptionController.text,
                      "montantTotal": montantTotal,
                      "tirageAleatoire": tirageAleatoire,
                      "reglement": reglementController.text,
                      "commissionPourcentage":
                          double.tryParse(commissionController.text) ?? 0.0,
                    });
                    await AuditLogger.logModificationTontine(nomController.text);
                    setState(() {});
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Tontine modifiée avec succès"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  child: const Text("Enregistrer"),
                )
              ],
            );
          },
        );
      },
    );
  }

  // Supprimer une tontine
  void _supprimerTontine(Map<String, dynamic> t) {
    final raisonBlocage = _data.verifierSuppressionTontine(t["id"]);

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
        title: const Text("Supprimer Tontine"),
        content: Text("Voulez-vous vraiment supprimer ${t["nom"]} ?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler")),
          TextButton(
            onPressed: () async {
              final nomTontine = t["nom"];  // ✅ Sauvegarder le nom avant suppression

              _data.supprimerTontine(t["id"]);

              // ✅ AJOUTER CETTE LIGNE
              await AuditLogger.logSuppressionTontine(nomTontine);

              setState(() {});
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("${t["nom"]} supprimée"),
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

  @override
  Widget build(BuildContext context) {
    final filtered = _data.tontines
        .where(
            (t) => t["nom"].toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: "Rechercher une tontine...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
            const SizedBox(height: 20),
            Expanded(
                child: filtered.isEmpty
                    ? const Center(child: Text("Aucune tontine trouvée."))
                    : ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, i) {
                          final t = filtered[i];
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
                                // Titre + Badge
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        t["nom"],
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF00853F),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: t["statut"] == "Active"
                                            ? Colors.green[100]
                                            : t["statut"] == "Complète"
                                                ? Colors.orange[100]
                                                : Colors.red[100],
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        t["statut"],
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: t["statut"] == "Active"
                                              ? Colors.green
                                              : t["statut"] == "Complète"
                                                  ? Colors.orange[800]
                                                  : Colors.red,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Adhérents + Montant
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.group,
                                            size: 18, color: Colors.black54),
                                        const SizedBox(width: 6),
                                        Text("${t["membres"]} adhérents",
                                            style:
                                                const TextStyle(fontSize: 14)),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Icon(Icons.attach_money,
                                            size: 18, color: Colors.black54),
                                        const SizedBox(width: 6),
                                        Text("${t["montant"]} FCFA",
                                            style:
                                                const TextStyle(fontSize: 14)),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),

                                // Durée + Fréquence
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_month,
                                            size: 18, color: Colors.black54),
                                        const SizedBox(width: 6),
                                        Text(t["frequence"],
                                            style:
                                                const TextStyle(fontSize: 14)),
                                      ],
                                    ),
                                    Text(
                                      "${t["dateDebut"]} - ${t["dateFin"]}",
                                      style: const TextStyle(
                                          fontSize: 12, color: Colors.black54),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Actions
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      onPressed: () => _afficherDetails(t),
                                      icon: const Icon(Icons.info_outline,
                                          color: Colors.blue),
                                    ),
                                    IconButton(
                                      onPressed: () => _modifierTontine(t),
                                      icon: const Icon(Icons.edit,
                                          color: Colors.orange),
                                    ),
                                    IconButton(
                                      onPressed: () => _supprimerTontine(t),
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _ajouterTontine,
        backgroundColor: const Color(0xFFE30B17),
        icon: const Icon(Icons.add),
        label: const Text("Nouvelle Tontine"),
      ),
    );
  }
}
