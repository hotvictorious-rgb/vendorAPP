class ApiEndpoints {
  static const String defaultBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8080',
  );

  static const String appConfig = '/api/v1/config';
  static const String login = '/api/v1/auth/login';
  static const String me = '/api/v1/auth/me';

  // Vendor Terminal Endpoints
  static const String dashboard = '/api/v1/vendor/dashboard';
  static const String orders = '/api/v1/vendor/orders';
  static const String orderDetails = '/api/v1/vendor/orders/'; // + {id}
  static const String markReady = '/api/v1/vendor/orders/'; // + {id}/ready-for-handover
  static const String verifyHandoverOtp = '/api/v1/vendor/orders/verify-handover-otp';
  static const String pickupReservations = '/api/v1/vendor/pickup-reservations';
  static const String verifyInspection = '/api/v1/vendor/pickup-reservations/verify-inspection';
  static const String products = '/api/v1/vendor/products';
  static const String refreshFreshness = '/api/v1/vendor/products/'; // + {id}/freshness
  static const String toggleStock = '/api/v1/vendor/products/'; // + {id}/toggle-stock
  static const String payouts = '/api/v1/vendor/payouts';
  static const String updateBank = '/api/v1/vendor/bank/update';
  static const String categories = '/api/v1/categories';

  // Inbound Returns & Counter-Dispute Desk
  static const String returns = '/api/v1/vendor/returns';
  static const String disputeReturn = '/api/v1/vendor/returns/'; // + {case_number}/dispute
}
