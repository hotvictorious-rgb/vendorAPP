import 'package:flutter/material.dart';
import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exceptions.dart';
import '../models/vendor_order_model.dart';

class VendorOrdersProvider extends ChangeNotifier {
  final ApiClient apiClient;

  List<VendorOrderModel> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedStatus = 'all';
  String _searchQuery = '';

  List<VendorOrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedStatus => _selectedStatus;
  String get searchQuery => _searchQuery;

  VendorOrdersProvider({required this.apiClient});

  void setFilterStatus(String status) {
    _selectedStatus = status;
    fetchOrders();
  }

  void setSearchQuery(String query) {
    _searchQuery = query.trim();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final Map<String, dynamic> params = {};
      if (_selectedStatus != 'all') {
        params['status'] = _selectedStatus;
      }
      if (_searchQuery.isNotEmpty) {
        params['search'] = _searchQuery;
      }

      final res = await apiClient.get(ApiEndpoints.orders, queryParameters: params);
      if (res.data['status'] == true && res.data['data'] != null) {
        final list = res.data['data'] as List;
        _orders = list.map((e) => VendorOrderModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Failed to load merchant orders.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> markReadyForHandover(int orderId) async {
    try {
      final res = await apiClient.post('${ApiEndpoints.markReady}$orderId/ready-for-handover');
      if (res.data['status'] == true) {
        await fetchOrders();
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<Map<String, dynamic>> verifyHandoverOtp(int orderId, String otp) async {
    try {
      final res = await apiClient.post(
        ApiEndpoints.verifyHandoverOtp,
        data: {
          'order_id': orderId,
          'otp': otp.trim(),
        },
      );
      if (res.data['status'] == true) {
        await fetchOrders();
        return {'success': true, 'message': res.data['message'] ?? 'Handover verified.'};
      }
      return {'success': false, 'message': res.data['message'] ?? 'Verification failed.'};
    } on ApiException catch (e) {
      return {'success': false, 'message': e.message};
    } catch (_) {
      return {'success': false, 'message': 'Handover confirmation network error.'};
    }
  }
}
