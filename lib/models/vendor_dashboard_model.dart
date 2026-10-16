class VendorDashboardModel {
  final MerchantInfo merchant;
  final ShopInfo? shop;
  final FinancialMetrics financialMetrics;
  final OrdersBreakdown ordersBreakdown;
  final ReservationsBreakdown reservationsBreakdown;
  final InventorySummary inventorySummary;
  final SecurityCooldown securityCooldown;

  VendorDashboardModel({
    required this.merchant,
    this.shop,
    required this.financialMetrics,
    required this.ordersBreakdown,
    required this.reservationsBreakdown,
    required this.inventorySummary,
    required this.securityCooldown,
  });

  factory VendorDashboardModel.fromJson(Map<String, dynamic> json) {
    return VendorDashboardModel(
      merchant: MerchantInfo.fromJson(json['merchant'] as Map<String, dynamic>? ?? {}),
      shop: json['shop'] != null ? ShopInfo.fromJson(json['shop'] as Map<String, dynamic>) : null,
      financialMetrics: FinancialMetrics.fromJson(json['financial_metrics'] as Map<String, dynamic>? ?? {}),
      ordersBreakdown: OrdersBreakdown.fromJson(json['orders_breakdown'] as Map<String, dynamic>? ?? {}),
      reservationsBreakdown: ReservationsBreakdown.fromJson(json['reservations_breakdown'] as Map<String, dynamic>? ?? {}),
      inventorySummary: InventorySummary.fromJson(json['inventory_summary'] as Map<String, dynamic>? ?? {}),
      securityCooldown: SecurityCooldown.fromJson(json['security_cooldown'] as Map<String, dynamic>? ?? {}),
    );
  }
}

class MerchantInfo {
  final int id;
  final String businessName;
  final String marketplaceStatus;
  final String commissionRate;
  final bool isEmployee;
  final String? employeeRole;

  MerchantInfo({
    required this.id,
    required this.businessName,
    required this.marketplaceStatus,
    required this.commissionRate,
    required this.isEmployee,
    this.employeeRole,
  });

  factory MerchantInfo.fromJson(Map<String, dynamic> json) {
    return MerchantInfo(
      id: json['id'] as int? ?? 0,
      businessName: json['business_name'] as String? ?? 'Merchant Enterprise',
      marketplaceStatus: json['marketplace_status'] as String? ?? 'active',
      commissionRate: json['commission_rate']?.toString() ?? '10.00',
      isEmployee: json['is_employee'] as bool? ?? false,
      employeeRole: json['employee_role'] as String?,
    );
  }
}

class ShopInfo {
  final int id;
  final String name;
  final String? address;
  final String? phone;
  final bool pickupEnabled;
  final String lgaName;

  ShopInfo({
    required this.id,
    required this.name,
    this.address,
    this.phone,
    required this.pickupEnabled,
    required this.lgaName,
  });

  factory ShopInfo.fromJson(Map<String, dynamic> json) {
    return ShopInfo(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Main Store',
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      pickupEnabled: json['pickup_enabled'] as bool? ?? true,
      lgaName: json['lga_name'] as String? ?? 'Akwa Ibom',
    );
  }
}

class FinancialMetrics {
  final String grossSales;
  final String net90Earnings;
  final String settledAmount;
  final String pendingEscrow;
  final String currency;
  final String currencySymbol;

  FinancialMetrics({
    required this.grossSales,
    required this.net90Earnings,
    required this.settledAmount,
    required this.pendingEscrow,
    required this.currency,
    required this.currencySymbol,
  });

  factory FinancialMetrics.fromJson(Map<String, dynamic> json) {
    return FinancialMetrics(
      grossSales: json['gross_sales']?.toString() ?? '0.00',
      net90Earnings: json['net_90_earnings']?.toString() ?? '0.00',
      settledAmount: json['settled_amount']?.toString() ?? '0.00',
      pendingEscrow: json['pending_escrow']?.toString() ?? '0.00',
      currency: json['currency'] as String? ?? 'NGN',
      currencySymbol: json['currency_symbol'] as String? ?? '₦',
    );
  }
}

class OrdersBreakdown {
  final int all;
  final int pending;
  final int processing;
  final int readyForHandover;
  final int delivered;

  OrdersBreakdown({
    required this.all,
    required this.pending,
    required this.processing,
    required this.readyForHandover,
    required this.delivered,
  });

  factory OrdersBreakdown.fromJson(Map<String, dynamic> json) {
    return OrdersBreakdown(
      all: json['all'] as int? ?? 0,
      pending: json['pending'] as int? ?? 0,
      processing: json['processing'] as int? ?? 0,
      readyForHandover: json['ready_for_handover'] as int? ?? 0,
      delivered: json['delivered'] as int? ?? 0,
    );
  }
}

class ReservationsBreakdown {
  final int activePending;
  final int approvedInspected;

  ReservationsBreakdown({
    required this.activePending,
    required this.approvedInspected,
  });

  factory ReservationsBreakdown.fromJson(Map<String, dynamic> json) {
    return ReservationsBreakdown(
      activePending: json['active_pending'] as int? ?? 0,
      approvedInspected: json['approved_inspected'] as int? ?? 0,
    );
  }
}

class InventorySummary {
  final int totalProducts;
  final int lowStock;

  InventorySummary({
    required this.totalProducts,
    required this.lowStock,
  });

  factory InventorySummary.fromJson(Map<String, dynamic> json) {
    return InventorySummary(
      totalProducts: json['total_products'] as int? ?? 0,
      lowStock: json['low_stock'] as int? ?? 0,
    );
  }
}

class SecurityCooldown {
  final bool isActive;
  final String? bankName;
  final String? accountName;
  final String? accountNumberMasked;
  final String? bankUpdatedAt;
  final String? cooldownExpiresAt;
  final int hoursRemaining;

  SecurityCooldown({
    required this.isActive,
    this.bankName,
    this.accountName,
    this.accountNumberMasked,
    this.bankUpdatedAt,
    this.cooldownExpiresAt,
    required this.hoursRemaining,
  });

  factory SecurityCooldown.fromJson(Map<String, dynamic> json) {
    return SecurityCooldown(
      isActive: json['is_active'] as bool? ?? false,
      bankName: json['bank_name'] as String?,
      accountName: json['account_name'] as String?,
      accountNumberMasked: json['account_number_masked'] as String?,
      bankUpdatedAt: json['bank_updated_at'] as String?,
      cooldownExpiresAt: json['cooldown_expires_at'] as String?,
      hoursRemaining: json['hours_remaining'] as int? ?? 0,
    );
  }
}
