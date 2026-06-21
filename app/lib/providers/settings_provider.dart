import 'dart:convert';
import 'package:flutter/material.dart';
import '../core/api_client.dart';

class SettingsProvider extends ChangeNotifier {
  double _commissionRate = 0.0;
  bool _isLoading = false;
  String? _errorMessage;

  double get commissionRate => _commissionRate;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchSettings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.get('/api/settings');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _commissionRate = (data['taxa_corretagem'] ?? 0.0).toDouble();
      } else {
        _errorMessage = 'Falha ao buscar configurações';
      }
    } catch (e) {
      _errorMessage = 'Erro de conexão: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateCommissionRate(double rate) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.put('/api/settings', {
        'taxa_corretagem': rate,
      });
      _isLoading = false;
      if (response.statusCode == 200) {
        _commissionRate = rate;
        notifyListeners();
        return true;
      } else {
        _errorMessage = jsonDecode(response.body)['error'] ?? 'Falha ao atualizar taxa';
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

  Future<bool> updateSupervisorPassword(String newPassword) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.put('/api/settings', {
        'senha_supervisor': newPassword,
      });
      _isLoading = false;
      if (response.statusCode == 200) {
        return true;
      } else {
        _errorMessage = jsonDecode(response.body)['error'] ?? 'Falha ao atualizar senha';
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

  Future<bool> verifySupervisorPassword(String password) async {
    try {
      final response = await ApiClient.instance.post('/api/supervisor/verify-password', {
        'password': password,
      });
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['valid'] ?? false;
      }
    } catch (_) {}
    return false;
  }
}
