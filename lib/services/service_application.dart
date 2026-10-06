import 'dart:convert';
//import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static String baseUrl = 'https://kinstore.alwaysdata.net/api';

  // static String get baseUrl {
  //   if (kIsWeb) {
  //     return 'http://localhost:8000/api';
  //   } else if (Platform.isAndroid) {
  //     return 'http://10.0.2.2:8000/api';
  //   } else if (Platform.isIOS) {
  //     return 'http://localhost:8000/api';
  //   }
  //   return 'http://localhost:8000/api';
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
}
