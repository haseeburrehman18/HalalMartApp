// lib/services/admin_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import '../models/product_model.dart';
import '../models/user_model.dart';
import '../core/constants/app_constants.dart';

class AdminService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _cloudinaryCloudName = 'dr0bln100';
  static const String _cloudinaryUploadPreset = 'halal_mart_unsigned';
  static const String _adminUploadFolder = 'halal_mart/admin_profiles';

  // ─────────────────────────────────────────────────────────────────────
  // PRODUCT APPROVAL METHODS
  // ─────────────────────────────────────────────────────────────────────

  /// Get all pending products as a stream
  Stream<List<ProductModel>> getPendingProducts() {
    return _firestore
        .collection(AppConstants.productsCollection)
        .where('certStatus', isEqualTo: CertificationStatus.pending.name)
        .snapshots()
        .map((snapshot) {
      final products = snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data()))
          .toList();
      products.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return products;
    });
  }

  Stream<int> watchPendingProductsCount() {
    return _firestore
        .collection(AppConstants.productsCollection)
        .where('certStatus', isEqualTo: CertificationStatus.pending.name)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Stream<List<ProductModel>> getApprovedProductRecords() {
    return _firestore
        .collection('product_approval_records')
        .snapshots()
        .map((snapshot) {
      final products = snapshot.docs.map((doc) {
        final data = doc.data();
        return ProductModel.fromMap({
          ...data,
          'id': (data['id'] ?? data['productId'] ?? doc.id).toString(),
        });
      }).toList();
      products.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return products;
    });
  }

  Future<void> deleteApprovedProductRecord(String productId) async {
    await _firestore
        .collection('product_approval_records')
        .doc(productId)
        .delete();
  }

  Future<String> getSellerStoreName(String sellerId, String fallback) async {
    if (sellerId.isEmpty) return fallback;
    final doc =
        await _firestore.collection(AppConstants.usersCollection).doc(sellerId).get();
    final data = doc.data();
    if (data == null) return fallback;
    final shopName = (data['shopName'] ?? '').toString().trim();
    if (shopName.isNotEmpty) return shopName;
    final sellerName = (data['name'] ?? '').toString().trim();
    return sellerName.isNotEmpty ? sellerName : fallback;
  }

  Future<String?> getSellerStoreImageUrl(String sellerId) async {
    if (sellerId.isEmpty) return null;
    final doc =
        await _firestore.collection(AppConstants.usersCollection).doc(sellerId).get();
    final data = doc.data();
    final imageUrl = (data?['photoUrl'] ?? '').toString().trim();
    return imageUrl.isEmpty ? null : imageUrl;
  }

  /// Approve a product
  Future<void> approveProduct(String productId, {String? adminId}) async {
    try {
      final now = DateTime.now();
      final productRef =
          _firestore.collection(AppConstants.productsCollection).doc(productId);
      final productSnapshot = await productRef.get();
      final productData = productSnapshot.data() ?? <String, dynamic>{};
      final sellerStoreName = await getSellerStoreName(
        (productData['sellerId'] ?? '').toString(),
        (productData['sellerName'] ?? '').toString(),
      );
      final sellerStoreImageUrl = await getSellerStoreImageUrl(
        (productData['sellerId'] ?? '').toString(),
      );
      final approvedData = {
        ...productData,
        'certStatus': CertificationStatus.approved.name,
        'sellerStoreName': sellerStoreName,
        if (sellerStoreImageUrl != null)
          'sellerStoreImageUrl': sellerStoreImageUrl,
        'rejectionReason': null,
        'approvedAt': now.toIso8601String(),
        'reviewedAt': now.toIso8601String(),
        'reviewedBy': adminId,
        'reviewSchedule': {
          'submittedAt': FieldValue.serverTimestamp(),
          'reviewedAt': FieldValue.serverTimestamp(),
          'nextManualReviewAt':
              now.add(const Duration(days: 365)).toIso8601String(),
        },
        'retentionPolicy': 'manual_delete_only',
        'updatedAt': now.toIso8601String(),
      };

      final batch = _firestore.batch();
      batch.update(productRef, approvedData);
      batch.set(
        _firestore.collection('product_approval_records').doc(productId),
        {
          ...approvedData,
          'productId': productId,
          'recordType': 'approved_product_snapshot',
          'savedAt': now.toIso8601String(),
          'deleteMode': 'manual_only',
        },
        SetOptions(merge: true),
      );
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to approve product: $e');
    }
  }

  /// Reject a product with reason
  Future<void> rejectProduct(
    String productId,
    String reason, {
    String? adminId,
  }) async {
    try {
      final now = DateTime.now();
      await _firestore
          .collection(AppConstants.productsCollection)
          .doc(productId)
          .update({
        'certStatus': CertificationStatus.rejected.name,
        'rejectionReason': reason,
        'reviewedAt': now.toIso8601String(),
        'reviewedBy': adminId,
        'updatedAt': now.toIso8601String(),
      });
    } catch (e) {
      throw Exception('Failed to reject product: $e');
    }
  }

  Future<String> uploadAdminProfilePhoto({
    required String adminId,
    required XFile imageFile,
  }) async {
    final uploadUrl = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudinaryCloudName/image/upload',
    );
    final imageBytes = await imageFile.readAsBytes();
    final request = http.MultipartRequest('POST', uploadUrl)
      ..fields['upload_preset'] = _cloudinaryUploadPreset
      ..fields['folder'] = _adminUploadFolder
      ..fields['public_id'] = '${adminId}_${DateTime.now().millisecondsSinceEpoch}'
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: imageFile.name.isNotEmpty ? imageFile.name : '$adminId.jpg',
        ),
      );

    final response = await request.send();
    final body = await response.stream.bytesToString();
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Admin photo upload failed: $body');
    }

    final decoded = jsonDecode(body) as Map<String, dynamic>;
    final secureUrl = decoded['secure_url'];
    if (secureUrl is! String || secureUrl.isEmpty) {
      throw Exception('Admin photo upload did not return a URL.');
    }
    return secureUrl;
  }

  // ─────────────────────────────────────────────────────────────────────
  // USER MANAGEMENT METHODS
  // ─────────────────────────────────────────────────────────────────────

  /// Get all users as a stream
  Stream<List<UserModel>> getAllUsers() {
    return _firestore
        .collection(AppConstants.usersCollection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList();
    });
  }

  /// Get users by role as a stream
  Stream<List<UserModel>> getUsersByRole(String role) {
    return _firestore
        .collection(AppConstants.usersCollection)
        .where('role', isEqualTo: role)
        .snapshots()
        .map((snapshot) {
      final users = snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList();
      users.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return users;
    });
  }

  /// Search users by name or email
  Future<List<UserModel>> searchUsers(String query) async {
    if (query.isEmpty) {
      final snapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList();
    }

    try {
      // Firestore doesn't support full-text search, so we fetch and filter
      final snapshot =
          await _firestore.collection(AppConstants.usersCollection).get();

      final queryLower = query.toLowerCase();
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .where((user) =>
              user.name.toLowerCase().contains(queryLower) ||
              user.email.toLowerCase().contains(queryLower))
          .toList();
    } catch (e) {
      throw Exception('Failed to search users: $e');
    }
  }

  /// Enable/Disable user
  Future<void> toggleUserStatus(String userId, bool isEnabled) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({'isEnabled': isEnabled});
    } catch (e) {
      throw Exception('Failed to toggle user status: $e');
    }
  }

  /// Delete a user account
  Future<void> deleteUser(String userId) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  // ─────────────────────────────────────────────────────────────────────
  // DASHBOARD STATS METHODS
  // ─────────────────────────────────────────────────────────────────────

  /// Get total count of users
  Future<int> getTotalUsersCount() async {
    try {
      final snapshot =
          await _firestore.collection(AppConstants.usersCollection).get();
      return snapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get users count: $e');
    }
  }

  /// Get total count of sellers
  Future<int> getSellersCount() async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.usersCollection)
          .where('role', isEqualTo: AppConstants.roleSeller)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get sellers count: $e');
    }
  }

  /// Get total count of products
  Future<int> getProductsCount() async {
    try {
      final snapshot =
          await _firestore.collection(AppConstants.productsCollection).get();
      return snapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get products count: $e');
    }
  }

  /// Get pending products count
  Future<int> getPendingProductsCount() async {
    try {
      final snapshot = await _firestore
          .collection(AppConstants.productsCollection)
          .where('certStatus', isEqualTo: CertificationStatus.pending.name)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get pending products count: $e');
    }
  }
}
