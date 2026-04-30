// lib/providers/admin_provider.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../models/user_model.dart';
import '../services/admin_service.dart';

class AdminProvider extends ChangeNotifier {
  final AdminService _adminService = AdminService();
  StreamSubscription<List<ProductModel>>? _pendingProductsSubscription;
  StreamSubscription<List<ProductModel>>? _approvedProductsSubscription;
  StreamSubscription<List<UserModel>>? _usersSubscription;

  // ─────────────────────────────────────────────────────────────────────
  // PRODUCT APPROVAL STATE
  // ─────────────────────────────────────────────────────────────────────

  List<ProductModel> _pendingProducts = [];
  bool _isLoadingProducts = false;
  String? _productsError;

  List<ProductModel> get pendingProducts => _pendingProducts;
  bool get isLoadingProducts => _isLoadingProducts;
  String? get productsError => _productsError;
  List<ProductModel> _approvedProductRecords = [];
  bool _isLoadingApprovedProducts = false;

  List<ProductModel> get approvedProductRecords => _approvedProductRecords;
  bool get isLoadingApprovedProducts => _isLoadingApprovedProducts;

  /// Listen to pending products stream
  void listenToPendingProducts() {
    _isLoadingProducts = true;
    notifyListeners();
    _pendingProductsSubscription?.cancel();
    _pendingProductsSubscription = _adminService.getPendingProducts().listen(
      (products) {
        _pendingProducts = products;
        _pendingCount = products.length;
        _isLoadingProducts = false;
        _productsError = null;
        notifyListeners();
      },
      onError: (error) {
        _productsError = error.toString();
        _isLoadingProducts = false;
        notifyListeners();
      },
    );
  }

  /// Approve a product
  Future<void> approveProduct(String productId, {String? adminId}) async {
    try {
      await _adminService.approveProduct(productId, adminId: adminId);
      notifyListeners();
    } catch (e) {
      _productsError = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Reject a product with reason
  Future<void> rejectProduct(
    String productId,
    String reason, {
    String? adminId,
  }) async {
    try {
      await _adminService.rejectProduct(productId, reason, adminId: adminId);
      notifyListeners();
    } catch (e) {
      _productsError = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────────────
  // USER MANAGEMENT STATE
  // ─────────────────────────────────────────────────────────────────────

  List<UserModel> _allUsers = [];
  List<UserModel> _filteredUsers = [];
  String _userFilterRole = 'all';
  String _userSearchQuery = '';
  bool _isLoadingUsers = false;
  String? _usersError;

  List<UserModel> get filteredUsers => _filteredUsers;
  bool get isLoadingUsers => _isLoadingUsers;
  String? get usersError => _usersError;
  String get userFilterRole => _userFilterRole;

  /// Initialize user management by listening to all users
  void initializeUserManagement() {
    _isLoadingUsers = true;
    notifyListeners();

    _usersSubscription?.cancel();
    _usersSubscription = _adminService.getAllUsers().listen(
      (users) {
        _allUsers = users;
        _applyUserFilters();
        _isLoadingUsers = false;
        _usersError = null;
        notifyListeners();
      },
      onError: (error) {
        _usersError = error.toString();
        _isLoadingUsers = false;
        notifyListeners();
      },
    );
  }

  /// Filter users by role and search query
  void _applyUserFilters() {
    _filteredUsers = _allUsers;

    // Filter by role
    if (_userFilterRole != 'all') {
      _filteredUsers = _filteredUsers
          .where((user) => user.role == _userFilterRole)
          .toList();
    }

    // Filter by search query
    if (_userSearchQuery.isNotEmpty) {
      final queryLower = _userSearchQuery.toLowerCase();
      _filteredUsers = _filteredUsers
          .where((user) =>
              user.name.toLowerCase().contains(queryLower) ||
              user.email.toLowerCase().contains(queryLower))
          .toList();
    }
  }

  /// Set user role filter
  void setUserRoleFilter(String role) {
    _userFilterRole = role;
    _applyUserFilters();
    notifyListeners();
  }

  /// Search users by name or email
  void searchUsers(String query) {
    _userSearchQuery = query;
    _applyUserFilters();
    notifyListeners();
  }

  /// Toggle user enabled/disabled status
  Future<void> toggleUserStatus(String userId, bool isEnabled) async {
    try {
      await _adminService.toggleUserStatus(userId, isEnabled);
      // Update local state
      final index = _allUsers.indexWhere((u) => u.uid == userId);
      if (index != -1) {
        _allUsers[index] = _allUsers[index].copyWith(isEnabled: isEnabled);
        _applyUserFilters();
        notifyListeners();
      }
    } catch (e) {
      _usersError = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Delete a user
  Future<void> deleteUser(String userId) async {
    try {
      await _adminService.deleteUser(userId);
      _allUsers.removeWhere((u) => u.uid == userId);
      _applyUserFilters();
      notifyListeners();
    } catch (e) {
      _usersError = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────────────
  // DASHBOARD STATS
  // ─────────────────────────────────────────────────────────────────────

  int _totalUsers = 0;
  int _totalSellers = 0;
  int _totalProducts = 0;
  int _pendingCount = 0;
  bool _isLoadingStats = false;

  int get totalUsers => _totalUsers;
  int get totalSellers => _totalSellers;
  int get totalProducts => _totalProducts;
  int get pendingCount => _pendingCount;
  bool get isLoadingStats => _isLoadingStats;

  /// Load dashboard stats
  Future<void> loadDashboardStats() async {
    _isLoadingStats = true;
    notifyListeners();

    try {
      _totalUsers = await _adminService.getTotalUsersCount();
      _totalSellers = await _adminService.getSellersCount();
      _totalProducts = await _adminService.getProductsCount();
      _pendingCount = await _adminService.getPendingProductsCount();
      _isLoadingStats = false;
      notifyListeners();
    } catch (e) {
      _isLoadingStats = false;
      notifyListeners();
      rethrow;
    }
  }

  // ─────────────────────────────────────────────────────────────────────
  // CLEANUP
  // ─────────────────────────────────────────────────────────────────────

  void clearErrors() {
    _productsError = null;
    _usersError = null;
    notifyListeners();
  }

  void listenToApprovedProductRecords() {
    _isLoadingApprovedProducts = true;
    notifyListeners();
    _approvedProductsSubscription?.cancel();
    _approvedProductsSubscription = _adminService.getApprovedProductRecords().listen(
      (products) {
        _approvedProductRecords = products;
        _isLoadingApprovedProducts = false;
        _productsError = null;
        notifyListeners();
      },
      onError: (error) {
        _productsError = error.toString();
        _isLoadingApprovedProducts = false;
        notifyListeners();
      },
    );
  }

  Future<void> deleteApprovedProductRecord(String productId) async {
    try {
      await _adminService.deleteApprovedProductRecord(productId);
    } catch (e) {
      _productsError = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    _pendingProductsSubscription?.cancel();
    _approvedProductsSubscription?.cancel();
    _usersSubscription?.cancel();
    super.dispose();
  }
}
