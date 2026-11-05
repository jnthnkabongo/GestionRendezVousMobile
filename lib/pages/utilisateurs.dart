import 'package:flutter/material.dart';
import '../services/service_application.dart';

class Utilisateurs extends StatefulWidget {
  const Utilisateurs({super.key});

  @override
  State<Utilisateurs> createState() => _UtilisateursState();
}

class _UtilisateursState extends State<Utilisateurs> {
  List<dynamic> utilisateursList = [];
  List<dynamic> filteredUtilisateursList = [];
  List<dynamic> roles = [];
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  // Formulaire utilisateur
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedRoleId;
  bool _actif = true;
  String? _editingUserId;
  bool _isSubmitting = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    fetchData();
    searchController.addListener(_filterUtilisateurs);
  }

  @override
  void dispose() {
    searchController.dispose();
    _nomController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> fetchData() async {
    try {
      final results = await Future.wait([
        ApiService.getUtilisateurs(),
        ApiService.getRoles(),
      ]);
      final usersData = results[0];
      final rolesData = results[1];
      if (usersData['success'] == true && usersData['data'] != null) {
        setState(() {
          utilisateursList = usersData['data'];
          filteredUtilisateursList = usersData['data'];
          roles = rolesData['data'] ?? [];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Error fetching utilisateurs: $e');
      setState(() => isLoading = false);
    }
  }

  void _filterUtilisateurs() {
    final query = searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredUtilisateursList = utilisateursList;
      } else {
        filteredUtilisateursList = utilisateursList.where((user) {
          final name = (user['name'] ?? '').toString().toLowerCase();
          final email = (user['email'] ?? '').toString().toLowerCase();
          final roleNom =
              (user['role'] is Map ? user['role']['name'] : user['role'] ?? '')
                  .toString()
                  .toLowerCase();
          return name.contains(query) ||
              email.contains(query) ||
              roleNom.contains(query);
        }).toList();
      }
    });
  }

  void _resetForm() {
    _nomController.clear();
    _emailController.clear();
    _passwordController.clear();
    _selectedRoleId = null;
    _actif = true;
    _editingUserId = null;
    _formKey.currentState?.reset();
  }

  void _openUserModal([Map<String, dynamic>? user]) {
    if (user != null) {
      _editingUserId = user['id']?.toString();
      _nomController.text = user['name'] ?? '';
      _emailController.text = user['email'] ?? '';
      _passwordController.clear();
      _selectedRoleId = user['role_id']?.toString();
      _actif = user['actif'] == true || user['actif'] == 1;
    } else {
      _resetForm();
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.5,
        maxChildSize: 0.55,
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
                      _editingUserId == null
                          ? 'Nouvel Utilisateur'
                          : 'Modifier l\'Utilisateur',
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

                        // Email
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.email),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer l\'email';
                            }
                            if (!value.contains('@')) {
                              return 'Email invalide';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),

                        // Mot de passe
                        StatefulBuilder(
                          builder: (context, setModalState) => TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: _editingUserId == null
                                  ? 'Mot de passe'
                                  : 'Nouveau mot de passe (optionnel)',
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.lock),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Color(0xFF152895),
                                ),
                                onPressed: () => setModalState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (_editingUserId == null &&
                                  (value == null || value.isEmpty)) {
                                return 'Veuillez entrer un mot de passe';
                              }
                              if (value != null &&
                                  value.isNotEmpty &&
                                  value.length < 6) {
                                return 'Minimum 6 caractères';
                              }
                              return null;
                            },
                          ),
                        ),
                        SizedBox(height: 10),

                        // Rôle
                        DropdownButtonFormField<String>(
                          initialValue: _selectedRoleId,
                          decoration: InputDecoration(
                            labelText: 'Rôle',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.badge),
                          ),
                          items: roles.map((role) {
                            final roleNom = (role['nom'] ?? role['name'] ?? '')
                                .toString();
                            return DropdownMenuItem<String>(
                              value: role['id'].toString(),
                              child: Text(roleNom),
                            );
                          }).toList(),
                          onChanged: (value) =>
                              setState(() => _selectedRoleId = value),
                        ),
                        SizedBox(height: 10),

                        // Actif
                        SwitchListTile(
                          title: Text('Utilisateur actif'),
                          value: _actif,
                          onChanged: (value) => setState(() => _actif = value),
                          activeColor: Color(0xFF152895),
                        ),
                        SizedBox(height: 10),

                        // Bouton de soumission
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isSubmitting ? null : _submitUser,
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
                                    _editingUserId == null
                                        ? 'Créer'
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

  Future<void> _submitUser() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final data = {
      'name': _nomController.text,
      'email': _emailController.text,
      'role_id': _selectedRoleId,
      'actif': _actif,
    };
    if (_passwordController.text.isNotEmpty) {
      data['password'] = _passwordController.text;
    }

    final isEdit = _editingUserId != null;
    try {
      if (_editingUserId == null) {
        await ApiService.createUtilisateur(data);
      } else {
        await ApiService.updateUtilisateur(_editingUserId!, data);
      }
      _resetForm();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isEdit
                  ? 'Utilisateur modifié avec succès'
                  : 'Utilisateur créé avec succès',
            ),
            backgroundColor: Colors.green,
          ),
        );
        fetchData();
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

  void _confirmDelete(Map<String, dynamic> user) {
    final name = user['name'] ?? '';
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Supprimer l\'utilisateur'),
        content: Text('Voulez-vous vraiment supprimer "$name" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _deleteUser(user['id'].toString());
            },
            child: Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteUser(String id) async {
    try {
      await ApiService.deleteUtilisateur(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Utilisateur supprimé avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        fetchData();
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
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Gestion des Utilisateurs',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
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
                  hintText: 'Rechercher un utilisateur...',
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
            // Liste des utilisateurs
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : filteredUtilisateursList.isEmpty
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
                                ? 'Aucun utilisateur'
                                : 'Aucun résultat',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: fetchData,
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: filteredUtilisateursList.length,
                        itemBuilder: (context, index) {
                          final user = filteredUtilisateursList[index];
                          return _buildUserCard(user);
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openUserModal(),
        backgroundColor: Color(0xFF152895),
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
    final fullName = (user['name'] ?? '').toString();
    final email = user['email'] ?? '';
    final role = user['role'];
    final roleNom = role is Map
        ? (role['name'] ?? 'Aucun rôle').toString()
        : 'Aucun rôle';
    final actif = user['actif'] == true || user['actif'] == 1;

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
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.badge, size: 12, color: Color(0xFF152895)),
                    SizedBox(width: 4),
                    Text(
                      roleNom,
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF152895).withValues(alpha: 0.7),
                      ),
                    ),
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: actif
                            ? Colors.green.withValues(alpha: 0.2)
                            : Colors.red.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        actif ? 'Actif' : 'Inactif',
                        style: TextStyle(
                          fontSize: 10,
                          color: actif ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
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
                _openUserModal(user);
              } else if (value == 'supprimer') {
                _confirmDelete(user);
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
