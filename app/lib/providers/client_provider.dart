import 'dart:convert';
import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../models/client.dart';
import '../models/proposal.dart';

class ClientProvider extends ChangeNotifier {
  List<Cliente> _clients = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Cliente> get clients => _clients;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchClients() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.get('/api/clients');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _clients = data.map((e) => Cliente.fromJson(e)).toList();
      } else {
        _errorMessage = 'Falha ao buscar clientes';
      }
    } catch (e) {
      _errorMessage = 'Erro de conexão: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createClient(Cliente client) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post('/api/clients', client.toJson());
      _isLoading = false;
      if (response.statusCode == 201) {
        await fetchClients();
        return true;
      } else {
        final err = jsonDecode(response.body)['error'] ?? 'Falha ao cadastrar cliente';
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

  Future<bool> updateClient(String id, Cliente client) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.put('/api/clients/$id', client.toJson());
      _isLoading = false;
      if (response.statusCode == 200) {
        await fetchClients();
        return true;
      } else {
        final err = jsonDecode(response.body)['error'] ?? 'Falha ao atualizar cliente';
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

  Future<bool> deleteClient(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.delete('/api/clients/$id');
      _isLoading = false;
      if (response.statusCode == 200) {
        await fetchClients();
        return true;
      } else {
        final err = jsonDecode(response.body)['error'] ?? 'Falha ao excluir cliente';
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

  Future<List<Proposta>> fetchClientProposals(String id) async {
    try {
      final response = await ApiClient.instance.get('/api/clients/$id/proposals');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((e) => Proposta.fromJson(e)).toList();
      }
    } catch (_) {}
    return [];
  }
}
