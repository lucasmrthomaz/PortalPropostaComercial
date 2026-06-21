import 'dart:convert';
import 'package:flutter/material.dart';
import '../core/api_client.dart';
import '../models/analysis_request.dart';

class SupervisorProvider extends ChangeNotifier {
  List<PedidoAnalise> _requests = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<PedidoAnalise> get requests => _requests;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchRequests({String? status = 'Pendente'}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final path = status != null ? '/api/supervisor/requests?status=$status' : '/api/supervisor/requests';
      final response = await ApiClient.instance.get(path);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        _requests = data.map((e) => PedidoAnalise.fromJson(e)).toList();
      } else {
        _errorMessage = 'Falha ao carregar solicitações de análise';
      }
    } catch (e) {
      _errorMessage = 'Erro de conexão: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createRequest(PedidoAnalise request) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post('/api/supervisor/requests', request.toJson());
      _isLoading = false;
      if (response.statusCode == 201) {
        return true;
      } else {
        _errorMessage = jsonDecode(response.body)['error'] ?? 'Falha ao criar pedido';
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

  Future<bool> approveRequest(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post('/api/supervisor/requests/$id/approve', {});
      _isLoading = false;
      if (response.statusCode == 200) {
        await fetchRequests();
        return true;
      } else {
        _errorMessage = jsonDecode(response.body)['error'] ?? 'Falha ao aprovar pedido';
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

  Future<bool> rejectRequest(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await ApiClient.instance.post('/api/supervisor/requests/$id/reject', {});
      _isLoading = false;
      if (response.statusCode == 200) {
        await fetchRequests();
        return true;
      } else {
        _errorMessage = jsonDecode(response.body)['error'] ?? 'Falha ao recusar pedido';
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
