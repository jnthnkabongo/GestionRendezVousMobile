import 'package:flutter/material.dart';
import '../services/service_application.dart';

class Dashboard extends StatefulWidget {
  final Map<String, dynamic> dashboardData;
  final Future<void> Function()? onRefresh;

  const Dashboard({super.key, required this.dashboardData, this.onRefresh});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Text controllers
  final _objetController = TextEditingController();
  final _dateController = TextEditingController();
  final _heureDebutController = TextEditingController();
  final _heureFinController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _rappelMinutesController = TextEditingController(text: '30');

  // Dropdown values
  String? _selectedClientId;
  String? _selectedStatut = 'planifie';
  String? _selectedType = 'interieur';

  // Clients list
  List<dynamic> _clients = [];
  bool _isLoadingClients = false;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fetchClients();
  }

  @override
  void dispose() {
    _objetController.dispose();
    _dateController.dispose();
    _heureDebutController.dispose();
    _heureFinController.dispose();
    _descriptionController.dispose();
    _rappelMinutesController.dispose();
    super.dispose();
  }

  Future<void> _fetchClients() async {
    try {
      final response = await ApiService.getListeInvites();
      if (response['success'] == true && response['data'] != null) {
        setState(() {
          _clients = response['data'];
        });
      }
    } catch (e) {
      print('Error fetching clients: $e');
    }
  }

  void _resetForm() {
    _objetController.clear();
    _dateController.clear();
    _heureDebutController.clear();
    _heureFinController.clear();
    _descriptionController.clear();
    _rappelMinutesController.text = '30';
    setState(() {
      _selectedClientId = null;
      _selectedStatut = 'planifie';
      _selectedType = 'interieur';
    });
    _formKey.currentState?.reset();
  }

  Future<void> _createRendezVous() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final rendezVousData = {
      'objet': _objetController.text,
      'date_rendez_vous': _dateController.text,
      'heure_debut': _heureDebutController.text,
      'heure_fin': _heureFinController.text,
      'client_id': _selectedClientId,
      'statut': _selectedStatut,
      'type_rendez_vous': _selectedType,
      'description': _descriptionController.text,
      'rappel_active': true,
      'rappel_minutes': int.tryParse(_rappelMinutesController.text) ?? 30,
    };

    try {
      await ApiService.createRendezVous(rendezVousData);
      _resetForm();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rendez-vous créé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        // Refresh the dashboard
        if (widget.onRefresh != null) {
          widget.onRefresh!();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _dateController.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _selectTime(String controllerType) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (controllerType == 'debut') {
          _heureDebutController.text =
              '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}:00';
        } else {
          _heureFinController.text =
              '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}:00';
        }
      });
    }
  }

  void _showCreateRendezVousModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        minChildSize: 0.5,
        maxChildSize: 0.85,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Color(0xFF152895),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Nouveau Rendez-vous',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              // Form
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Objet
                        TextFormField(
                          controller: _objetController,
                          decoration: InputDecoration(
                            labelText: 'Objet',
                            hintText: 'Ex: Réunion importante',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.event),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer l\'objet';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),

                        // Date
                        TextFormField(
                          controller: _dateController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Date',
                            hintText: 'Sélectionner la date',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_today),
                            suffixIcon: Icon(Icons.calendar_month),
                          ),
                          onTap: _selectDate,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez sélectionner la date';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),

                        // Heures
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _heureDebutController,
                                readOnly: true,
                                decoration: InputDecoration(
                                  labelText: 'Heure début',
                                  hintText: '08:00',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.access_time),
                                ),
                                onTap: () => _selectTime('debut'),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Requis';
                                  }
                                  return null;
                                },
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _heureFinController,
                                readOnly: true,
                                decoration: InputDecoration(
                                  labelText: 'Heure fin',
                                  hintText: '09:00',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.access_time),
                                ),
                                onTap: () => _selectTime('fin'),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Requis';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),

                        // Client
                        DropdownButtonFormField<String>(
                          value: _selectedClientId,
                          decoration: InputDecoration(
                            labelText: 'Invité',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                          items: _clients.map((client) {
                            return DropdownMenuItem<String>(
                              value: client['id'].toString(),
                              child: Text(
                                '${client['nom']} ${client['prenom']}',
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedClientId = value);
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Veuillez sélectionner un invité';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),

                        // Statut
                        DropdownButtonFormField<String>(
                          value: _selectedStatut,
                          decoration: InputDecoration(
                            labelText: 'Statut',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.info),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'planifie',
                              child: Text('Planifié'),
                            ),
                            DropdownMenuItem(
                              value: 'confirme',
                              child: Text('Confirmé'),
                            ),
                            DropdownMenuItem(
                              value: 'termine',
                              child: Text('Terminé'),
                            ),
                            DropdownMenuItem(
                              value: 'annule',
                              child: Text('Annulé'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() => _selectedStatut = value);
                          },
                        ),
                        SizedBox(height: 10),

                        // Type
                        DropdownButtonFormField<String>(
                          value: _selectedType,
                          decoration: InputDecoration(
                            labelText: 'Type',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.location_on),
                          ),
                          items: [
                            DropdownMenuItem(
                              value: 'interieur',
                              child: Text('Intérieur'),
                            ),
                            DropdownMenuItem(
                              value: 'exterieur',
                              child: Text('Extérieur'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() => _selectedType = value);
                          },
                        ),
                        SizedBox(height: 10),

                        // Description
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: 'Description (optionnel)',
                            hintText: 'Description du rendez-vous...',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.description),
                          ),
                        ),
                        SizedBox(height: 10),

                        TextFormField(
                          controller: _rappelMinutesController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Minutes avant le rappel',
                            hintText: '30',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.timer),
                            helperText:
                                'Notification envoyée avant le rendez-vous',
                          ),
                          validator: (value) {
                            final minutes = int.tryParse(value ?? '');
                            if (minutes == null || minutes < 1) {
                              return 'Entrez un nombre de minutes valide';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 20),

                        // Submit button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _createRendezVous,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF152895),
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isSubmitting
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'Créer le Rendez-vous',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.dashboardData;
    final userName = data['user']?['name'] ?? 'Utilisateur';
    final totalRendezVous = data['total_rendez_vous'] ?? 0;
    final rendezVousAujourdhui = data['rendez_vous_aujourdhui'] ?? 0;
    final rendezVousPlanifies = data['rendez_vous_planifies'] ?? 0;
    final rendezVousConfirmes = data['rendez_vous_confirmes'] ?? 0;
    final rendezVousTermines = data['rendez_vous_termines'] ?? 0;
    final rendezVousAnnules = data['rendez_vous_annules'] ?? 0;
    final rendezVousRecents =
        (data['rendez_vous_recents'] as List<dynamic>?) ?? [];

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreateRendezVousModal,
        backgroundColor: Color(0xFF152895),
        child: Icon(Icons.add, color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: widget.onRefresh ?? () async {},
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  margin: EdgeInsets.only(bottom: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Dashboard',
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
                        child: Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                    ],
                  ),
                ),
                // Card de bienvenue
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
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
                                        color: Colors.white.withValues(
                                          alpha: 0.8,
                                        ),
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
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 16),

                // Liste des rendez-vous récents
                ...rendezVousRecents.map((rdv) {
                  final client = rdv['client'] as Map<String, dynamic>?;
                  final clientName = client != null
                      ? '${client['nom'] ?? ''} ${client['prenom'] ?? ''}'
                            .trim()
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
        color: Colors.white.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Color(0xFF152895).withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: Color(0xFF152895), size: 28),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF152895),
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Text(title, style: TextStyle(fontSize: 10, color: Color(0xFF152895))),
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
        color: Colors.white.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFFB8860B).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Color(0xFFB8860B), size: 24),
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
                    color: Color(0xFFB8860B),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Color(0xFFB8860B).withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFFB8860B).withValues(alpha: 0.6),
                ),
              ),
              SizedBox(height: 4),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Color(0xFFB8860B).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _capitalize(statut),
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFFB8860B),
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
