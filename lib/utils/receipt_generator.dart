import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

/// Génère et permet de partager/imprimer/télécharger un reçu de paiement
/// au format PDF pour un paiement de tontine.
class ReceiptGenerator {
  /// Construit le document PDF du reçu à partir des informations du
  /// paiement. Les champs attendus dans [paiement] sont :
  /// id, date, membreNom, tontineNom, montant, statut.
  static Future<pw.Document> buildReceipt(
    Map<String, dynamic> paiement,
  ) async {
    final pdf = pw.Document();

    final id = paiement["id"]?.toString() ?? "";
    final date = paiement["date"]?.toString() ?? "";
    final membreNom = paiement["membreNom"]?.toString() ?? "";
    final tontineNom = paiement["tontineNom"]?.toString() ?? "";
    final montant = paiement["montant"]?.toString() ?? "0";
    final statut = paiement["statut"]?.toString() ?? "";

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(32),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // En-tête
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      "SenTontine",
                      style: pw.TextStyle(
                        fontSize: 26,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromHex("#00853F"),
                      ),
                    ),
                    pw.Text(
                      "Reçu de paiement",
                      style: pw.TextStyle(
                        fontSize: 16,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 4),
                pw.Divider(thickness: 1.5, color: PdfColor.fromHex("#00853F")),
                pw.SizedBox(height: 24),

                // Numéro et date du reçu
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text("Référence du reçu : $id"),
                    pw.Text("Date du paiement : $date"),
                  ],
                ),
                pw.SizedBox(height: 24),

                // Détails du paiement
                pw.Container(
                  width: double.infinity,
                  padding: const pw.EdgeInsets.all(16),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey100,
                    borderRadius: pw.BorderRadius.circular(8),
                  ),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      _ligneDetail("Membre", membreNom),
                      pw.SizedBox(height: 10),
                      _ligneDetail("Tontine", tontineNom),
                      pw.SizedBox(height: 10),
                      _ligneDetail("Montant", "$montant FCFA"),
                      pw.SizedBox(height: 10),
                      _ligneDetail("Statut", statut),
                    ],
                  ),
                ),
                pw.SizedBox(height: 32),

                pw.Text(
                  "Ce reçu atteste que le paiement ci-dessus a été enregistré "
                  "dans le système SenTontine. Chaque opération est "
                  "conservée dans le journal d'audit de l'application afin "
                  "de garantir la traçabilité et la transparence de la "
                  "gestion de la tontine.",
                  style: pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey600,
                  ),
                ),
                pw.SizedBox(height: 40),

                pw.Divider(color: PdfColors.grey300),
                pw.Center(
                  child: pw.Text(
                    "Document généré automatiquement par l'application SenTontine",
                    style: pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.grey500,
                      fontStyle: pw.FontStyle.italic,
                    ),
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

  static pw.Widget _ligneDetail(String label, String valeur) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: pw.TextStyle(
            color: PdfColors.grey700,
            fontSize: 12,
          ),
        ),
        pw.Text(
          valeur,
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Ouvre la boîte de dialogue native de partage/impression/téléchargement
  /// du reçu PDF. Sur mobile, cela permet d'enregistrer le fichier ou de le
  /// partager (WhatsApp, email, etc.). Sur desktop/web, cela déclenche le
  /// téléchargement du fichier.
  static Future<void> shareReceipt(Map<String, dynamic> paiement) async {
    final pdf = await buildReceipt(paiement);
    final id = paiement["id"]?.toString() ?? "recu";
    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: "recu_paiement_$id.pdf",
    );
  }
}
