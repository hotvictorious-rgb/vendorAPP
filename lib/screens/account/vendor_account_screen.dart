import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/storage_service.dart';
import '../../providers/vendor_auth_provider.dart';
import '../../providers/vendor_dashboard_provider.dart';
import '../auth/vendor_login_screen.dart';
import '../returns/vendor_returns_screen.dart';

class VendorAccountScreen extends StatefulWidget {
  const VendorAccountScreen({super.key});

  @override
  State<VendorAccountScreen> createState() => _VendorAccountScreenState();
}

class _VendorAccountScreenState extends State<VendorAccountScreen> {
  final _serverController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final storage = context.read<StorageService>();
    _serverController.text = storage.getBaseUrl();
  }

  @override
  void dispose() {
    _serverController.dispose();
    super.dispose();
  }

  void _saveServerUrl() async {
    final storage = context.read<StorageService>();
    await storage.saveBaseUrl(_serverController.text.trim());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('API Server Endpoint updated.'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  void _handleLogout() async {
    final auth = context.read<VendorAuthProvider>();
    await auth.logout();
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const VendorLoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<VendorAuthProvider>();
    final dash = context.watch<VendorDashboardProvider>();
    final user = auth.currentUser;
    final shop = dash.dashboardData?.shop;

    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      appBar: AppBar(
        title: const Text('Storefront & Account Settings'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: AppColors.primaryPurple.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.store, color: AppColors.primaryPurple, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user?.name ?? 'Merchant', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                        Text(user?.email ?? '', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'ROLE: ${user?.userType.toUpperCase() ?? 'MERCHANT'}',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF15803D)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Branch Details Card
            if (shop != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('BRANCH OUTLET INFO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
                    const SizedBox(height: 6),
                    Text(shop.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    if (shop.address != null) ...[
                      const SizedBox(height: 2),
                      Text(shop.address!, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    ],
                    Text(shop.lgaName, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primaryPurple)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Inbound Returns & Counter-Dispute Desk Tile
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3E8FF),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.assignment_return_outlined, color: AppColors.primaryPurple, size: 22),
                ),
                title: const Text('Inbound Returns & Arbitration Desk', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                subtitle: const Text('Customer returns, courier OTPs & counter-disputes', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const VendorReturnsScreen()),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // API Server Endpoint Configurator Card
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
                  const Text('API SERVER ENDPOINT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.textSecondary)),
                  const SizedBox(height: 4),
                  const Text(
                    'Configure connection address for local development or remote live staging server.',
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _serverController,
                          decoration: InputDecoration(
                            isDense: true,
                            hintText: 'http://127.0.0.1:8080',
                            filled: true,
                            fillColor: AppColors.scaffoldBackground,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.border)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryPurple,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        onPressed: _saveServerUrl,
                        child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Terminate Terminal Session', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                onPressed: _handleLogout,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
