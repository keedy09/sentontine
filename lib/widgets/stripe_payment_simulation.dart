import 'package:flutter/material.dart';

/// Widget qui simule l'interface de paiement Stripe
/// Apparence réaliste mais aucune vraie transaction
class StripePaymentSimulation extends StatefulWidget {
  final Map<String, dynamic> paiement;
  final VoidCallback onPaymentSuccess;
  final VoidCallback onPaymentCancel;

  const StripePaymentSimulation({
    super.key,
    required this.paiement,
    required this.onPaymentSuccess,
    required this.onPaymentCancel,
  });

  @override
  State<StripePaymentSimulation> createState() =>
      _StripePaymentSimulationState();
}

class _StripePaymentSimulationState extends State<StripePaymentSimulation> {
  final _cardNumberController =
      TextEditingController(text: "4242 4242 4242 4242");
  final _expiryController = TextEditingController(text: "12/25");
  final _cvvController = TextEditingController(text: "123");
  final _nameController = TextEditingController(text: "Awa Diop");

  bool _isProcessing = false;
  bool _showSuccess = false;

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // Simuler le processus de paiement (3 secondes)
  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);

    // Simulation : vérification des données (1 sec)
    await Future.delayed(const Duration(milliseconds: 1000));

    // Simulation : connexion à Stripe (1 sec)
    await Future.delayed(const Duration(milliseconds: 1000));

    // Simulation : validation du paiement (1 sec)
    await Future.delayed(const Duration(milliseconds: 1000));

    setState(() {
      _isProcessing = false;
      _showSuccess = true;
    });

    // Afficher le succès pendant 2 secondes
    await Future.delayed(const Duration(seconds: 2));

    // Appeler le callback de succès
    widget.onPaymentSuccess();
  }

  @override
  Widget build(BuildContext context) {
    if (_showSuccess) {
      return _buildSuccessScreen();
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête Stripe
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF635BFF),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      "stripe",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: _isProcessing ? null : widget.onPaymentCancel,
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Badge "Mode Test"
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.orange),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.science, size: 14, color: Colors.orange),
                    SizedBox(width: 4),
                    Text(
                      "MODE TEST - Simulation",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Montant à payer
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Paiement pour",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.paiement["tontineNom"],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Montant total",
                          style: TextStyle(fontSize: 14),
                        ),
                        Text(
                          "${widget.paiement["montant"]} FCFA",
                          style: const TextStyle(
                            fontSize: 20,
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

              // Formulaire de carte
              const Text(
                "Informations de carte",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Numéro de carte
              TextField(
                controller: _cardNumberController,
                enabled: !_isProcessing,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Numéro de carte",
                  hintText: "4242 4242 4242 4242",
                  prefixIcon: const Icon(Icons.credit_card),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Expiration et CVV
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _expiryController,
                      enabled: !_isProcessing,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "MM/AA",
                        hintText: "12/25",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _cvvController,
                      enabled: !_isProcessing,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      maxLength: 3,
                      decoration: InputDecoration(
                        labelText: "CVV",
                        hintText: "123",
                        counterText: "",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Nom sur la carte
              TextField(
                controller: _nameController,
                enabled: !_isProcessing,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: "Nom sur la carte",
                  hintText: "Awa Diop",
                  prefixIcon: const Icon(Icons.person),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Message de sécurité
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lock, size: 16, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Paiement sécurisé par Stripe (simulation)",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Bouton de paiement
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isProcessing ? null : _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF635BFF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: _isProcessing
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              "Traitement en cours...",
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        )
                      : Text(
                          "Payer ${widget.paiement["montant"]} FCFA",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Bouton annuler
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: _isProcessing ? null : widget.onPaymentCancel,
                  child: const Text("Annuler"),
                ),
              ),

              const SizedBox(height: 16),

              // Powered by Stripe
              Center(
                child: Text(
                  "Powered by Stripe (Test Mode)",
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Écran de succès
  Widget _buildSuccessScreen() {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(32),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animation de succès
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.green[100],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 60,
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              "Paiement effectué !",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),

            const SizedBox(height: 12),

            Text(
              "${widget.paiement["montant"]} FCFA",
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              "pour ${widget.paiement["tontineNom"]}",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Transaction ID"),
                      Text(
                        "TXN${DateTime.now().millisecondsSinceEpoch}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Statut"),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "Payé",
                          style: TextStyle(
                            color: Colors.green,
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

            const SizedBox(height: 24),

            const Text(
              "L'administrateur sera notifié de votre paiement",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
