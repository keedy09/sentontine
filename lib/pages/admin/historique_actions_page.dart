import 'package:flutter/material.dart';
import '../../database/database_helper.dart';

/// Page d'historique des actions admin (Audit Trail)
class HistoriqueActionsPage extends StatefulWidget {
  const HistoriqueActionsPage({super.key});

  @override
  State<HistoriqueActionsPage> createState() => _HistoriqueActionsPageState();
}

class _HistoriqueActionsPageState extends State<HistoriqueActionsPage> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<Map<String, dynamic>> _actions = [];
  String _filtreType = "Tous";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _chargerActions();
  }

  Future<void> _chargerActions() async {
    setState(() => _isLoading = true);

    if (_filtreType == "Tous") {
      _actions = await _db.getActionsLog();
    } else {
      _actions = await _db.getActionsLogByType(_filtreType);
    }

    setState(() => _isLoading = false);
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'Tontine':
        return Icons.group_work;
      case 'Membre':
        return Icons.person;
      case 'Paiement':
        return Icons.payments;
      case 'Tirage':
        return Icons.casino;
      default:
        return Icons.history;
    }
  }

  Color _getColorForType(String type) {
    switch (type) {
      case 'Tontine':
        return Colors.green;
      case 'Membre':
        return Colors.blue;
      case 'Paiement':
        return Colors.orange;
      case 'Tirage':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // En-tête avec statistiques
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00853F), Color(0xFF005C2E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              children: [
                const Row(
                  children: [
                    Icon(Icons.history, color: Colors.white, size: 32),
                    SizedBox(width: 12),
                    Text(
                      "Historique des Actions",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "${_actions.length} action(s) enregistrée(s)",
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Filtres
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip("Tous"),
                  const SizedBox(width: 8),
                  _buildFilterChip("Tontine"),
                  const SizedBox(width: 8),
                  _buildFilterChip("Membre"),
                  const SizedBox(width: 8),
                  _buildFilterChip("Paiement"),
                  const SizedBox(width: 8),
                  _buildFilterChip("Tirage"),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Liste des actions
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _actions.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
              onRefresh: _chargerActions,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _actions.length,
                itemBuilder: (context, index) {
                  final action = _actions[index];
                  return _buildActionCard(action);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _filtreType == label;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _filtreType = label;
        });
        _chargerActions();
      },
      selectedColor: const Color(0xFF00853F).withValues(alpha: 0.2),
      checkmarkColor: const Color(0xFF00853F),
      backgroundColor: Colors.grey[200],
    );
  }

  Widget _buildActionCard(Map<String, dynamic> action) {
    final type = action['typeAction'] as String;
    final color = _getColorForType(type);
    final icon = _getIconForType(type);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icône
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),

            // Contenu
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Action
                  Text(
                    action['action'],
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Admin
                  Row(
                    children: [
                      const Icon(Icons.person, size: 14, color: Colors.black54),
                      const SizedBox(width: 4),
                      Text(
                        action['adminNom'],
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 4),

                  // Date
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 14, color: Colors.black54),
                      const SizedBox(width: 4),
                      Text(
                        action['date'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),

                  // Détails (si présents)
                  if (action['details'] != null && action['details'].toString().isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        action['details'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black87,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Badge type
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                type,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_outlined,
            size: 100,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 20),
          Text(
            "Aucune action enregistrée",
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Les actions des administrateurs\nseront affichées ici",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}