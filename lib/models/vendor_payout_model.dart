class VendorPayoutModel {
  final String bankName;
  final String? bankCode;
  final String accountNumberMasked;
  final String accountName;
  final bool isBankConfigured;
  final bool isCooldownActive;
  final int hoursRemaining;
  final String? cooldownExpiresAt;
  final String settledSum;
  final String eligibleSum;
  final String withdrawableBalance;
  final String escrowHeldBalance;
  final String pendingPayoutBalance;
  final String totalSettledBalance;
  final String unrecoveredDebt;
  final List<PayoutRequestRecord> payoutRequests;
  final List<SettledRecord> settledHistory;

  VendorPayoutModel({
    required this.bankName,
    this.bankCode,
    required this.accountNumberMasked,
    required this.accountName,
    required this.isBankConfigured,
    required this.isCooldownActive,
    required this.hoursRemaining,
    this.cooldownExpiresAt,
    required this.settledSum,
    required this.eligibleSum,
    required this.withdrawableBalance,
    required this.escrowHeldBalance,
    required this.pendingPayoutBalance,
    required this.totalSettledBalance,
    required this.unrecoveredDebt,
    required this.payoutRequests,
    required this.settledHistory,
  });

  bool get hasUnrecoveredDebt =>
      (double.tryParse(unrecoveredDebt) ?? 0.0) > 0.0;

  factory VendorPayoutModel.fromJson(Map<String, dynamic> json) {
    final bank = json['bank_details'] as Map<String, dynamic>? ?? {};
    final cooldown = json['security_cooldown'] as Map<String, dynamic>? ?? {};
    final totals = json['totals'] as Map<String, dynamic>? ?? {};
    final balances = json['balances'] as Map<String, dynamic>? ?? {};
    final history = json['settled_history'] as List? ?? [];
    final requests = json['payout_requests'] as List? ?? [];

    final withBal = balances['withdrawable_balance']?.toString() ??
        totals['eligible_sum']?.toString() ??
        '0.00';
    final escrowBal = balances['escrow_held_balance']?.toString() ?? '0.00';
    final pendingBal = balances['pending_payout_balance']?.toString() ?? '0.00';
    final totalSettled = balances['total_settled_balance']?.toString() ??
        totals['settled_sum']?.toString() ??
        '0.00';
    final debt = balances['unrecovered_debt']?.toString() ?? '0.00';

    return VendorPayoutModel(
      bankName: bank['bank_name'] as String? ?? 'No Bank Linked',
      bankCode: bank['bank_code'] as String?,
      accountNumberMasked:
          bank['account_number_masked'] as String? ?? '••••••••••',
      accountName: bank['account_name'] as String? ?? 'N/A',
      isBankConfigured: bank['is_configured'] as bool? ??
          (bank['bank_name'] != null && bank['account_number_masked'] != null),
      isCooldownActive: cooldown['is_active'] as bool? ?? false,
      hoursRemaining: cooldown['hours_remaining'] as int? ?? 0,
      cooldownExpiresAt: cooldown['cooldown_expires_at'] as String?,
      settledSum: totalSettled,
      eligibleSum: withBal,
      withdrawableBalance: withBal,
      escrowHeldBalance: escrowBal,
      pendingPayoutBalance: pendingBal,
      totalSettledBalance: totalSettled,
      unrecoveredDebt: debt,
      payoutRequests: requests
          .map((e) => PayoutRequestRecord.fromJson(e as Map<String, dynamic>))
          .toList(),
      settledHistory: history
          .map((e) => SettledRecord.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PayoutRequestRecord {
  final int id;
  final String amount;
  final String status;
  final String bankName;
  final String accountNumberMasked;
  final String? accountName;
  final String? createdAt;
  final String? disbursedAt;
  final String? rejectionReason;

  PayoutRequestRecord({
    required this.id,
    required this.amount,
    required this.status,
    required this.bankName,
    required this.accountNumberMasked,
    this.accountName,
    this.createdAt,
    this.disbursedAt,
    this.rejectionReason,
  });

  bool get isPending => status == 'pending';
  bool get isApproved => status == 'approved';
  bool get isDisbursed => status == 'disbursed';
  bool get isRejected => status == 'rejected';

  factory PayoutRequestRecord.fromJson(Map<String, dynamic> json) {
    final rawAcc = json['account_number']?.toString() ?? '';
    final masked = rawAcc.length >= 4
        ? '******${rawAcc.substring(rawAcc.length - 4)}'
        : '••••••••••';

    return PayoutRequestRecord(
      id: json['id'] as int? ?? 0,
      amount: json['amount']?.toString() ?? '0.00',
      status: json['status'] as String? ?? 'pending',
      bankName: json['bank_name'] as String? ?? 'Commercial Bank',
      accountNumberMasked: masked,
      accountName: json['account_name'] as String?,
      createdAt: json['created_at'] as String?,
      disbursedAt: json['disbursed_at'] as String?,
      rejectionReason: json['rejection_reason'] as String?,
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
