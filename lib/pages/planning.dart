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

  // Formulaire de modification
  final _editFormKey = GlobalKey<FormState>();
  final _editObjetController = TextEditingController();
  final _editDateController = TextEditingController();
  final _editHeureDebutController = TextEditingController();
  final _editHeureFinController = TextEditingController();
  final _editDescriptionController = TextEditingController();
  final _editRappelController = TextEditingController(text: '30');
  String? _editClientId;
  String _editStatut = 'planifie';
  String _editType = 'interieur';
  String? _editingRdvId;
  bool _isSubmittingEdit = false;
  List<dynamic> _clients = [];

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('fr_FR', null).then((_) {
      fetchRendezVous();
    });
    searchController.addListener(_filterRendezVous);
    _fetchClients();
  }

  @override
  void dispose() {
    searchController.dispose();
    _editObjetController.dispose();
    _editDateController.dispose();
    _editHeureDebutController.dispose();
    _editHeureFinController.dispose();
    _editDescriptionController.dispose();
    _editRappelController.dispose();
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

  Future<void> _selectEditDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(Duration(days: 3650)),
    );
    if (picked != null) {
      setState(() {
        _editDateController.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _selectEditTime(TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        controller.text =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}:00';
      });
    }
  }

  void _openEditModal(Map<String, dynamic> rdv) {
    _editingRdvId = rdv['id']?.toString();
    _editObjetController.text = rdv['objet'] ?? '';
    _editDescriptionController.text = rdv['description'] ?? '';
    _editRappelController.text = (rdv['rappel_minutes'] ?? 30).toString();
    _editClientId =
        rdv['client_id']?.toString() ?? rdv['client']?['id']?.toString();
    _editStatut = rdv['statut'] ?? 'planifie';
    _editType = rdv['type_rendez_vous'] ?? 'interieur';

    final dateStr = rdv['date_rendez_vous']?.toString() ?? '';
    _editDateController.text = dateStr.split(RegExp(r'[T\s]'))[0];
    _editHeureDebutController.text = (rdv['heure_debut'] ?? '')
        .toString()
        .substring(
          0,
          (rdv['heure_debut'] ?? '').toString().length >= 5 ? 5 : 0,
        );
    _editHeureFinController.text = (rdv['heure_fin'] ?? '')
        .toString()
        .substring(0, (rdv['heure_fin'] ?? '').toString().length >= 5 ? 5 : 0);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF152895),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Modifier le Rendez-vous',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(sheetContext),
                    ),
                  ],
                ),
              ),
              // Formulaire
              Expanded(
                child: Form(
                  key: _editFormKey,
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Invité
                        DropdownButtonFormField<String>(
                          initialValue: _editClientId,
                          decoration: InputDecoration(
                            labelText: 'Invité',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                          items: () {
                            final items = _clients.map((client) {
                              return DropdownMenuItem<String>(
                                value: client['id'].toString(),
                                child: Text(
                                  '${client['nom']} ${client['prenom']}',
                                ),
                              );
                            }).toList();
                            final ids = _clients
                                .map((c) => c['id'].toString())
                                .toList();
                            if (_editClientId != null &&
                                !ids.contains(_editClientId)) {
                              items.add(
                                DropdownMenuItem<String>(
                                  value: _editClientId,
                                  child: Text('Invité #$_editClientId'),
                                ),
                              );
                            }
                            return items;
                          }(),
                          onChanged: (value) =>
                              setState(() => _editClientId = value),
                          validator: (value) => value == null
                              ? 'Veuillez sélectionner un invité'
                              : null,
                        ),
                        SizedBox(height: 10),

                        // Objet
                        TextFormField(
                          controller: _editObjetController,
                          decoration: InputDecoration(
                            labelText: 'Objet',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.event),
                          ),
                          validator: (value) => (value == null || value.isEmpty)
                              ? 'Veuillez entrer l\'objet'
                              : null,
                        ),
                        SizedBox(height: 10),

                        // Date
                        TextFormField(
                          controller: _editDateController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText: 'Date',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_today),
                            suffixIcon: Icon(Icons.calendar_month),
                          ),
                          onTap: _selectEditDate,
                          validator: (value) => (value == null || value.isEmpty)
                              ? 'Veuillez sélectionner la date'
                              : null,
                        ),
                        SizedBox(height: 10),

                        // Heures
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _editHeureDebutController,
                                readOnly: true,
                                decoration: InputDecoration(
                                  labelText: 'Heure début',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.access_time),
                                ),
                                onTap: () =>
                                    _selectEditTime(_editHeureDebutController),
                                validator: (value) =>
                                    (value == null || value.isEmpty)
                                    ? 'Requis'
                                    : null,
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _editHeureFinController,
                                readOnly: true,
                                decoration: InputDecoration(
                                  labelText: 'Heure fin',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.access_time),
                                ),
                                onTap: () =>
                                    _selectEditTime(_editHeureFinController),
                                validator: (value) =>
                                    (value == null || value.isEmpty)
                                    ? 'Requis'
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),

                        // Statut
                        DropdownButtonFormField<String>(
                          initialValue: _editStatut,
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
                          onChanged: (value) =>
                              setState(() => _editStatut = value ?? 'planifie'),
                        ),
                        SizedBox(height: 10),

                        // Type
                        DropdownButtonFormField<String>(
                          initialValue: _editType,
                          decoration: InputDecoration(
                            labelText: 'Type',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.category),
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
                          onChanged: (value) =>
                              setState(() => _editType = value ?? 'interieur'),
                        ),
                        SizedBox(height: 10),

                        // Description
                        TextFormField(
                          controller: _editDescriptionController,
                          maxLines: 3,
                          decoration: InputDecoration(
                            labelText: 'Description (optionnel)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.description),
                          ),
                        ),
                        SizedBox(height: 10),

                        // Rappel
                        TextFormField(
                          controller: _editRappelController,
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

                        // Bouton de soumission
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSubmittingEdit ? null : _submitEdit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF152895),
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isSubmittingEdit
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'Enregistrer',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(height: 20),
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

  Future<void> _submitEdit() async {
    if (_isSubmittingEdit || _editingRdvId == null) return;
    if (!_editFormKey.currentState!.validate()) return;

    setState(() => _isSubmittingEdit = true);

    final data = {
      'objet': _editObjetController.text,
      'date_rendez_vous': _editDateController.text,
      'heure_debut': _editHeureDebutController.text.length == 5
          ? '${_editHeureDebutController.text}:00'
          : _editHeureDebutController.text,
      'heure_fin': _editHeureFinController.text.length == 5
          ? '${_editHeureFinController.text}:00'
          : _editHeureFinController.text,
      'client_id': _editClientId,
      'statut': _editStatut,
      'type_rendez_vous': _editType,
      'description': _editDescriptionController.text,
      'rappel_active': true,
      'rappel_minutes': int.tryParse(_editRappelController.text) ?? 30,
    };

    try {
      await ApiService.updateRendezVous(_editingRdvId!, data);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rendez-vous modifié avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        fetchRendezVous();
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
        setState(() => _isSubmittingEdit = false);
      }
    }
  }

  void _confirmDelete(Map<String, dynamic> rdv) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Supprimer le rendez-vous'),
        content: Text(
          'Voulez-vous vraiment supprimer "${rdv['objet'] ?? 'ce rendez-vous'}" ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _deleteRendezVous(rdv['id'].toString());
            },
            child: Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteRendezVous(String id) async {
    try {
      await ApiService.deleteRendezVous(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Rendez-vous supprimé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        fetchRendezVous();
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
                    'Planning',
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
                  hintText: 'Rechercher un planning...',
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
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                          SizedBox(height: 16),
                          Text(
                            searchController.text.isEmpty
                                ? 'Aucun rendez-vous planifié'
                                : 'Aucun résultat',
                            style: TextStyle(fontSize: 16, color: Colors.white),
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
      ),
    );
  }

  Widget _buildPlanningCard(Map<String, dynamic> rdv) {
    final client = rdv['client'] ?? {};
    final clientName = '${client['nom'] ?? ''} ${client['prenom'] ?? ''}'
        .trim();
    final date = _formatDate(rdv['date_rendez_vous']);
    final time = '${rdv['heure_debut'] ?? ''} - ${rdv['heure_fin'] ?? ''}';

    return Container(
      margin: EdgeInsets.only(bottom: 16),
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
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Color(0xFF152895).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.event, color: Color(0xFF152895), size: 22),
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
                    color: Color(0xFF152895),
                  ),
                ),
                SizedBox(height: 4),
                if (clientName.isNotEmpty)
                  Text(
                    clientName,
                    style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFF152895).withValues(alpha: 0.7),
                    ),
                  ),
                SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      date,
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF152895).withValues(alpha: 0.6),
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF152895),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: Color(0xFF152895)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            onSelected: (value) {
              if (value == 'modifier') {
                _openEditModal(rdv);
              } else if (value == 'supprimer') {
                _confirmDelete(rdv);
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<String>(
                value: 'modifier',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 20, color: Color(0xFF152895)),
                    SizedBox(width: 8),
                    Text('Modifier'),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'supprimer',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Supprimer', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
