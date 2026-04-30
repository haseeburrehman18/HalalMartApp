// lib/core/routes/app_routes.dart
// All named route definitions for the app

class AppRoutes {

  // ── Shared ──────────────────────────────────────────────────────────
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';

  // ── User (Main) ─────────────────────────────────────────────────────
  static const String home = '/home';
  static const String categories = '/categories';
  static const String productList = '/product-list';
  static const String productDetail = '/product-detail';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orderConfirmation = '/order-confirmation';
  static const String userProfile = '/user-profile';

  // ── User Profile Features (NEW) ─────────────────────────────────────
  static const String editProfile = '/edit-profile';
  static const String myOrders = '/my-orders';
  static const String savedAddresses = '/saved-addresses';
  static const String paymentMethods = '/payment-methods';
  static const String wishlist = '/wishlist';
  static const String notifications = '/notifications';
  static const String helpSupport = '/help-support';
  static const String settings = '/settings';

  // ── Seller (4 screens) ──────────────────────────────────────────────
  static const String sellerDashboard = '/seller-dashboard';
  static const String addProduct = '/add-product';
  static const String sellerOrders = '/seller-orders';
  static const String uploadCertificate = '/upload-certificate';

  // ── Admin (4 screens) ───────────────────────────────────────────────
  static const String adminDashboard = '/admin-dashboard';
  static const String certificateReview = '/certificate-review';
  static const String productApproval = '/product-approval';
  static const String approvedProducts = '/approved-products';
  static const String userManagement = '/user-management';
}
