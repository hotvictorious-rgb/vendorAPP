class VendorOrderModel {
  final int id;
  final String orderNumber;
  final String orderStatus;
  final String paymentStatus;
  final String fulfillmentType;
  final String grandTotal;
  final String vendorNet90;
  final String? customerName;
  final String? customerPhone;
  final String? pickupVerificationCode;
  final String? vendorHandoverReadyAt;
  final bool pickupConfirmedByRider;
  final String? riderName;
  final String? riderPhone;
  final String? riderPlateNumber;
  final List<VendorOrderItem> items;
  final String createdAt;

  VendorOrderModel({
    required this.id,
    required this.orderNumber,
    required this.orderStatus,
    required this.paymentStatus,
    required this.fulfillmentType,
    required this.grandTotal,
    required this.vendorNet90,
    this.customerName,
    this.customerPhone,
    this.pickupVerificationCode,
    this.vendorHandoverReadyAt,
    required this.pickupConfirmedByRider,
    this.riderName,
    this.riderPhone,
    this.riderPlateNumber,
    required this.items,
    required this.createdAt,
  });

  bool get isReadyForHandover => vendorHandoverReadyAt != null || orderStatus == 'ready_for_pickup';

  factory VendorOrderModel.fromJson(Map<String, dynamic> json) {
    final customer = json['customer'] as Map<String, dynamic>?;
    final rider = json['rider'] as Map<String, dynamic>?;
    final riderUser = rider?['user'] as Map<String, dynamic>?;

    final rawItems = json['items'] as List? ?? json['order_items'] as List? ?? [];
    final itemsList = rawItems.map((e) => VendorOrderItem.fromJson(e as Map<String, dynamic>)).toList();

    return VendorOrderModel(
      id: json['id'] as int? ?? 0,
      orderNumber: json['order_number'] as String? ?? '',
      orderStatus: json['order_status'] as String? ?? 'pending',
      paymentStatus: json['payment_status'] as String? ?? 'unpaid',
      fulfillmentType: json['fulfillment_type'] as String? ?? 'doorstep_delivery',
      grandTotal: json['grand_total']?.toString() ?? '0.00',
      vendorNet90: json['vendor_net_90']?.toString() ?? '0.00',
      customerName: customer?['name'] as String? ?? 'Customer',
      customerPhone: customer?['phone'] as String?,
      pickupVerificationCode: json['pickup_verification_code'] as String?,
      vendorHandoverReadyAt: json['vendor_handover_ready_at'] as String?,
      pickupConfirmedByRider: json['pickup_confirmed_by_rider'] as bool? ?? false,
      riderName: riderUser?['name'] as String?,
      riderPhone: riderUser?['phone'] as String?,
      riderPlateNumber: rider?['plate_number'] as String?,
      items: itemsList,
      createdAt: json['created_at'] as String? ?? '',
    );
  }
}

class VendorOrderItem {
  final int id;
  final int productId;
  final String productName;
  final String unitPrice;
  final int quantity;
  final String? thumbnail;

  VendorOrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    this.thumbnail,
  });

  factory VendorOrderItem.fromJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>?;

    return VendorOrderItem(
      id: json['id'] as int? ?? 0,
      productId: json['product_id'] as int? ?? 0,
      productName: product?['name'] as String? ?? json['product_name'] as String? ?? 'Item',
      unitPrice: json['unit_price']?.toString() ?? product?['unit_price']?.toString() ?? '0.00',
      quantity: json['quantity'] as int? ?? 1,
      thumbnail: product?['thumbnail'] as String? ?? product?['image_path'] as String?,
    );
  }
}
