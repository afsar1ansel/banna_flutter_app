import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_client.dart';

class AuthProvider extends ChangeNotifier {
  final ApiClient _apiClient = ApiClient();

  bool _isLoading = false;
  String? _token;
  Map<String, dynamic>? _user;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;
  String? get token => _token;
  Map<String, dynamic>? get user => _user;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _loadSession();
  }

  // Load persisted session on startup
  Future<void> _loadSession() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('access_token');
    
    final String? userJson = prefs.getString('admin_user');
    if (userJson != null) {
      _user = jsonDecode(userJson);
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final String trimmedEmail = email.trim();
    final String trimmedPassword = password.trim();

    // Hardcoded bypass for testing on physical devices when backend is only local on computer
    if (trimmedEmail == 'afsar@gmail.com' && trimmedPassword == 'afsar@123') {
      _token = 'mock_dev_access_token_afsar_ansel';
      _user = {
        'id': '1bd05878-69b9-440d-aa03-bbb4d09e122b',
        'name': 'Afsar Ansel',
        'email': 'afsar@gmail.com',
        'role': 'admin',
        'created_at': DateTime.now().toIso8601String(),
      };

      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('access_token', _token!);
      await prefs.setString('admin_user', jsonEncode(_user));

      _isLoading = false;
      notifyListeners();
      return true;
    }

    try {
      final response = await _apiClient.post('/admin/auth/login', {
        'email': trimmedEmail,
        'password': trimmedPassword,
      });

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        _token = data['access_token'];
        _user = data['user'];

        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('access_token', _token!);
        await prefs.setString('admin_user', jsonEncode(_user));

        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        final Map<String, dynamic> errorData = jsonDecode(response.body);
        _errorMessage = errorData['detail'] ?? 'Authentication failed.';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Unable to connect to the login service.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Logout
  Future<void> logout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('admin_user');
    
    _token = null;
    _user = null;
    notifyListeners();
  }
}
