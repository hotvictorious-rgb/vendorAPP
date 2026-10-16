class VendorReturnModel {
  final int id;
  final String caseNumber;
  final int orderId;
  final String orderNumber;
  final String returnReason;
  final String? customerDescription;
  final String? source;
  final String status;
  final String resolutionType;
  final String totalRefundableAmount;
  final String? vendorReturnOtp;
  final String? doorstepPhotoPath;
  final String? vendorReturnPhotoPath;
  final String? returnedToVendorAt;
  final String? returnedByRiderName;
  final String? returnedByRiderPhone;
  final bool vendorDisputed;
  final String? vendorDisputeReason;
  final String? vendorDisputePhotoPath;
  final String? vendorDisputedAt;
  final String? adminRuling;
  final String? adminRuledAt;
  final String? costAllocation;
  final String createdAt;
  final List<VendorReturnItem> items;

  VendorReturnModel({
    required this.id,
    required this.caseNumber,
    required this.orderId,
    required this.orderNumber,
    required this.returnReason,
    this.customerDescription,
    this.source,
    required this.status,
    required this.resolutionType,
    required this.totalRefundableAmount,
    this.vendorReturnOtp,
    this.doorstepPhotoPath,
    this.vendorReturnPhotoPath,
    this.returnedToVendorAt,
    this.returnedByRiderName,
    this.returnedByRiderPhone,
    required this.vendorDisputed,
    this.vendorDisputeReason,
    this.vendorDisputePhotoPath,
    this.vendorDisputedAt,
    this.adminRuling,
    this.adminRuledAt,
    this.costAllocation,
    required this.createdAt,
    required this.items,
  });

  bool get isInTransit => status == 'in_transit_back_to_vendor' || status == 'approved_for_return' || status == 'received_at_hub';
  bool get isReturnedToShop => status == 'returned_to_vendor';
  bool get isDisputed => vendorDisputed || status == 'disputed_by_vendor';
  bool get isResolved => status == 'resolved' || status == 'refunded' || status == 'closed';
  bool get hasEvidencePhotos => doorstepPhotoPath != null || vendorReturnPhotoPath != null || vendorDisputePhotoPath != null || items.any((i) => i.defectPhotoPath != null);

  factory VendorReturnModel.fromJson(Map<String, dynamic> json) {
    final order = json['order'] as Map<String, dynamic>?;
    final rider = json['returned_by_rider'] as Map<String, dynamic>? ?? json['returnedByRider'] as Map<String, dynamic>?;
    final rawItems = json['items'] as List? ?? [];

    return VendorReturnModel(
      id: json['id'] as int? ?? 0,
      caseNumber: json['case_number'] as String? ?? 'RET-00000000',
      orderId: json['order_id'] as int? ?? order?['id'] as int? ?? 0,
      orderNumber: order?['order_number'] as String? ?? json['order_number'] as String? ?? 'Order #${json['order_id'] ?? ''}',
      returnReason: json['return_reason'] as String? ?? 'general_return',
      customerDescription: json['customer_description'] as String?,
      source: json['source'] as String?,
      status: json['status'] as String? ?? 'requested',
      resolutionType: json['resolution_type'] as String? ?? 'refund',
      totalRefundableAmount: json['total_refundable_amount']?.toString() ?? '0.00',
      vendorReturnOtp: json['vendor_return_otp'] as String?,
      doorstepPhotoPath: json['doorstep_photo_path'] as String?,
      vendorReturnPhotoPath: json['vendor_return_photo_path'] as String?,
      returnedToVendorAt: json['returned_to_vendor_at'] as String?,
      returnedByRiderName: rider?['name'] as String?,
      returnedByRiderPhone: rider?['phone'] as String?,
      vendorDisputed: json['vendor_disputed'] as bool? ?? false,
      vendorDisputeReason: json['vendor_dispute_reason'] as String?,
      vendorDisputePhotoPath: json['vendor_dispute_photo_path'] as String?,
      vendorDisputedAt: json['vendor_disputed_at'] as String?,
      adminRuling: json['admin_ruling'] as String?,
      adminRuledAt: json['admin_ruled_at'] as String?,
      costAllocation: json['cost_allocation'] as String?,
      createdAt: json['created_at'] as String? ?? '',
      items: rawItems.map((e) => VendorReturnItem.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class VendorReturnItem {
  final int id;
  final String productName;
  final int quantity;
  final String unitPrice;
  final String refundableAmount;
  final String itemCondition;
  final String status;
  final String? thumbnail;
  final String? defectPhotoPath;

  VendorReturnItem({
    required this.id,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    required this.refundableAmount,
    required this.itemCondition,
    required this.status,
    this.thumbnail,
    this.defectPhotoPath,
  });

  factory VendorReturnItem.fromJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>?;

    return VendorReturnItem(
      id: json['id'] as int? ?? 0,
      productName: product?['name'] as String? ?? json['product_name'] as String? ?? 'Returned Item',
      quantity: json['quantity'] as int? ?? 1,
      unitPrice: json['unit_price']?.toString() ?? '0.00',
      refundableAmount: json['refundable_amount']?.toString() ?? '0.00',
      itemCondition: json['item_condition'] as String? ?? 'opened_tested',
      status: json['status'] as String? ?? 'requested',
      thumbnail: product?['thumbnail'] as String? ?? product?['image_path'] as String?,
      defectPhotoPath: json['defect_photo_path'] as String?,
    );
  }
}
