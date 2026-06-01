import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'constants.dart';

class ApiClient {
  final http.Client _client = http.Client();

  // Helper to determine base URL dynamically based on operating platform
  String get _baseUrl {
    if (Platform.isAndroid) {
      return AppConstants.baseApiUrlAndroid;
    } else {
      return AppConstants.baseApiUrlIos;
    }
  }

  // Prepares headers and injects authentication token automatically
  Future<Map<String, String>> _getHeaders() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? token = prefs.getString('access_token');
    
    final Map<String, String> headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // Intercept response to check for 401 unauthorized
  void _checkResponseStatus(http.Response response) {
    if (response.statusCode == 401) {
      // Prompt global session expiration
      _handleUnauthorized();
    }
  }

  Future<void> _handleUnauthorized() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('access_token');
    await prefs.remove('admin_user');
    
    // We can add navigation event dispatcher here if needed
  }

  // GET request
  Future<http.Response> get(String endpoint) async {
    final String url = '$_baseUrl$endpoint';
    final Map<String, String> headers = await _getHeaders();
    
    try {
      final http.Response response = await _client.get(Uri.parse(url), headers: headers);
      _checkResponseStatus(response);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // POST request
  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final String url = '$_baseUrl$endpoint';
    final Map<String, String> headers = await _getHeaders();
    
    try {
      final http.Response response = await _client.post(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );
      _checkResponseStatus(response);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // PUT request
  Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    final String url = '$_baseUrl$endpoint';
    final Map<String, String> headers = await _getHeaders();
    
    try {
      final http.Response response = await _client.put(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );
      _checkResponseStatus(response);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // PATCH request
  Future<http.Response> patch(String endpoint, Map<String, dynamic> body) async {
    final String url = '$_baseUrl$endpoint';
    final Map<String, String> headers = await _getHeaders();
    
    try {
      final http.Response response = await _client.patch(
        Uri.parse(url),
        headers: headers,
        body: jsonEncode(body),
      );
      _checkResponseStatus(response);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // DELETE request
  Future<http.Response> delete(String endpoint) async {
    final String url = '$_baseUrl$endpoint';
    final Map<String, String> headers = await _getHeaders();
    
    try {
      final http.Response response = await _client.delete(Uri.parse(url), headers: headers);
      _checkResponseStatus(response);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
