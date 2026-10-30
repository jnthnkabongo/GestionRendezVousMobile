import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../services/service_application.dart';

class Visites extends StatefulWidget {
  const Visites({super.key});

  @override
  State<Visites> createState() => _VisitesState();
}

class _VisitesState extends State<Visites> {
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
      final data = await ApiService.getListeRendezVousTermines();
      if (data['rendez_vous_termines'] != null) {
        setState(() {
          rendezVousList = data['rendez_vous_termines'];
          filteredRendezVousList = data['rendez_vous_termines'];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.only(top: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Visites',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
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
            // Barre de recherche
            Container(
              padding: EdgeInsets.all(16),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: 'Rechercher une visite...',
                  prefixIcon: Icon(Icons.search, color: Color(0xFF152895)),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.5),
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
            // Liste de visites
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
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                          SizedBox(height: 16),
                          Text(
                            searchController.text.isEmpty
                                ? 'Aucune visite'
                                : 'Aucun résultat',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
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
                          return _buildVisiteCard(rdv);
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // TODO: Ajouter la logique pour créer une nouvelle visite
      //   },
      //   backgroundColor: Color(0xFF152895),
      //   child: Icon(Icons.add, color: Colors.white),
      // ),
    );
  }

  Widget _buildVisiteCard(Map<String, dynamic> rdv) {
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
        color: Colors.white.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
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
                  color: Color(0xFF152895).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.location_on, color: Color(0xFF152895), size: 22),
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
                      style: TextStyle(fontSize: 12, color: Color(0xFF152895).withValues(alpha: 0.7)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Color(0xFF152895).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getStatusText(rdv['statut']),
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF152895),
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
                  color: Color(0xFF152895),
                ),
                SizedBox(width: 4),
                Text(
                  'Rappel activé: $rappelMinutes min avant',
                  style: TextStyle(fontSize: 12, color: Color(0xFF152895)),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
