import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../services/service_application.dart';

class RendezVous extends StatefulWidget {
  const RendezVous({super.key});

  @override
  State<RendezVous> createState() => _RendezVousState();
}

class _RendezVousState extends State<RendezVous> {
  List<dynamic> rendezVousList = [];
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
        filteredRendezVousList = rendezVousList;
      } else {
        filteredRendezVousList = rendezVousList.where((rdv) {
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
      final data = await ApiService.getListeRendezVous();
      if (data['rendez_vous'] != null) {
        setState(() {
          rendezVousList = data['rendez_vous'];
          filteredRendezVousList = data['rendez_vous'];
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
      // Extraire seulement la partie date (avant le T ou l'espace)
      final dateOnly = dateString.split(RegExp(r'[T\s]'))[0];
      // Parser la date
      final date = DateTime.parse(dateOnly);
      // Formater en français
      return DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(date);
    } catch (e) {
      print('Error formatting date: $e - dateString: $dateString');
      return dateString;
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
              'Rendez-vous',
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
          SizedBox(height: 4),

          // Barre de recherche
          Container(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher un rendez-vous...',
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

          // Liste de rendez-vous
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
                          size: 44,
                          color: Colors.grey[300],
                        ),
                        SizedBox(height: 16),
                        Text(
                          searchController.text.isEmpty
                              ? 'Aucun rendez-vous'
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
                        return _buildRendezVousCard(rdv);
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Ajouter la logique pour créer un nouveau rendez-vous
        },
        backgroundColor: Color(0xFF152895),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Color _getStatusColor(String? statut) {
    switch (statut) {
      case 'planifie':
        return Color(0xFF152895);
      case 'confirme':
        return Color(0xFF152895);
      case 'termine':
        return Color(0xFF9C27B0);
      case 'annule':
        return Color(0xFFF44336);
      default:
        return Color(0xFF152895);
    }
  }

  Widget _buildRendezVousCard(Map<String, dynamic> rdv) {
    final color = _getStatusColor(rdv['statut']);
    final client = rdv['client'] ?? {};
    final clientName = '${client['nom'] ?? ''} ${client['prenom'] ?? ''}'
        .trim();
    final date = _formatDate(rdv['date_rendez_vous']);
    final time = '${rdv['heure_debut'] ?? ''} - ${rdv['heure_fin'] ?? ''}';
    final rappelActive = rdv['rappel_active'] == true;
    final rappelMinutes = rdv['rappel_minutes'] ?? 0;

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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.event, color: color, size: 22),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rdv['objet'] ?? 'Sans titre',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF152895),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      clientName.isNotEmpty
                          ? clientName
                          : 'Client non spécifié',
                      style: TextStyle(fontSize: 12, color: Color(0xFF152895)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getStatusText(rdv['statut']),
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (rdv['description'] != null &&
              rdv['description'].toString().isNotEmpty) ...[
            SizedBox(height: 8),
            Text(
              rdv['description'],
              style: TextStyle(fontSize: 12, color: Color(0xFF152895)),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 12, color: Color(0xFF152895)),
              SizedBox(width: 4),
              Text(
                date,
                style: TextStyle(fontSize: 12, color: Color(0xFF152895)),
              ),
              SizedBox(width: 16),
              Icon(Icons.access_time, size: 12, color: Color(0xFF152895)),
              SizedBox(width: 4),
              Text(
                time,
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF152895),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          if (rappelActive) ...[
            SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.notifications_active,
                  size: 16,
                  color: Colors.orange,
                ),
                SizedBox(width: 4),
                Text(
                  'Rappel activé: $rappelMinutes min avant',
                  style: TextStyle(fontSize: 12, color: Colors.orange[700]),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _getStatusText(String? statut) {
    switch (statut) {
      case 'planifie':
        return 'Planifié';
      case 'confirme':
        return 'Confirmé';
      case 'termine':
        return 'Terminé';
      case 'annule':
        return 'Annulé';
      default:
        return statut ?? 'N/A';
    }
  }
}
