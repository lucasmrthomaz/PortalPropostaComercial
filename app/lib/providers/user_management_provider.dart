import 'dart:convert';
import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../models/user.dart';

class UserManagementProvider extends ChangeNotifier {
  List<Usuario> _users = [];
  List<Perfil> _profiles = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Usuario> get users => _users;
  List<Perfil> get profiles => _profiles;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchProfiles() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.get('/api/profiles');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _profiles = data.map((e) => Perfil.fromJson(e)).toList();
      } else {
        _errorMessage = 'Falha ao buscar perfis';
      }
    } catch (e) {
      _errorMessage = 'Erro de conexão: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUsers() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.get('/api/users');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _users = data.map((e) => Usuario.fromJson(e)).toList();
      } else {
        _errorMessage = 'Falha ao buscar usuários';
      }
    } catch (e) {
      _errorMessage = 'Erro de conexão: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createProfile(Perfil profile) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post('/api/profiles', profile.toJson());
      _isLoading = false;
      if (response.statusCode == 201) {
        await fetchProfiles();
        return true;
      } else {
        _errorMessage = jsonDecode(response.body)['error'] ?? 'Falha ao criar perfil';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Erro de conexão: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile(String id, Perfil profile) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.put('/api/profiles/$id', profile.toJson());
      _isLoading = false;
      if (response.statusCode == 200) {
        await fetchProfiles();
        return true;
      } else {
        _errorMessage = jsonDecode(response.body)['error'] ?? 'Falha ao atualizar perfil';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Erro de conexão: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteProfile(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.delete('/api/profiles/$id');
      _isLoading = false;
      if (response.statusCode == 200) {
        await fetchProfiles();
        return true;
      } else {
        _errorMessage = jsonDecode(response.body)['error'] ?? 'Falha ao excluir perfil';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Erro de conexão: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> createUser(String nome, String email, String senha, String perfilId, bool ativo) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post('/api/users', {
        'nome': nome,
        'email': email,
        'senha': senha,
        'perfil_id': perfilId,
        'ativo': ativo,
      });
      _isLoading = false;
      if (response.statusCode == 201) {
        await fetchUsers();
        return true;
      } else {
        _errorMessage = jsonDecode(response.body)['error'] ?? 'Falha ao criar usuário';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Erro de conexão: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateUser(String id, String nome, String email, String senha, String perfilId, bool ativo) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.put('/api/users/$id', {
        'nome': nome,
        'email': email,
        if (senha.isNotEmpty) 'senha': senha,
        'perfil_id': perfilId,
        'ativo': ativo,
      });
      _isLoading = false;
      if (response.statusCode == 200) {
        await fetchUsers();
        return true;
      } else {
        _errorMessage = jsonDecode(response.body)['error'] ?? 'Falha ao atualizar usuário';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Erro de conexão: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteUser(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.delete('/api/users/$id');
      _isLoading = false;
      if (response.statusCode == 200) {
        await fetchUsers();
        return true;
      } else {
        _errorMessage = jsonDecode(response.body)['error'] ?? 'Falha ao excluir usuário';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = 'Erro de conexão: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
