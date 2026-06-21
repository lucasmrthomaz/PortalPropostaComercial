import 'dart:convert';
import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../models/company.dart';

class CompanyProvider extends ChangeNotifier {
  List<Empresa> _companies = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Empresa> get companies => _companies;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchCompanies() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.get('/api/companies');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _companies = data.map((e) => Empresa.fromJson(e)).toList();
      } else {
        _errorMessage = 'Falha ao buscar empresas parceiras';
      }
    } catch (e) {
      _errorMessage = 'Erro de conexão: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createCompany(Empresa company) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post('/api/companies', company.toJson());
      _isLoading = false;
      if (response.statusCode == 201) {
        await fetchCompanies();
        return true;
      } else {
        final err = jsonDecode(response.body)['error'] ?? 'Falha ao cadastrar empresa';
        _errorMessage = err;
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

  Future<bool> updateCompany(String id, Empresa company) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.put('/api/companies/$id', company.toJson());
      _isLoading = false;
      if (response.statusCode == 200) {
        await fetchCompanies();
        return true;
      } else {
        final err = jsonDecode(response.body)['error'] ?? 'Falha ao atualizar empresa';
        _errorMessage = err;
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

  Future<bool> deleteCompany(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.delete('/api/companies/$id');
      _isLoading = false;
      if (response.statusCode == 200) {
        await fetchCompanies();
        return true;
      } else {
        final err = jsonDecode(response.body)['error'] ?? 'Falha ao excluir empresa';
        _errorMessage = err;
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
