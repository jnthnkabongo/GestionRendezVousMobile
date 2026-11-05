import 'package:flutter/material.dart';
import '../services/service_application.dart';

class Visites extends StatefulWidget {
  const Visites({super.key});

  @override
  State<Visites> createState() => _VisitesState();
}

class _VisitesState extends State<Visites> {
  List<dynamic> invitesList = [];
  List<dynamic> filteredInvitesList = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  // Formulaire invité
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _telephoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _adresseController = TextEditingController();
  String? _editingInviteId;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    fetchInvites();
    searchController.addListener(_filterInvites);
  }

  @override
  void dispose() {
    searchController.dispose();
    _nomController.dispose();
    _prenomController.dispose();
    _telephoneController.dispose();
    _emailController.dispose();
    _adresseController.dispose();
    super.dispose();
  }

  void _filterInvites() {
    final query = searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredInvitesList = invitesList;
      } else {
        filteredInvitesList = invitesList.where((invite) {
          final nom = (invite['nom'] ?? '').toString().toLowerCase();
          final prenom = (invite['prenom'] ?? '').toString().toLowerCase();
          final telephone = (invite['telephone'] ?? '')
              .toString()
              .toLowerCase();
          final email = (invite['email'] ?? '').toString().toLowerCase();
          return nom.contains(query) ||
              prenom.contains(query) ||
              telephone.contains(query) ||
              email.contains(query);
        }).toList();
      }
    });
  }

  Future<void> fetchInvites() async {
    try {
      final data = await ApiService.getListeInvites();
      if (data['success'] == true && data['data'] != null) {
        setState(() {
          invitesList = data['data'];
          filteredInvitesList = data['data'];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Error fetching invites: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  void _resetForm() {
    _nomController.clear();
    _prenomController.clear();
    _telephoneController.clear();
    _emailController.clear();
    _adresseController.clear();
    _editingInviteId = null;
    _formKey.currentState?.reset();
  }

  void _openInviteModal([Map<String, dynamic>? invite]) {
    if (invite != null) {
      _editingInviteId = invite['id']?.toString();
      _nomController.text = invite['nom'] ?? '';
      _prenomController.text = invite['prenom'] ?? '';
      _telephoneController.text = invite['telephone'] ?? '';
      _emailController.text = invite['email'] ?? '';
      _adresseController.text = invite['adresse'] ?? '';
    } else {
      _resetForm();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.5,
        maxChildSize: 0.7,
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
                      _editingInviteId == null
                          ? 'Nouvel Invité'
                          : 'Modifier l\'Invité',
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
                  key: _formKey,
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nom
                        TextFormField(
                          controller: _nomController,
                          decoration: InputDecoration(
                            labelText: 'Nom',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                          ),
                          validator: (value) => (value == null || value.isEmpty)
                              ? 'Veuillez entrer le nom'
                              : null,
                        ),
                        SizedBox(height: 10),

                        // Prénom
                        TextFormField(
                          controller: _prenomController,
                          decoration: InputDecoration(
                            labelText: 'Prénom',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (value) => (value == null || value.isEmpty)
                              ? 'Veuillez entrer le prénom'
                              : null,
                        ),
                        SizedBox(height: 10),

                        // Téléphone
                        TextFormField(
                          controller: _telephoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'Téléphone',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.phone),
                          ),
                          validator: (value) => (value == null || value.isEmpty)
                              ? 'Veuillez entrer le téléphone'
                              : null,
                        ),
                        SizedBox(height: 10),

                        // Email
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email (optionnel)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.email),
                          ),
                          validator: (value) {
                            if (value != null &&
                                value.isNotEmpty &&
                                !value.contains('@')) {
                              return 'Email invalide';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),

                        // Adresse
                        TextFormField(
                          controller: _adresseController,
                          maxLines: 2,
                          decoration: InputDecoration(
                            labelText: 'Adresse (optionnel)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.location_on),
                          ),
                        ),
                        SizedBox(height: 20),

                        // Bouton de soumission
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submitInvite,
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
                                    _editingInviteId == null
                                        ? 'Ajouter'
                                        : 'Enregistrer',
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

  Future<void> _submitInvite() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final data = {
      'nom': _nomController.text,
      'prenom': _prenomController.text,
      'telephone': _telephoneController.text,
      'email': _emailController.text.isEmpty ? null : _emailController.text,
      'adresse': _adresseController.text.isEmpty
          ? null
          : _adresseController.text,
    };

    final isEdit = _editingInviteId != null;
    try {
      if (_editingInviteId == null) {
        await ApiService.createInvite(data);
      } else {
        await ApiService.updateInvite(_editingInviteId!, data);
      }
      _resetForm();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEdit
                  ? 'Invité modifié avec succès'
                  : 'Invité ajouté avec succès',
            ),
            backgroundColor: Colors.green,
          ),
        );
        fetchInvites();
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

  void _confirmDelete(Map<String, dynamic> invite) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Supprimer l\'invité'),
        content: Text(
          'Voulez-vous vraiment supprimer "${invite['nom']} ${invite['prenom']}" ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _deleteInvite(invite['id'].toString());
            },
            child: Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteInvite(String id) async {
    try {
      await ApiService.deleteInvite(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invité supprimé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        fetchInvites();
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
                  hintText: 'Rechercher un invité...',
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
            // Liste des invités
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : filteredInvitesList.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 64,
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                          SizedBox(height: 16),
                          Text(
                            searchController.text.isEmpty
                                ? 'Aucun invité'
                                : 'Aucun résultat',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: fetchInvites,
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: filteredInvitesList.length,
                        itemBuilder: (context, index) {
                          final invite = filteredInvitesList[index];
                          return _buildInviteCard(invite);
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openInviteModal(),
        backgroundColor: Color(0xFF152895),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildInviteCard(Map<String, dynamic> invite) {
    final nom = invite['nom'] ?? '';
    final prenom = invite['prenom'] ?? '';
    final fullName = '$nom $prenom'.trim();
    final telephone = invite['telephone'] ?? '';
    final email = invite['email'] ?? '';
    final adresse = invite['adresse'] ?? '';

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
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Color(0xFF152895).withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person, color: Color(0xFF152895), size: 22),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName.isNotEmpty ? fullName : 'Sans nom',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF152895),
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.phone, size: 12, color: Color(0xFF152895)),
                    SizedBox(width: 4),
                    Text(
                      telephone.isNotEmpty ? telephone : 'N/A',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF152895).withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
                if (email.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Icon(Icons.email, size: 12, color: Color(0xFF152895)),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            email,
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF152895).withValues(alpha: 0.7),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (adresse.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 12,
                          color: Color(0xFF152895),
                        ),
                        SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            adresse,
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF152895).withValues(alpha: 0.7),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
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
                _openInviteModal(invite);
              } else if (value == 'supprimer') {
                _confirmDelete(invite);
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
