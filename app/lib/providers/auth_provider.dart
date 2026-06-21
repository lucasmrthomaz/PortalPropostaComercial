import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_client.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  Usuario? _currentUser;
  bool _isLoading = false;

  Usuario? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isLoading => _isLoading;
  bool get isSuperAdmin => _currentUser?.perfil?.nome == 'Super Admin';

  List<String> get permissoes {
    if (_currentUser == null || _currentUser!.perfil == null) return [];
    return _currentUser!.perfil!.permissoes;
  }

  AuthProvider() {
    ApiClient.instance.onUnauthorized = logout;
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final userRaw = prefs.getString('portal_user');
    if (userRaw != null) {
      try {
        _currentUser = Usuario.fromJson(jsonDecode(userRaw));
        // Mock token if present (though backend routes are open, we store it)
        ApiClient.instance.setToken(_currentUser?.id);
        notifyListeners();
      } catch (_) {}
    }
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post('/api/auth/login', {
        'email': email,
        'senha': password,
      });

      _isLoading = false;
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        _currentUser = Usuario.fromJson(data);
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('portal_user', jsonEncode(data));
        
        // Use ID as auth token for headers if backend ever implements it
        ApiClient.instance.setToken(_currentUser!.id);
        notifyListeners();
        return true;
      } else {
        notifyListeners();
        return false;
      }
    } catch (_) {
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void logout() {
    _currentUser = null;
    SharedPreferences.getInstance().then((prefs) {
      prefs.remove('portal_user');
    });
    ApiClient.instance.setToken(null);
    notifyListeners();
  }

  bool hasPermission(String permission) {
    if (isSuperAdmin) return true;
    return permissoes.contains('*') || permissoes.contains(permission);
  }
}
