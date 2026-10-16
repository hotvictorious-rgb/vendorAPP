import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/vendor_order_model.dart';
import '../../providers/vendor_orders_provider.dart';
import '../../widgets/handover_otp_dialog.dart';

class VendorOrderDetailScreen extends StatelessWidget {
  final VendorOrderModel order;

  const VendorOrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VendorOrdersProvider>();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: Text('Order #${order.orderNumber}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status & Financial Snapshot Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Merchandise Value:', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                      Text(CurrencyFormatter.format(order.grandTotal), style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Guaranteed Merchant Payout (90%):', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.success)),
                      Text(CurrencyFormatter.format(order.vendorNet90), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.success)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Customer Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('CUSTOMER DETAILS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  Text(order.customerName ?? 'Verified Customer', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  if (order.customerPhone != null) ...[
                    const SizedBox(height: 2),
                    Text(order.customerPhone!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: const Color(0xFFF3E8FF), borderRadius: BorderRadius.circular(6)),
                    child: Text(
                      order.fulfillmentType == 'doorstep_delivery' ? '🚚 Directional Doorstep Delivery' : '🏪 In-Shop Customer Pickup',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primaryPurple),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Itemized Products
            const Text('PURCHASED LINE ITEMS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: order.items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final item = order.items[i];
                  return ListTile(
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.scaffoldBackground,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.shopping_bag_outlined, color: AppColors.primaryPurple),
                    ),
                    title: Text(item.productName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    subtitle: Text('Qty: ${item.quantity} • ${CurrencyFormatter.format(item.unitPrice)}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Handover Verification Action
            if (order.orderStatus != 'delivered') ...[
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: order.isReadyForHandover ? const Color(0xFF0D9488) : AppColors.primaryPurple,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: Icon(order.isReadyForHandover ? Icons.key : Icons.check_circle_outline, size: 18),
                  label: Text(
                    order.isReadyForHandover ? 'Verify Courier PIN & Release' : 'Mark Ready for Courier Pickup',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Colors.white),
                  ),
                  onPressed: () {
                    if (order.isReadyForHandover) {
                      HandoverOtpDialog.show(
                        context,
                        orderId: order.id,
                        orderNumber: order.orderNumber,
                        onVerify: (otp) => provider.verifyHandoverOtp(order.id, otp),
                      );
                    } else {
                      provider.markReadyForHandover(order.id);
                    }
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
