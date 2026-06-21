import 'dart:convert';
import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../models/proposal.dart';
import '../models/dashboard_stats.dart';

class ProposalProvider extends ChangeNotifier {
  List<Proposta> _proposals = [];
  DashboardStats? _dashboardStats;
  bool _isLoading = false;
  String? _errorMessage;

  List<Proposta> get proposals => _proposals;
  DashboardStats? get dashboardStats => _dashboardStats;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchProposals() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.get('/api/proposals');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _proposals = data.map((e) => Proposta.fromJson(e)).toList();
      } else {
        _errorMessage = 'Falha ao buscar propostas';
      }
    } catch (e) {
      _errorMessage = 'Erro de conexão: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchDashboardStats() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await ApiClient.instance.get('/api/dashboard/stats');
      if (response.statusCode == 200) {
        _dashboardStats = DashboardStats.fromJson(jsonDecode(response.body));
      }
    } catch (_) {
      // Keep previous stats or handle connection failure silently for widget fallbacks
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createProposal(Proposta proposal) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post('/api/proposals', proposal.toJson());
      _isLoading = false;
      if (response.statusCode == 201) {
        await fetchProposals();
        await fetchDashboardStats();
        return true;
      } else {
        final err = jsonDecode(response.body)['error'] ?? 'Falha ao criar proposta';
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

  Future<bool> updateProposal(String id, Proposta proposal) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.put('/api/proposals/$id', proposal.toJson());
      _isLoading = false;
      if (response.statusCode == 200) {
        await fetchProposals();
        await fetchDashboardStats();
        return true;
      } else {
        final err = jsonDecode(response.body)['error'] ?? 'Falha ao atualizar proposta';
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

  Future<bool> deleteProposal(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.delete('/api/proposals/$id');
      _isLoading = false;
      if (response.statusCode == 200) {
        await fetchProposals();
        await fetchDashboardStats();
        return true;
      } else {
        final err = jsonDecode(response.body)['error'] ?? 'Falha ao excluir proposta';
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
