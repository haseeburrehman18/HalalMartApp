// lib/core/constants/app_constants.dart
// Central place for all app-wide constants

class AppConstants {
  // App Info
  static const String appName = 'Halal Mart';
  static const String appTagline = 'Certified Halal. Always.';

  // Padding & Spacing
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double cardRadius = 16.0;

  // User Roles
  static const String roleUser = 'user';
  static const String roleSeller = 'seller';
  static const String roleAdmin = 'admin';

  // Firestore Collections
  static const String usersCollection = 'users';
  static const String productsCollection = 'products';
  static const String ordersCollection = 'orders';
  static const String certificatesCollection = 'certificates';
  static const String categoriesCollection = 'categories';

  // Product Categories
  static const List<String> categories = [
    'Meat & Poultry',
    'Dairy',
    'Snacks',
    'Beverages',
    'Frozen Foods',
    'Bakery',
    'Grains & Cereals',
    'Condiments',
  ];

  // Order Statuses
  static const String statusPending = 'pending';
  static const String statusProcessing = 'processing';
  static const String statusShipped = 'shipped';
  static const String statusDelivered = 'delivered';
  static const String statusCancelled = 'cancelled';

  // Certificate Statuses
  static const String certPending = 'pending';
  static const String certApproved = 'approved';
  static const String certRejected = 'rejected';
}
