import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/vendor_order_model.dart';
import '../../providers/vendor_orders_provider.dart';
import '../../widgets/handover_otp_dialog.dart';
import '../returns/vendor_returns_screen.dart';
import 'vendor_order_detail_screen.dart';

class VendorOrdersScreen extends StatefulWidget {
  const VendorOrdersScreen({super.key});

  @override
  State<VendorOrdersScreen> createState() => _VendorOrdersScreenState();
}

class _VendorOrdersScreenState extends State<VendorOrdersScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchExpanded = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VendorOrdersProvider>();

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: _isSearchExpanded
            ? TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Search order #, customer, phone...',
                  hintStyle: TextStyle(color: Colors.white70, fontSize: 14),
                  border: InputBorder.none,
                ),
                onSubmitted: (val) => provider.setSearchQuery(val),
              )
            : const Text('Orders & Courier Handover'),
        actions: [
          IconButton(
            icon: Icon(_isSearchExpanded ? Icons.close : Icons.search, color: Colors.white),
            tooltip: _isSearchExpanded ? 'Close Search' : 'Search Orders',
            onPressed: () {
              setState(() {
                if (_isSearchExpanded) {
                  _isSearchExpanded = false;
                  _searchController.clear();
                  provider.setSearchQuery('');
                } else {
                  _isSearchExpanded = true;
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.assignment_return_outlined, color: Colors.white),
            tooltip: 'Inbound Returns & Disputes',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const VendorReturnsScreen()),
              );
            },
          ),
        ],
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

          // Active Search Indicator
          if (provider.searchQuery.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: const Color(0xFFF1F5F9),
              child: Row(
                children: [
                  const Icon(Icons.filter_alt_outlined, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    'Search: "${provider.searchQuery}"',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      provider.setSearchQuery('');
                    },
                    child: const Text('Clear', style: TextStyle(fontSize: 12, color: AppColors.primaryPurple, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
          ],

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
    final provider = context.read<VendorOrdersProvider>();

    return FilterChip(
      selected: selected,
      label: Text(label),
      labelStyle: TextStyle(
        fontSize: 12,
        fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
        color: selected ? Colors.white : AppColors.textPrimary,
      ),
      backgroundColor: AppColors.scaffoldBackground,
      selectedColor: AppColors.primaryPurple,
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: selected ? AppColors.primaryPurple : AppColors.border),
      ),
      onSelected: (_) => provider.setFilterStatus(status),
    );
  }

  Widget _buildOrderCard(BuildContext context, VendorOrderModel order) {
    final provider = context.read<VendorOrdersProvider>();

    Color statusColor = AppColors.warning;
    Color statusBg = const Color(0xFFFEF3C7);
    String statusLabel = order.orderStatus.replaceAll('_', ' ').toUpperCase();

    if (order.orderStatus == 'delivered') {
      statusColor = AppColors.success;
      statusBg = const Color(0xFFDCFCE7);
    } else if (order.isReadyForHandover) {
      statusColor = const Color(0xFF0D9488);
      statusBg = const Color(0xFFCCFBF1);
      statusLabel = 'READY FOR COURIER';
    }

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => VendorOrderDetailScreen(order: order)),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: Order Number & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      '#${order.orderNumber}',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppColors.textPrimary),
                    ),
                    if (order.hasPhotoAudits) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF2FF),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: const Color(0xFFC7D2FE)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.photo_camera, size: 10, color: Color(0xFF4338CA)),
                            SizedBox(width: 2),
                            Text(
                              'Proof Snaps',
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF4338CA)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(6)),
                  child: Text(
                    statusLabel,
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: statusColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Customer info & fulfillment mode
            Row(
              children: [
                const Icon(Icons.person_outline, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 4),
                Text(
                  order.customerName ?? 'Verified Customer',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(color: const Color(0xFFF3E8FF), borderRadius: BorderRadius.circular(4)),
                  child: Text(
                    order.fulfillmentType == 'doorstep_delivery' ? 'Delivery' : 'Pickup',
                    style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.primaryPurple),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${order.items.length} ${order.items.length == 1 ? 'item' : 'items'}',
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
            const Divider(height: 18),

            // Payout value & Action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Merchant Net 90%', style: TextStyle(fontSize: 10, color: AppColors.textSecondary)),
                    Text(
                      CurrencyFormatter.format(order.vendorNet90),
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, color: AppColors.success),
                    ),
                  ],
                ),
                if (order.orderStatus != 'delivered') ...[
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: order.isReadyForHandover ? const Color(0xFF0D9488) : AppColors.primaryPurple,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      visualDensity: VisualDensity.compact,
                    ),
                    icon: Icon(order.isReadyForHandover ? Icons.key : Icons.check_circle_outline, size: 14),
                    label: Text(
                      order.isReadyForHandover ? 'Verify OTP' : 'Mark Ready',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: Colors.white),
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
                ] else ...[
                  const Text('Completed', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textSecondary)),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border),
            ),
            child: const Icon(Icons.inbox_outlined, size: 48, color: AppColors.primaryPurple),
          ),
          const SizedBox(height: 16),
          const Text('No Orders Found', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 4),
          const Text('Orders matching your filter or search will appear here live.', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
