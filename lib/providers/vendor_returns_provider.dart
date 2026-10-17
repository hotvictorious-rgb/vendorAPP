import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exceptions.dart';
import '../models/vendor_return_model.dart';

class VendorReturnsProvider extends ChangeNotifier {
  final ApiClient apiClient;

  List<VendorReturnModel> _returns = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedStatus = 'all';

  List<VendorReturnModel> get returns => _returns;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get selectedStatus => _selectedStatus;

  VendorReturnsProvider({required this.apiClient});

  void setFilterStatus(String status) {
    _selectedStatus = status;
    fetchReturns();
  }

  Future<void> fetchReturns() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final Map<String, dynamic> params = {};
      if (_selectedStatus != 'all') {
        params['status'] = _selectedStatus;
      }

      final res = await apiClient.get(ApiEndpoints.returns, queryParameters: params);
      if (res.data['status'] == true && res.data['data'] != null) {
        final list = res.data['data'] as List;
        _returns = list.map((e) => VendorReturnModel.fromJson(e as Map<String, dynamic>)).toList();
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Failed to load inbound returns ledger.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> disputeReturn({
    required String caseNumber,
    required String disputeReason,
    File? disputePhoto,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      dynamic payload;
      if (disputePhoto != null) {
        payload = FormData.fromMap({
          'dispute_reason': disputeReason.trim(),
          'dispute_photo': await MultipartFile.fromFile(
            disputePhoto.path,
            filename: 'dispute_${caseNumber}.jpg',
          ),
        });
      } else {
        payload = {
          'dispute_reason': disputeReason.trim(),
        };
      }

      final res = await apiClient.post(
        '${ApiEndpoints.disputeReturn}$caseNumber/dispute',
        data: payload,
      );

      _isLoading = false;
      notifyListeners();

      if (res.data['status'] == true) {
        await fetchReturns();
        return {
          'success': true,
          'message': res.data['message'] ?? 'Counter-dispute logged and escalated to Super Admin Arbitration Desk.',
        };
      } else {
        return {
          'success': false,
          'message': res.data['message'] ?? 'Dispute submission failed.',
        };
      }
    } on ApiException catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': e.message};
    } catch (_) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'Network error while submitting dispute.'};
    }
  }
}
