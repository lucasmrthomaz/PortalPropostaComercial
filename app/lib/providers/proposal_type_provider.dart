import 'dart:convert';
import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../models/proposal_type.dart';

class ProposalTypeProvider extends ChangeNotifier {
  List<TipoProposta> _proposalTypes = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<TipoProposta> get proposalTypes => _proposalTypes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchProposalTypes() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.get('/api/proposal-types');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _proposalTypes = data.map((e) => TipoProposta.fromJson(e)).toList();
      } else {
        _errorMessage = 'Falha ao buscar tipos de proposta';
      }
    } catch (e) {
      _errorMessage = 'Erro de conexão: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createProposalType(TipoProposta type) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post('/api/proposal-types', type.toJson());
      _isLoading = false;
      if (response.statusCode == 201) {
        await fetchProposalTypes();
        return true;
      } else {
        _errorMessage = jsonDecode(response.body)['error'] ?? 'Falha ao criar tipo de proposta';
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

  Future<bool> updateProposalType(String id, TipoProposta type) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.put('/api/proposal-types/$id', type.toJson());
      _isLoading = false;
      if (response.statusCode == 200) {
        await fetchProposalTypes();
        return true;
      } else {
        _errorMessage = jsonDecode(response.body)['error'] ?? 'Falha ao atualizar tipo';
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

  Future<bool> deleteProposalType(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.delete('/api/proposal-types/$id');
      _isLoading = false;
      if (response.statusCode == 200) {
        await fetchProposalTypes();
        return true;
      } else {
        _errorMessage = jsonDecode(response.body)['error'] ?? 'Falha ao excluir tipo';
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
