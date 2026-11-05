import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static String baseUrl = 'https://my2kmining.alwaysdata.net/api';

  // Pour développement local, décommentez et ajustez ces lignes
  // static String get baseUrl {
  //   if (kIsWeb) {
  //     return 'http://10.235.140.126:8000/api';
  //   } else if (Platform.isAndroid) {
  //     return 'http://10.235.140.126:8000/api';
  //   } else if (Platform.isIOS) {
  //     return 'http://10.235.140.126:8000/api';
  //   }
  //   return 'http://10.235.140.126:8000/api';
  // }

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user';

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        final data = jsonDecode(response.body);
        final message =
            data['message'] ?? 'Erreur de connexion lors de la connexion';
        throw Exception(message);
      }
    } catch (e) {
      throw Exception('Erreur de réseau : ${e.toString()}');
    }
  }

  //Sauvegarde des donnees de l'utilisateur connecter
  static Future<void> sauvegardeDonneesUser(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is String) {
      await prefs.setString(key, value);
    } else {
      await prefs.setString(key, jsonEncode(value));
    }
  }

  //Recuperation des donnees de l'utilisateur connecter
  static Future<dynamic> recupererDonneesUser(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString(key);
    if (data != null) {
      try {
        return jsonDecode(data);
      } catch (e) {
        // Si ce n'est pas du JSON, retourner la chaîne brute
        return data;
      }
    }
    return null;
  }

  //Récupérer le token d'authentification
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  //Créer les headers avec authentification
  static Future<Map<String, String>> getAuthHeaders() async {
    final token = await getToken();
    final headers = {'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<dynamic> getDashboardApi() async {
    final headers = await getAuthHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/dashboard-api'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception('Erreur lors de la récupération du dashboard');
    }
  }

  static Future<dynamic> getListeRendezVous() async {
    final headers = await getAuthHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/rendez-vous'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception('Erreur lors de la récupération des rendez-vous');
    }
  }

  static Future<dynamic> getListeRendezVousPlanifies() async {
    final headers = await getAuthHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/rendez-vous/planifier'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception(
        'Erreur lors de la récupération des rendez-vous planifiés',
      );
    }
  }

  static Future<dynamic> getListeRendezVousTermines() async {
    final headers = await getAuthHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/rendez-vous/terminer'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception(
        'Erreur lors de la récupération des rendez-vous terminés',
      );
    }
  }

  static Future<dynamic> createRendezVous(
    Map<String, dynamic> rendezVousData,
  ) async {
    final headers = await getAuthHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/rendez-vous'),
      headers: headers,
      body: jsonEncode(rendezVousData),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      final data = jsonDecode(response.body);
      String message =
          data['message'] ?? 'Erreur lors de la création du rendez-vous';
      if (data['errors'] != null) {
        final errors = data['errors'] as Map<String, dynamic>;
        final firstError = errors.values
            .expand((e) => e is List ? e : [e])
            .firstOrNull;
        if (firstError != null) {
          message = '$message ($firstError)';
        }
      }
      throw Exception(message);
    }
  }

  static Future<dynamic> getListeInvites() async {
    final headers = await getAuthHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/clients'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception('Erreur lors de la récupération des invités');
    }
  }

  static Future<dynamic> createInvite(Map<String, dynamic> clientData) async {
    final headers = await getAuthHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/clients'),
      headers: headers,
      body: jsonEncode(clientData),
    );
    return _handleClientResponse(response, 'création');
  }

  static Future<dynamic> updateInvite(
    String id,
    Map<String, dynamic> clientData,
  ) async {
    final headers = await getAuthHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/clients/$id'),
      headers: headers,
      body: jsonEncode(clientData),
    );
    return _handleClientResponse(response, 'modification');
  }

  static Future<dynamic> deleteInvite(String id) async {
    final headers = await getAuthHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/clients/$id'),
      headers: headers,
    );
    return _handleClientResponse(response, 'suppression');
  }

  static dynamic _handleClientResponse(http.Response response, String action) {
    final data = jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    }
    String message =
        data['message'] ?? 'Erreur lors de la $action de l\'invité';
    if (data['errors'] != null) {
      final errors = data['errors'] as Map<String, dynamic>;
      final firstError = errors.values
          .expand((e) => e is List ? e : [e])
          .firstOrNull;
      if (firstError != null) {
        message = '$message ($firstError)';
      }
    }
    throw Exception(message);
  }

  static Future<dynamic> getUtilisateurs() async {
    final headers = await getAuthHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/utilisateurs'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Erreur lors de la récupération des utilisateurs');
  }

  static Future<dynamic> getRoles() async {
    final headers = await getAuthHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/utilisateurs/roles'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw Exception('Erreur lors de la récupération des rôles');
  }

  static Future<dynamic> createUtilisateur(
    Map<String, dynamic> userData,
  ) async {
    final headers = await getAuthHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/utilisateurs'),
      headers: headers,
      body: jsonEncode(userData),
    );
    return _handleClientResponse(response, 'création');
  }

  static Future<dynamic> updateUtilisateur(
    String id,
    Map<String, dynamic> userData,
  ) async {
    final headers = await getAuthHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/utilisateurs/$id'),
      headers: headers,
      body: jsonEncode(userData),
    );
    return _handleClientResponse(response, 'modification');
  }

  static Future<dynamic> deleteUtilisateur(String id) async {
    final headers = await getAuthHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/utilisateurs/$id'),
      headers: headers,
    );
    return _handleClientResponse(response, 'suppression');
  }

  static Future<dynamic> getListeRendezVousTerminer() async {
    final headers = await getAuthHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/rendez-vous/terminer'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception(
        'Erreur lors de la récupération des rendez-vous terminés',
      );
    }
  }

  static Future<dynamic> updateRendezVous(
    String id,
    Map<String, dynamic> rendezVousData,
  ) async {
    final headers = await getAuthHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl/rendez-vous/$id'),
      headers: headers,
      body: jsonEncode(rendezVousData),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      final data = jsonDecode(response.body);
      String message =
          data['message'] ?? 'Erreur lors de la modification du rendez-vous';
      if (data['errors'] != null) {
        final errors = data['errors'] as Map<String, dynamic>;
        final firstError = errors.values
            .expand((e) => e is List ? e : [e])
            .firstOrNull;
        if (firstError != null) {
          message = '$message ($firstError)';
        }
      }
      throw Exception(message);
    }
  }

  static Future<dynamic> deleteRendezVous(String id) async {
    final headers = await getAuthHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/rendez-vous/$id'),
      headers: headers,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      final data = jsonDecode(response.body);
      throw Exception(
        data['message'] ?? 'Erreur lors de la suppression du rendez-vous',
      );
    }
  }

  static Future<dynamic> updateOnesignalId(String onesignalId) async {
    final headers = await getAuthHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/update-onesignal-id'),
      headers: headers,
      body: jsonEncode({'onesignal_id': onesignalId}),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception('Erreur lors de la mise à jour de l\'OneSignal ID');
    }
  }

  //Déconnexion de l'utilisateur
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}
