import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/vendor_dashboard_provider.dart';
import '../../providers/vendor_orders_provider.dart';
import '../../providers/vendor_reservations_provider.dart';
import '../../providers/vendor_products_provider.dart';
import '../../providers/vendor_payout_provider.dart';
import '../dashboard/vendor_dashboard_screen.dart';
import '../orders/vendor_orders_screen.dart';
import '../reservations/vendor_reservations_screen.dart';
import '../products/vendor_products_screen.dart';
import '../payout/vendor_payout_screen.dart';

class VendorShellScreen extends StatefulWidget {
  const VendorShellScreen({super.key});

  @override
  State<VendorShellScreen> createState() => _VendorShellScreenState();
}

class _VendorShellScreenState extends State<VendorShellScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    VendorDashboardScreen(),
    VendorOrdersScreen(),
    VendorReservationsScreen(),
    VendorProductsScreen(),
    VendorPayoutScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VendorDashboardProvider>().fetchDashboard();
      context.read<VendorOrdersProvider>().fetchOrders();
      context.read<VendorReservationsProvider>().fetchReservations();
      context.read<VendorProductsProvider>().fetchProducts();
      context.read<VendorPayoutProvider>().fetchPayouts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<VendorOrdersProvider>();
    final pendingOrdersCount = orders.orders.where((o) => o.orderStatus == 'processing' || o.orderStatus == 'pending').length;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.primaryPurple,
          unselectedItemColor: AppColors.textSecondary,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
          elevation: 0,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard),
              label: 'Overview',
            ),
            BottomNavigationBarItem(
              icon: Badge(
                isLabelVisible: pendingOrdersCount > 0,
                label: Text('$pendingOrdersCount'),
                backgroundColor: AppColors.error,
                child: const Icon(Icons.local_shipping_outlined),
              ),
              activeIcon: Badge(
                isLabelVisible: pendingOrdersCount > 0,
                label: Text('$pendingOrdersCount'),
                backgroundColor: AppColors.error,
                child: const Icon(Icons.local_shipping),
              ),
              label: 'Orders',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_2_outlined),
              activeIcon: Icon(Icons.qr_code_2),
              label: 'Passes',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              activeIcon: Icon(Icons.inventory_2),
              label: 'Catalog',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined),
              activeIcon: Icon(Icons.account_balance_wallet),
              label: 'Payouts',
            ),
          ],
        ),
      ),
    );
  }
}
