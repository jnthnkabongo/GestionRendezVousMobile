import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/tts_service.dart';
import '../services/service_application.dart';
import '../auth/login.dart';

class Parametres extends StatefulWidget {
  const Parametres({super.key});

  @override
  State<Parametres> createState() => _ParametresState();
}

class _ParametresState extends State<Parametres> {
  bool _ttsEnabled = true;
  String _userName = 'Utilisateur';
  String _userEmail = 'email@example.com';
  String _userRole = 'Utilisateur';

  @override
  void initState() {
    super.initState();
    _loadTTSSetting();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await ApiService.recupererDonneesUser('user');
    if (user != null) {
      setState(() {
        _userName = '${user['nom'] ?? ''} ${user['prenom'] ?? ''}'.trim();
        _userEmail = user['email'] ?? 'email@example.com';
        _userRole = user['role'] ?? 'Utilisateur';
      });
    }
  }

  Future<void> _loadTTSSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _ttsEnabled = prefs.getBool('tts_enabled') ?? true;
    });
    TTSService.instance.setEnabled(_ttsEnabled);
  }

  Future<void> _toggleTTS(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tts_enabled', value);
    setState(() {
      _ttsEnabled = value;
    });
    TTSService.instance.setEnabled(value);
  }

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Déconnexion'),
        content: Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ApiService.logout();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const Login()),
                  (route) => false,
                );
              }
            },
            child: Text(
              'Déconnexion',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
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
        child: ListView(
          padding: EdgeInsets.all(16),
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(16),
              margin: EdgeInsets.only(top: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Paramètres',
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
            SizedBox(height: 24),
            // Card utilisateur connecté
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
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
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    child: Icon(Icons.person, size: 48, color: Colors.white),
                  ),
                ),
                SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userName.isNotEmpty ? _userName : 'Utilisateur',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        _userEmail,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _capitalize(_userRole),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.edit, color: Colors.white, size: 24),
              ],
            ),
          ),
          SizedBox(height: 24),

            // Section Profil
            Text(
              'Profil',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 12),
            _buildSettingsCard(
              Icons.person,
              'Informations personnelles',
              'Modifiez vos informations',
              () {},
            ),
            _buildSettingsCard(
              Icons.security,
              'Sécurité',
              'Mot de passe et authentification',
              () {},
            ),
            SizedBox(height: 24),

            // Section Notifications
            Text(
              'Notifications',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 12),
            _buildSettingsCard(
              Icons.notifications,
              'Notifications push',
              'Gérez les notifications',
              () {},
            ),
            _buildSettingsCard(
              Icons.email,
              'Notifications email',
              'Gérez les emails',
              () {},
            ),
            _buildToggleCard(
              Icons.volume_up,
              'Lecture vocale',
              'Lire les notifications à haute voix',
              _ttsEnabled,
              _toggleTTS,
            ),
            SizedBox(height: 24),

            // Section Apparence
            Text(
              'Apparence',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 12),
            _buildSettingsCard(
              Icons.dark_mode,
              'Thème sombre',
              'Activez le mode sombre',
              () {},
            ),
            _buildSettingsCard(
              Icons.language,
              'Langue',
              'Choisissez votre langue',
              () {},
            ),
            SizedBox(height: 24),

            // Section Autres
            Text(
              'Autres',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 12),
            _buildSettingsCard(
              Icons.info,
              'À propos',
              'Informations sur l\'application',
              () {},
            ),
            _buildSettingsCard(
              Icons.support_agent,
              'Support',
              'Contactez le support',
              () {},
            ),
            _buildSettingsCard(
              Icons.logout,
              'Déconnexion',
              'Déconnectez votre compte',
              _logout,
              isDestructive: true,
            ),
            SizedBox(height: 24),

            // Version
            Center(
              child: Text(
                'Version 1.0.0',
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
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
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDestructive
                ? Colors.red.withValues(alpha: 0.2)
                : Color(0xFF152895).withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isDestructive ? Colors.red : Color(0xFF152895),
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDestructive ? Colors.red : Color(0xFF152895),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 14, color: Color(0xFF152895).withValues(alpha: 0.7)),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Color(0xFF152895).withValues(alpha: 0.5),
          size: 20,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildToggleCard(
    IconData icon,
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
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
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Color(0xFF152895).withValues(alpha: 0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Color(0xFF152895), size: 24),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF152895),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 14, color: Color(0xFF152895).withValues(alpha: 0.7)),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeColor: Color(0xFF152895),
        ),
      ),
    );
  }

  String _capitalize(String text) {
    if (text.isEmpty) return '';
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }
}
