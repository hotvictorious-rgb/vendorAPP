import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/vendor_order_model.dart';
import '../../providers/vendor_orders_provider.dart';
import '../../widgets/handover_otp_dialog.dart';
import 'vendor_order_detail_screen.dart';

class VendorOrdersScreen extends StatelessWidget {
  const VendorOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VendorOrdersProvider>();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Orders & Courier Handover'),
      ),
      body: Column(
        children: [
          // Filter Chips Row
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(context, label: 'All Orders', status: 'all', selected: provider.selectedStatus == 'all'),
                  const SizedBox(width: 8),
                  _buildFilterChip(context, label: 'Processing', status: 'processing', selected: provider.selectedStatus == 'processing'),
                  const SizedBox(width: 8),
                  _buildFilterChip(context, label: 'Ready for Courier', status: 'ready_for_handover', selected: provider.selectedStatus == 'ready_for_handover'),
                  const SizedBox(width: 8),
                  _buildFilterChip(context, label: 'Delivered', status: 'delivered', selected: provider.selectedStatus == 'delivered'),
                ],
              ),
            ),
          ),
          const Divider(height: 1, color: AppColors.border),

          // Orders List
          Expanded(
            child: provider.isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primaryPurple))
                : provider.orders.isEmpty
                    ? _buildEmptyState()
                    : RefreshIndicator(
                        color: AppColors.primaryPurple,
                        onRefresh: () => provider.fetchOrders(),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: provider.orders.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final order = provider.orders[index];
                            return _buildOrderCard(context, order);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    BuildContext context, {
    required String label,
    required String status,
    required bool selected,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      selectedColor: AppColors.primaryPurple,
      backgroundColor: AppColors.scaffoldBackground,
      labelStyle: TextStyle(
        color: selected ? Colors.white : AppColors.textPrimary,
        fontWeight: FontWeight.w700,
        fontSize: 12,
      ),
      onSelected: (_) => context.read<VendorOrdersProvider>().setFilterStatus(status),
    );
  }

  Widget _buildOrderCard(BuildContext context, VendorOrderModel order) {
    final provider = context.read<VendorOrdersProvider>();

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => VendorOrderDetailScreen(order: order)),
        );
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order Number & Status Chip
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.orderNumber,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.primaryPurple),
                ),
                _buildStatusChip(order.orderStatus),
              ],
            ),
            const SizedBox(height: 8),

            // Customer & Items
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${order.customerName ?? 'Customer'} • ${order.items.length} item(s)',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                ),
                Text(
                  CurrencyFormatter.format(order.grandTotal),
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppColors.textPrimary),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Vendor Net 90%
            Text(
              'Net Payout (90%): ${CurrencyFormatter.format(order.vendorNet90)}',
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.success),
            ),
            const SizedBox(height: 12),

            // Action Buttons Row
            Row(
              children: [
                if (!order.isReadyForHandover && order.orderStatus != 'delivered') ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryPurple,
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.check_circle_outline, size: 15),
                      label: const Text('Mark Ready for Courier', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                      onPressed: () async {
                        final ok = await provider.markReadyForHandover(order.id);
                        if (ok && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Order #${order.orderNumber} marked ready for dispatch.'),
                              backgroundColor: AppColors.primaryPurple,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
                if (order.isReadyForHandover && order.orderStatus != 'delivered') ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D9488),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: const Icon(Icons.key, size: 15),
                      label: const Text('Verify Handover PIN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                      onPressed: () {
                        HandoverOtpDialog.show(
                          context,
                          orderId: order.id,
                          orderNumber: order.orderNumber,
                          onVerify: (otp) => provider.verifyHandoverOtp(order.id, otp),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color bg = const Color(0xFFF3F4F6);
    Color fg = const Color(0xFF374151);
    String label = status.replaceAll('_', ' ').toUpperCase();

    if (status == 'delivered') {
      bg = const Color(0xFFDCFCE7);
      fg = const Color(0xFF15803D);
    } else if (status == 'ready_for_pickup') {
      bg = const Color(0xFFFEF3C7);
      fg = const Color(0xFFB45309);
      label = 'READY FOR COURIER';
    } else if (status == 'processing') {
      bg = const Color(0xFFDBEAFE);
      fg = const Color(0xFF1E40AF);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: fg)),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.inventory_2_outlined, size: 54, color: AppColors.textMuted),
          SizedBox(height: 12),
          Text('No orders in this queue', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textPrimary)),
          SizedBox(height: 4),
          Text('New customer purchases will appear here live.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
