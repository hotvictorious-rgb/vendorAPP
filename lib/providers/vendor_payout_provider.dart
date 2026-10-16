import 'package:flutter/material.dart';
import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../core/network/api_exceptions.dart';
import '../models/vendor_payout_model.dart';

class VendorPayoutProvider extends ChangeNotifier {
  final ApiClient apiClient;

  VendorPayoutModel? _payoutData;
  bool _isLoading = false;
  String? _errorMessage;

  VendorPayoutModel? get payoutData => _payoutData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  VendorPayoutProvider({required this.apiClient});

  Future<void> fetchPayouts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await apiClient.get(ApiEndpoints.payouts);
      if (res.data['status'] == true && res.data['data'] != null) {
        _payoutData = VendorPayoutModel.fromJson(res.data['data'] as Map<String, dynamic>);
      }
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (_) {
      _errorMessage = 'Failed to load settlement ledger.';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> updateBank({
    required String bankName,
    required String accountNumber,
    required String accountName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await apiClient.post(
        ApiEndpoints.updateBank,
        data: {
          'bank_name': bankName.trim(),
          'account_number': accountNumber.trim(),
          'account_name': accountName.trim().toUpperCase(),
        },
      );

      _isLoading = false;
      notifyListeners();

      if (res.data['status'] == true) {
        await fetchPayouts();
        return {'success': true, 'message': res.data['message'] ?? 'Bank details updated. 48-Hour Cooldown is active.'};
      } else {
        return {'success': false, 'message': res.data['message'] ?? 'Update failed.'};
      }
    } on ApiException catch (e) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': e.message};
    } catch (_) {
      _isLoading = false;
      notifyListeners();
      return {'success': false, 'message': 'Network error while updating bank details.'};
    }
  }
}
