import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  final Map<String, dynamic> dashboardData;

  const Dashboard({super.key, required this.dashboardData});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  Widget build(BuildContext context) {
    final data = widget.dashboardData;
    final userName = data['user']?['name'] ?? 'Utilisateur';
    final totalRendezVous = data['total_rendez_vous'] ?? 0;
    final totalClients = data['total_clients'] ?? 0;
    final rendezVousAujourdhui = data['rendez_vous_aujourdhui'] ?? 0;
    final rendezVousPlanifies = data['rendez_vous_planifies'] ?? 0;
    final rendezVousConfirmes = data['rendez_vous_confirmes'] ?? 0;
    final rendezVousTermines = data['rendez_vous_termines'] ?? 0;
    final rendezVousAnnules = data['rendez_vous_annules'] ?? 0;
    final rendezVousRecents =
        (data['rendez_vous_recents'] as List<dynamic>?) ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF152895),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Dashboard',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person, color: Colors.white, size: 28),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card de bienvenue
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Color(0xFF152895),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF152895).withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -20,
                    top: -20,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 40,
                    bottom: -30,
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.account_circle,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bonjour,',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.8),
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  userName,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Aujourd\'hui, vous avez',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      // Row(
                      //   children: [
                      //     Text(
                      //       '$rendezVousAujourdhui',
                      //       style: TextStyle(
                      //         color: Colors.white,
                      //         fontSize: 36,
                      //         fontWeight: FontWeight.bold,
                      //       ),
                      //     ),
                      //     // SizedBox(width: 8),
                      //     // Text(
                      //     //   'rendez-vous',
                      //     //   style: TextStyle(
                      //     //     color: Colors.white.withValues(alpha: 0.9),
                      //     //     fontSize: 18,
                      //     //   ),
                      //     // ),
                      //   ],
                      // ),
                      // SizedBox(height: 16),
                      // Container(
                      //   padding: EdgeInsets.symmetric(
                      //     horizontal: 16,
                      //     vertical: 12,
                      //   ),
                      //   decoration: BoxDecoration(
                      //     color: Colors.white.withValues(alpha: 0.15),
                      //     borderRadius: BorderRadius.circular(12),
                      //     border: Border.all(
                      //       color: Colors.white.withValues(alpha: 0.3),
                      //       width: 1,
                      //     ),
                      //   ),
                      //   // child: Row(
                      //   //   children: [
                      //   //     Icon(
                      //   //       Icons.trending_up,
                      //   //       color: Colors.white,
                      //   //       size: 20,
                      //   //     ),
                      //   //     SizedBox(width: 12),
                      //   //     Expanded(
                      //   //       child: Text(
                      //   //         'Total de $totalRendezVous rendez-vous et $totalClients clients',
                      //   //         style: TextStyle(
                      //   //           color: Colors.white,
                      //   //           fontSize: 14,
                      //   //         ),
                      //   //       ),
                      //   //     ),
                      //   //   ],
                      //   // ),
                      // ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // 4 Cards de statistiques
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    Icons.calendar_month,
                    'Total RDV',
                    '$totalRendezVous',
                    Colors.white,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    Icons.event_available,
                    'Planifiés',
                    '$rendezVousPlanifies',
                    Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    Icons.today,
                    "Aujourd'hui",
                    '$rendezVousAujourdhui',
                    Colors.white,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    Icons.cancel,
                    'Annulés',
                    '$rendezVousAnnules',
                    Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    Icons.check_circle,
                    'Confirmés',
                    '$rendezVousConfirmes',
                    Colors.white,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    Icons.done_all,
                    'Terminés',
                    '$rendezVousTermines',
                    Colors.white,
                  ),
                ),
              ],
            ),

            SizedBox(height: 24),

            // Titre des rendez-vous récents
            Text(
              'Rendez-vous récents',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF152895),
              ),
            ),
            SizedBox(height: 16),

            // Liste des rendez-vous récents
            ...rendezVousRecents.map((rdv) {
              final client = rdv['client'] as Map<String, dynamic>?;
              final clientName = client != null
                  ? '${client['nom'] ?? ''} ${client['prenom'] ?? ''}'.trim()
                  : 'Client inconnu';
              final objet = rdv['objet'] ?? 'Sans objet';
              final date = rdv['date_rendez_vous'] ?? '';
              final heureDebut = rdv['heure_debut'] ?? '';
              final statut = rdv['statut'] ?? 'inconnu';

              return _buildActivityItem(
                _getStatusIcon(statut),
                objet,
                clientName,
                '${_formatDate(date)} à ${_formatTime(heureDebut)}',
                statut,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(0xFF152895),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(title, style: TextStyle(fontSize: 10, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    IconData icon,
    String title,
    String subtitle,
    String time,
    String statut,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getStatusColor(statut).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: _getStatusColor(statut), size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
              SizedBox(height: 4),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(statut).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _capitalize(statut),
                  style: TextStyle(
                    fontSize: 10,
                    color: _getStatusColor(statut),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(String statut) {
    switch (statut.toLowerCase()) {
      case 'planifie':
        return Icons.calendar_today;
      case 'confirme':
        return Icons.check_circle;
      case 'termine':
        return Icons.done_all;
      case 'annule':
        return Icons.cancel;
      default:
        return Icons.event;
    }
  }

  Color _getStatusColor(String statut) {
    switch (statut.toLowerCase()) {
      case 'planifie':
        return Colors.blue;
      case 'confirme':
        return Colors.green;
      case 'termine':
        return Colors.grey;
      case 'annule':
        return Colors.red;
      default:
        return Color(0xFF152895);
    }
  }

  String _formatDate(String dateStr) {
    if (dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }

  String _formatTime(String timeStr) {
    if (timeStr.isEmpty) return '';
    try {
      final parts = timeStr.split(':');
      if (parts.length >= 2) {
        return '${parts[0]}:${parts[1]}';
      }
      return timeStr;
    } catch (e) {
      return timeStr;
    }
  }

  String _capitalize(String text) {
    if (text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}
