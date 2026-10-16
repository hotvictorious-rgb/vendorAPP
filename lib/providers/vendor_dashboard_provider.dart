import 'package:flutter/material.dart';
import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exceptions.dart';
import '../core/services/storage_service.dart';
import '../models/vendor_dashboard_model.dart';

class VendorDashboardProvider extends ChangeNotifier {
  final ApiClient apiClient;
  final StorageService storageService;

  VendorDashboardModel? _dashboardData;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isBalanceVisible = true;

  VendorDashboardModel? get dashboardData => _dashboardData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isBalanceVisible => _isBalanceVisible;

  VendorDashboardProvider({required this.apiClient, required this.storageService}) {
    _isBalanceVisible = storageService.isBalanceVisible();
  }

  void toggleBalanceVisibility() {
    _isBalanceVisible = !_isBalanceVisible;
    storageService.setBalanceVisible(_isBalanceVisible);
    notifyListeners();
  }

  Future<void> fetchDashboard() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await apiClient.get(ApiEndpoints.dashboard);
      if (res.data['status'] == true && res.data['data'] != null) {
        _dashboardData = VendorDashboardModel.fromJson(res.data['data'] as Map<String, dynamic>);
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Failed to load merchant dashboard telemetry.';
    }

    _isLoading = false;
    notifyListeners();
  }
}
