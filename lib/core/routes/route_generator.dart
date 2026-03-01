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

// Seller screens
import '../../views/seller/seller_dashboard_screen.dart';
import '../../views/seller/add_product_screen.dart';
import '../../views/seller/seller_orders_screen.dart';
import '../../views/seller/upload_certificate_screen.dart';

// Admin screens
import '../../views/admin/admin_dashboard_screen.dart';
import '../../views/admin/certificate_review_screen.dart';
import '../../views/admin/product_approval_screen.dart';
import '../../views/admin/user_management_screen.dart';

class RouteGenerator {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    final args = settings.arguments;

    switch (settings.name) {
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

      // ── Seller ──────────────────────────────────────────────────────
      case AppRoutes.sellerDashboard:
        return _build(const SellerDashboardScreen(), settings);
      case AppRoutes.addProduct:
        return _build(const AddProductScreen(), settings);
      case AppRoutes.sellerOrders:
        return _build(const SellerOrdersScreen(), settings);
      case AppRoutes.uploadCertificate:
        return _build(const UploadCertificateScreen(), settings);

      // ── Admin ───────────────────────────────────────────────────────
      case AppRoutes.adminDashboard:
        return _build(const AdminDashboardScreen(), settings);
      case AppRoutes.certificateReview:
        return _build(const CertificateReviewScreen(), settings);
      case AppRoutes.productApproval:
        return _build(const ProductApprovalScreen(), settings);
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
