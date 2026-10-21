import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../services/service_application.dart';

class Planning extends StatefulWidget {
  const Planning({super.key});

  @override
  State<Planning> createState() => _PlanningState();
}

class _PlanningState extends State<Planning> {
  List<dynamic> rendezVousListPlanifies = [];
  List<dynamic> filteredRendezVousList = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR', null).then((_) {
      fetchRendezVous();
    });
    searchController.addListener(_filterRendezVous);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _filterRendezVous() {
    final query = searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredRendezVousList = rendezVousListPlanifies;
      } else {
        filteredRendezVousList = rendezVousListPlanifies.where((rdv) {
          final objet = (rdv['objet'] ?? '').toLowerCase();
          final client = rdv['client'] ?? {};
          final clientName = '${client['nom'] ?? ''} ${client['prenom'] ?? ''}'
              .toLowerCase();
          final description = (rdv['description'] ?? '').toLowerCase();
          return objet.contains(query) ||
              clientName.contains(query) ||
              description.contains(query);
        }).toList();
      }
    });
  }

  Future<void> fetchRendezVous() async {
    try {
      final data = await ApiService.getListeRendezVousPlanifies();
      if (data['rendez_vous_planifies'] != null) {
        setState(() {
          rendezVousListPlanifies = data['rendez_vous_planifies'];
          filteredRendezVousList = data['rendez_vous_planifies'];
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching rendez-vous: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '';
    try {
      final dateOnly = dateString.split(RegExp(r'[T\s]'))[0];
      final date = DateTime.parse(dateOnly);
      return DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(date);
    } catch (e) {
      return dateString;
    }
  }

  Color _getStatusColor(String? statut) {
    switch (statut) {
      case 'planifie':
        return Color(0xFF152895);
      case 'confirme':
        return Color(0xFF4CAF50);
      case 'termine':
        return Color(0xFF9C27B0);
      case 'annule':
        return Color(0xFFF44336);
      default:
        return Color(0xFF152895);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF152895),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Planning',
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
      body: Column(
        children: [
          // Barre de recherche
          Container(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un planning...',
                prefixIcon: Icon(Icons.search, color: Color(0xFF152895)),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          // Liste de planning
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredRendezVousList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.event_busy,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        SizedBox(height: 16),
                        Text(
                          searchController.text.isEmpty
                              ? 'Aucun rendez-vous planifié'
                              : 'Aucun résultat',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: fetchRendezVous,
                    child: ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      itemCount: filteredRendezVousList.length,
                      itemBuilder: (context, index) {
                        final rdv = filteredRendezVousList[index];
                        return _buildPlanningCard(rdv);
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Ajouter la logique pour créer un nouveau planning
        },
        backgroundColor: Color(0xFF152895),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildPlanningCard(Map<String, dynamic> rdv) {
    final color = _getStatusColor(rdv['statut']);
    final client = rdv['client'] ?? {};
    final clientName = '${client['nom'] ?? ''} ${client['prenom'] ?? ''}'
        .trim();
    final date = _formatDate(rdv['date_rendez_vous']);
    final time = '${rdv['heure_debut'] ?? ''} - ${rdv['heure_fin'] ?? ''}';

    return Container(
      margin: EdgeInsets.only(bottom: 16),
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
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.event, color: color, size: 22),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rdv['objet'] ?? 'Sans titre',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4),
                if (clientName.isNotEmpty)
                  Text(
                    clientName,
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      date,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 12,
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
