import 'package:flutter/material.dart';

class Parametres extends StatefulWidget {
  const Parametres({super.key});

  @override
  State<Parametres> createState() => _ParametresState();
}

class _ParametresState extends State<Parametres> {
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
              'Paramètres',
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
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          // Card utilisateur connecté
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF152895), Color(0xFF2464d4)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
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
                        'Jonathan Kabongo',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'jonathan@example.com',
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
                          'Administrateur',
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
              color: Color(0xFF152895),
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
              color: Color(0xFF152895),
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
          SizedBox(height: 24),

          // Section Apparence
          Text(
            'Apparence',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF152895),
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
              color: Color(0xFF152895),
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
            () {},
            isDestructive: true,
          ),
          SizedBox(height: 24),

          // Version
          Center(
            child: Text(
              'Version 1.0.0',
              style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            ),
          ),
        ],
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
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDestructive
                ? Colors.red.withValues(alpha: 0.1)
                : Color(0xFF152895).withValues(alpha: 0.1),
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
            color: isDestructive ? Colors.red : Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: Colors.grey[400],
          size: 20,
        ),
        onTap: onTap,
      ),
    );
  }
}
