import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  static final ApiClient instance = ApiClient._internal();
  ApiClient._internal();

  String? _token;
  String _baseUrl = 'http://localhost:8080';
  VoidCallback? onUnauthorized;

  String get baseUrl => _baseUrl;

  void setBaseUrl(String url) {
    _baseUrl = url;
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('api_base_url', url);
    });
  }

  void setToken(String? token) {
    _token = token;
    SharedPreferences.getInstance().then((prefs) {
      if (token != null) {
        prefs.setString('auth_token', token);
      } else {
        prefs.remove('auth_token');
      }
    });
  }

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    
    // Automatically use http://10.0.2.2:8080 when running on Android Emulator in debug mode
    if (defaultTargetPlatform == TargetPlatform.android && kDebugMode) {
      _baseUrl = prefs.getString('api_base_url') ?? 'http://10.0.2.2:8080';
    } else {
      _baseUrl = prefs.getString('api_base_url') ?? 'http://localhost:8080';
    }
  }

  Map<String, String> _headers() {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  String _resolveUrl(String path) {
    if (!path.startsWith('/')) {
      path = '/$path';
    }
    return '$_baseUrl$path';
  }

  Future<http.Response> get(String path) async {
    try {
      final response = await http.get(
        Uri.parse(_resolveUrl(path)),
        headers: _headers(),
      );
      _checkStatus(response);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<http.Response> post(String path, dynamic body) async {
    try {
      final response = await http.post(
        Uri.parse(_resolveUrl(path)),
        headers: _headers(),
        body: jsonEncode(body),
      );
      _checkStatus(response);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<http.Response> put(String path, dynamic body) async {
    try {
      final response = await http.put(
        Uri.parse(_resolveUrl(path)),
        headers: _headers(),
        body: jsonEncode(body),
      );
      _checkStatus(response);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<http.Response> delete(String path) async {
    try {
      final response = await http.delete(
        Uri.parse(_resolveUrl(path)),
        headers: _headers(),
      );
      _checkStatus(response);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  void _checkStatus(http.Response response) {
    if (response.statusCode == 401) {
      onUnauthorized?.call();
    }
  }
}
