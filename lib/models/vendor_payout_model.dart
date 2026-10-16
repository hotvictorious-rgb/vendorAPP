class VendorPayoutModel {
  final String bankName;
  final String accountNumberMasked;
  final String accountName;
  final bool isCooldownActive;
  final int hoursRemaining;
  final String? cooldownExpiresAt;
  final String settledSum;
  final String eligibleSum;
  final List<SettledRecord> settledHistory;

  VendorPayoutModel({
    required this.bankName,
    required this.accountNumberMasked,
    required this.accountName,
    required this.isCooldownActive,
    required this.hoursRemaining,
    this.cooldownExpiresAt,
    required this.settledSum,
    required this.eligibleSum,
    required this.settledHistory,
  });

  factory VendorPayoutModel.fromJson(Map<String, dynamic> json) {
    final bank = json['bank_details'] as Map<String, dynamic>? ?? {};
    final cooldown = json['security_cooldown'] as Map<String, dynamic>? ?? {};
    final totals = json['totals'] as Map<String, dynamic>? ?? {};
    final history = json['settled_history'] as List? ?? [];

    return VendorPayoutModel(
      bankName: bank['bank_name'] as String? ?? 'No Bank Linked',
      accountNumberMasked: bank['account_number_masked'] as String? ?? '••••••••••',
      accountName: bank['account_name'] as String? ?? 'N/A',
      isCooldownActive: cooldown['is_active'] as bool? ?? false,
      hoursRemaining: cooldown['hours_remaining'] as int? ?? 0,
      cooldownExpiresAt: cooldown['cooldown_expires_at'] as String?,
      settledSum: totals['settled_sum']?.toString() ?? '0.00',
      eligibleSum: totals['eligible_sum']?.toString() ?? '0.00',
      settledHistory: history.map((e) => SettledRecord.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class SettledRecord {
  final int id;
  final String orderNumber;
  final String vendorNet90;
  final String? settledAt;
  final String? proofPath;

  SettledRecord({
    required this.id,
    required this.orderNumber,
    required this.vendorNet90,
    this.settledAt,
    this.proofPath,
  });

  factory SettledRecord.fromJson(Map<String, dynamic> json) {
    return SettledRecord(
      id: json['id'] as int? ?? 0,
      orderNumber: json['order_number'] as String? ?? '',
      vendorNet90: json['vendor_net_90']?.toString() ?? '0.00',
      settledAt: json['settled_at'] as String?,
      proofPath: json['settlement_proof_path'] as String?,
    );
  }
}
