// lib/core/routes/route_generator.dart
// Centralised route factory — maps named routes to screen widgets

import 'package:flutter/material.dart';
import 'app_routes.dart';

// User screens
import '../../views/user/splash_screen.dart';
import '../../views/user/onboarding_screen.dart';
import '../../views/user/login_screen.dart';
import '../../views/user/register_screen.dart';
import '../../views/user/home_screen.dart';
import '../../views/user/categories_screen.dart';
import '../../views/user/product_list_screen.dart';
import '../../views/user/product_detail_screen.dart';
import '../../views/user/cart_screen.dart';
import '../../views/user/checkout_screen.dart';
import '../../views/user/order_confirmation_screen.dart';
import '../../views/user/user_profile_screen.dart';
import '../../views/user/profile_feature_screens.dart';

// Seller screens
import '../../views/seller/seller_dashboard_screen.dart';
import '../../views/seller/add_product_screen.dart';
import '../../views/seller/seller_orders_screen.dart';
import '../../views/seller/upload_certificate_screen.dart';
import '../../views/seller/my_products_screen.dart';

// Admin screens
import '../../views/admin/admin_dashboard_screen.dart';
import '../../views/admin/product_approval_screen.dart';
import '../../views/admin/approved_products_screen.dart';
import '../../views/admin/user_management_screen.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;
    final name = settings.name ?? '';

    if (name.startsWith('${AppRoutes.productDetail}/')) {
      final productId = Uri.decodeComponent(
        name.substring('${AppRoutes.productDetail}/'.length),
      );
      return _build(ProductDetailScreen(productId: productId), settings);
    }

    switch (name) {
      // ── Shared ──────────────────────────────────────────────────────
      case AppRoutes.splash:
        return _build(const SplashScreen(), settings);
      case AppRoutes.onboarding:
        return _build(const OnboardingScreen(), settings);
      case AppRoutes.login:
        return _build(const LoginScreen(), settings);
      case AppRoutes.register:
        return _build(const RegisterScreen(), settings);

      // ── User ────────────────────────────────────────────────────────
      case AppRoutes.home:
        return _build(const HomeScreen(), settings);
      case AppRoutes.categories:
        return _build(const CategoriesScreen(), settings);
      case AppRoutes.productList:
        return _build(ProductListScreen(category: args as String? ?? 'All'), settings);
      case AppRoutes.productDetail:
        return _build(ProductDetailScreen(productId: args as String? ?? ''), settings);
      case AppRoutes.cart:
        return _build(const CartScreen(), settings);
      case AppRoutes.checkout:
        return _build(const CheckoutScreen(), settings);
      case AppRoutes.orderConfirmation:
        return _build(const OrderConfirmationScreen(), settings);
      case AppRoutes.userProfile:
        return _build(const UserProfileScreen(), settings);
      case AppRoutes.editProfile:
        return _build(const EditProfileScreen(), settings);
      case AppRoutes.myOrders:
        return _build(const MyOrdersScreen(), settings);
      case AppRoutes.savedAddresses:
        return _build(const SavedAddressesScreen(), settings);
      case AppRoutes.paymentMethods:
        return _build(const PaymentMethodsScreen(), settings);
      case AppRoutes.wishlist:
        return _build(const WishlistScreen(), settings);
      case AppRoutes.notifications:
        return _build(const NotificationsScreen(), settings);
      case AppRoutes.helpSupport:
        return _build(const HelpSupportScreen(), settings);
      case AppRoutes.settings:
        return _build(const SettingsScreen(), settings);

      // ── Seller ──────────────────────────────────────────────────────
      case AppRoutes.sellerDashboard:
        return _build(const SellerDashboardScreen(), settings);
      case AppRoutes.addProduct:
        return _build(const AddProductScreen(), settings);
      case AppRoutes.sellerOrders:
        return _build(const SellerOrdersScreen(), settings);
      case AppRoutes.uploadCertificate:
        return _build(const UploadCertificateScreen(), settings);
      case '/my-products':
        return _build(const MyProductsScreen(), settings);

      // ── Admin ───────────────────────────────────────────────────────
      case AppRoutes.adminDashboard:
        return _build(const AdminDashboardScreen(), settings);
      case AppRoutes.productApproval:
        return _build(const ProductApprovalScreen(), settings);
      case AppRoutes.approvedProducts:
        return _build(const ApprovedProductsScreen(), settings);
      case AppRoutes.userManagement:
        return _build(const UserManagementScreen(), settings);

      default:
        return _errorRoute(settings.name);
    }
  }

  static MaterialPageRoute _build(Widget page, RouteSettings settings) {
    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }

  static Route<dynamic> _errorRoute(String? name) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Page Not Found')),
        body: Center(child: Text('No route defined for "$name"')),
      ),
    );
  }
}
