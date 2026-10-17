import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/network/api_client.dart';
import 'core/services/storage_service.dart';
import 'core/theme/app_theme.dart';
import 'providers/vendor_auth_provider.dart';
import 'providers/vendor_dashboard_provider.dart';
import 'providers/vendor_orders_provider.dart';
import 'providers/vendor_reservations_provider.dart';
import 'providers/vendor_products_provider.dart';
import 'providers/vendor_payout_provider.dart';
import 'providers/vendor_returns_provider.dart';
import 'providers/vendor_notification_provider.dart';
import 'core/services/firebase_notification_service.dart';
import 'screens/auth/vendor_login_screen.dart';
import 'screens/shell/vendor_shell_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = StorageService();
  await storageService.init();

  final apiClient = ApiClient(storageService: storageService);

  // Background registration of merchant terminal with notification matrix
  FirebaseNotificationService.instance.registerWithBackend(
    apiClient: apiClient,
    storage: storageService,
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<StorageService>.value(value: storageService),
        Provider<ApiClient>.value(value: apiClient),
        ChangeNotifierProvider(
          create: (_) => VendorAuthProvider(
            apiClient: apiClient,
            storageService: storageService,
          )..init(),
        ),
        ChangeNotifierProvider(
          create: (_) => VendorDashboardProvider(
            apiClient: apiClient,
            storageService: storageService,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => VendorOrdersProvider(apiClient: apiClient),
        ),
        ChangeNotifierProvider(
          create: (_) => VendorReservationsProvider(apiClient: apiClient),
        ),
        ChangeNotifierProvider(
          create: (_) => VendorProductsProvider(apiClient: apiClient),
        ),
        ChangeNotifierProvider(
          create: (_) => VendorPayoutProvider(apiClient: apiClient),
        ),
        ChangeNotifierProvider(
          create: (_) => VendorReturnsProvider(apiClient: apiClient),
        ),
        ChangeNotifierProvider(
          create: (_) => VendorNotificationProvider(apiClient)..fetchNotifications(),
        ),
      ],
      child: const VictoriousVendorApp(),
    ),
  );
}

class VictoriousVendorApp extends StatelessWidget {
  const VictoriousVendorApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<VendorAuthProvider>();

    return MaterialApp(
      title: 'Victorious MARKET — Merchant Terminal',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: auth.isAuthenticated ? const VendorShellScreen() : const VendorLoginScreen(),
    );
  }
}
