class VendorReservationModel {
  final int id;
  final String reservationCode;
  final String status;
  final int quantity;
  final String? productName;
  final String? productPrice;
  final String? productThumbnail;
  final String? customerName;
  final String? customerPhone;
  final String? expiresAt;
  final String? createdAt;

  VendorReservationModel({
    required this.id,
    required this.reservationCode,
    required this.status,
    required this.quantity,
    this.productName,
    this.productPrice,
    this.productThumbnail,
    this.customerName,
    this.customerPhone,
    this.expiresAt,
    this.createdAt,
  });

  bool get isPending => status == 'pending';
  bool get isInspected => status == 'inspected';

  factory VendorReservationModel.fromJson(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>?;
    final customer = json['customer'] as Map<String, dynamic>?;

    return VendorReservationModel(
      id: json['id'] as int? ?? 0,
      reservationCode: json['reservation_code'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      quantity: json['quantity'] as int? ?? 1,
      productName: product?['name'] as String? ?? 'Reserved Item',
      productPrice: product?['unit_price']?.toString() ?? '0.00',
      productThumbnail: product?['thumbnail'] as String? ?? product?['image_path'] as String?,
      customerName: customer?['name'] as String? ?? 'Customer',
      customerPhone: customer?['phone'] as String?,
      expiresAt: json['expires_at'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }
}

