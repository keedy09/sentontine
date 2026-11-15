import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Génère une carte de membre (recto-verso) au format PDF pour un membre
/// d'une tontine. La carte affiche : initiales (en guise d'avatar), nom,
/// numéro de membre, tontine, durée de participation, et au verso un
/// résumé du règlement intérieur.
class MemberCardGenerator {
  // Format approximatif d'une carte bancaire (en points PDF), x2 pour
  // une meilleure lisibilité à l'impression.
  static const double _cardWidth = 360;
  static const double _cardHeight = 220;

  static String _initiales(String nomComplet) {
    final parts = nomComplet.trim().split(RegExp(r"\s+"));
    if (parts.isEmpty) return "?";
    if (parts.length == 1) {
      return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : "?";
    }
    final first = parts.first.isNotEmpty ? parts.first[0] : "";
    final last = parts.last.isNotEmpty ? parts.last[0] : "";
    return (first + last).toUpperCase();
  }

  // Couleur générée à partir du nom pour varier l'avatar entre membres,
  // tout en restant dans les tons de la charte verte de l'application.
  static PdfColor _couleurAvatar(String nom) {
    const palette = [
      "#00853F",
      "#0E7C3D",
      "#1F8A4C",
      "#136F3A",
      "#0A6E4E",
    ];
    final index = nom.codeUnits.fold<int>(0, (a, b) => a + b) % palette.length;
    return PdfColor.fromHex(palette[index]);
  }

  static Future<pw.Document> buildCard(
    Map<String, dynamic> membre,
    Map<String, dynamic>? tontine,
  ) async {
    final pdf = pw.Document();

    final nom = membre["nom"]?.toString() ?? "";
    final id = membre["id"]?.toString() ?? "";
    final tontineNom = membre["tontine"]?.toString() ?? "";
    final dateDebut = tontine?["dateDebut"]?.toString() ?? "—";
    final dateFin = tontine?["dateFin"]?.toString() ?? "—";
    final initiales = _initiales(nom);
    final couleur = _couleurAvatar(nom);
    final reglement = tontine?["reglement"]?.toString() ?? "";
    final reglementResume = reglement.isNotEmpty
        ? (reglement.length > 380
            ? "${reglement.substring(0, 380)}…"
            : reglement)
        : "Aucun règlement intérieur défini pour cette tontine.";

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Center(
            child: pw.Column(
              mainAxisAlignment: pw.MainAxisAlignment.center,
              children: [
                // ----- RECTO -----
                pw.Container(
                  width: _cardWidth,
                  height: _cardHeight,
                  decoration: pw.BoxDecoration(
                    borderRadius: pw.BorderRadius.circular(16),
                    gradient: pw.LinearGradient(
                      colors: [couleur, PdfColors.green900],
                      begin: pw.Alignment.topLeft,
                      end: pw.Alignment.bottomRight,
                    ),
                  ),
                  padding: const pw.EdgeInsets.all(20),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            "SenTontine",
                            style: pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 18,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          pw.Text(
                            "CARTE MEMBRE",
                            style: pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 10,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                      pw.Spacer(),
                      pw.Row(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          // Avatar (initiales)
                          pw.Container(
                            width: 56,
                            height: 56,
                            decoration: pw.BoxDecoration(
                              color: PdfColors.white,
                              shape: pw.BoxShape.circle,
                            ),
                            child: pw.Center(
                              child: pw.Text(
                                initiales,
                                style: pw.TextStyle(
                                  color: couleur,
                                  fontSize: 22,
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          pw.SizedBox(width: 14),
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  nom,
                                  style: pw.TextStyle(
                                    color: PdfColors.white,
                                    fontSize: 15,
                                    fontWeight: pw.FontWeight.bold,
                                  ),
                                ),
                                pw.SizedBox(height: 3),
                                pw.Text(
                                  tontineNom,
                                  style: pw.TextStyle(
                                    color: PdfColors.white,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 14),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            "N° membre : $id",
                            style: pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 9,
                            ),
                          ),
                          pw.Text(
                            "$dateDebut → $dateFin",
                            style: pw.TextStyle(
                              color: PdfColors.white,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                pw.SizedBox(height: 40),

                // ----- VERSO -----
                pw.Container(
                  width: _cardWidth,
                  height: _cardHeight,
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    border: pw.Border.all(color: couleur, width: 1.5),
                    borderRadius: pw.BorderRadius.circular(16),
                  ),
                  padding: const pw.EdgeInsets.all(16),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        "Règlement intérieur (résumé)",
                        style: pw.TextStyle(
                          fontSize: 11,
                          fontWeight: pw.FontWeight.bold,
                          color: couleur,
                        ),
                      ),
                      pw.SizedBox(height: 6),
                      pw.Expanded(
                        child: pw.Text(
                          reglementResume,
                          style: const pw.TextStyle(fontSize: 8),
                        ),
                      ),
                      pw.Divider(color: PdfColors.grey400),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text(
                            "Cette carte est la propriété de SenTontine.",
                            style: pw.TextStyle(
                              fontSize: 7,
                              color: PdfColors.grey600,
                              fontStyle: pw.FontStyle.italic,
                            ),
                          ),
                          pw.Text(
                            "Signature admin : ______________",
                            style: const pw.TextStyle(fontSize: 8),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    return pdf;
  }

  static Future<void> shareCard(
    Map<String, dynamic> membre,
    Map<String, dynamic>? tontine,
  ) async {
    final pdf = await buildCard(membre, tontine);
    final id = membre["id"]?.toString() ?? "membre";
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: "carte_membre_$id.pdf",
    );
  }
}
