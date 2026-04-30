// lib/services/product_service.dart
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../models/product_model.dart';
import '../core/constants/app_constants.dart';

class SellerDashboardStats {
  final double totalSales;
  final int ordersCount;
  final int productsCount;
  final int pendingProductsCount;
  final double averageRating;

  const SellerDashboardStats({
    required this.totalSales,
    required this.ordersCount,
    required this.productsCount,
    required this.pendingProductsCount,
    required this.averageRating,
  });
}

class ProductReview {
  final String id;
  final String userId;
  final String userName;
  final double rating;
  final String comment;
  final DateTime createdAt;

  const ProductReview({
    required this.id,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory ProductReview.fromMap(Map<String, dynamic> map) {
    return ProductReview(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? 'Customer',
      rating: (map['rating'] ?? 0).toDouble(),
      comment: map['comment'] ?? '',
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _collection = 'products';
  static const String _cloudinaryCloudName = 'dr0bln100';
  static const String _cloudinaryUploadPreset = 'halal_mart_unsigned';
  static const String _cloudinaryUploadFolder = 'halal_mart/products';

  /// Add a new product
  Future<void> addProduct(ProductModel product, XFile? imageFile) async {
    try {
      String imageUrl = '';
      if (imageFile != null) {
        imageUrl = await _uploadImage(imageFile, product.id);
      }

      final productToAdd = product.copyWith(imageUrl: imageUrl);

      // Use toMap but ensure id is part of it or use doc(id).set
      await _firestore.collection(_collection).doc(product.id).set(productToAdd.toMap());
    } catch (e) {
      rethrow;
    }
  }

  /// Upload image to Cloudinary and return the public HTTPS URL.
  Future<String> _uploadImage(XFile file, String productId) async {
    final uploadUrl = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudinaryCloudName/image/upload',
    );
    final imageBytes = await file.readAsBytes();

    final request = http.MultipartRequest('POST', uploadUrl)
      ..fields['upload_preset'] = _cloudinaryUploadPreset
      ..fields['folder'] = _cloudinaryUploadFolder
      ..fields['public_id'] = '${productId}_${DateTime.now().millisecondsSinceEpoch}'
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          imageBytes,
          filename: file.name.isNotEmpty ? file.name : '$productId.jpg',
        ),
      );

    final streamedResponse = await request.send();
    final body = await streamedResponse.stream.bytesToString();
    if (streamedResponse.statusCode < 200 ||
        streamedResponse.statusCode >= 300) {
      final decodedBody = _tryDecodeJson(body);
      final error = decodedBody?['error'];
      final message = error is Map<String, dynamic> ? error['message'] : body;
      throw Exception('Cloudinary upload failed: $message');
    }

    final decodedBody = _tryDecodeJson(body);
    final secureUrl = decodedBody?['secure_url'];
    if (secureUrl is! String || secureUrl.isEmpty) {
      throw Exception('Cloudinary upload did not return a secure image URL.');
    }

    return secureUrl;
  }

  Future<void> deleteSellerProduct({
    required String sellerId,
    required String productId,
  }) async {
    final doc = await _firestore.collection(_collection).doc(productId).get();
    final data = doc.data();
    if (!doc.exists || data == null) {
      throw Exception('Product no longer exists.');
    }
    if ((data['sellerId'] ?? '').toString() != sellerId) {
      throw Exception('You can only delete your own products.');
    }
    await _firestore.collection(_collection).doc(productId).delete();
  }

  Future<void> updateSellerStoreImage({
    required String sellerId,
    required String imageUrl,
  }) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('sellerId', isEqualTo: sellerId)
        .get();
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {
        'sellerStoreImageUrl': imageUrl,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    }
    await batch.commit();
  }

  Map<String, dynamic>? _tryDecodeJson(String body) {
    try {
      final decodedBody = jsonDecode(body);
      if (decodedBody is Map<String, dynamic>) {
        return decodedBody;
      }
    } on FormatException {
      return null;
    }

    return null;
  }

  /// Get products by seller ID
  Stream<List<ProductModel>> getSellerProducts(String sellerId) {
    return _firestore
        .collection(_collection)
        .where('sellerId', isEqualTo: sellerId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data()))
          .toList();
    });
  }

  /// Get real seller dashboard values from Firestore.
  Future<SellerDashboardStats> getSellerDashboardStats(String sellerId) async {
    final productsSnapshot = await _firestore
        .collection(_collection)
        .where('sellerId', isEqualTo: sellerId)
        .get();

    final products = productsSnapshot.docs
        .map((doc) => ProductModel.fromMap(doc.data()))
        .toList();

    final ordersSnapshot = await _firestore
        .collection(AppConstants.ordersCollection)
        .where('sellerId', isEqualTo: sellerId)
        .get();

    double totalSales = 0;
    for (final doc in ordersSnapshot.docs) {
      final data = doc.data();
      final status = (data['status'] ?? '').toString().toLowerCase();
      if (status == AppConstants.statusCancelled) continue;

      final total = data['totalAmount'] ?? data['total'] ?? data['amount'];
      if (total is num) {
        totalSales += total.toDouble();
      }
    }

    final ratedProducts = products.where((product) => product.rating > 0);
    final averageRating = ratedProducts.isEmpty
        ? 0.0
        : ratedProducts
                .map((product) => product.rating)
                .reduce((a, b) => a + b) /
            ratedProducts.length;

    return SellerDashboardStats(
      totalSales: totalSales,
      ordersCount: ordersSnapshot.docs.length,
      productsCount: products.length,
      pendingProductsCount: products
          .where((product) =>
              product.certStatus == CertificationStatus.pending)
          .length,
      averageRating: averageRating,
    );
  }

  /// Get all approved products (for users)
  Stream<List<ProductModel>> getApprovedProducts() {
    return _firestore
        .collection(_collection)
        .where('certStatus', isEqualTo: CertificationStatus.approved.name)
        .snapshots()
        .map((snapshot) {
      final products = snapshot.docs
          .map((doc) => ProductModel.fromMap(doc.data()))
          .toList();
      products.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return products;
    });
  }

  Future<ProductModel?> getProductById(String productId) async {
    final doc = await _firestore.collection(_collection).doc(productId).get();
    if (!doc.exists || doc.data() == null) return null;

    final product = ProductModel.fromMap(doc.data()!);
    if (product.certStatus != CertificationStatus.approved) {
      return null;
    }

    return product;
  }

  Future<ProductModel?> getProductByBarcode(String barcode) async {
    final cleanBarcode = barcode.trim();
    if (cleanBarcode.isEmpty) return null;

    final directDoc =
        await _firestore.collection(_collection).doc(cleanBarcode).get();
    if (directDoc.exists && directDoc.data() != null) {
      final product = ProductModel.fromMap(directDoc.data()!);
      if (product.certStatus == CertificationStatus.approved) return product;
    }

    final snapshot = await _firestore
        .collection(_collection)
        .where('barcode', isEqualTo: cleanBarcode)
        .where('certStatus', isEqualTo: CertificationStatus.approved.name)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return ProductModel.fromMap(snapshot.docs.first.data());
  }

  Stream<List<ProductReview>> watchProductReviews(String productId) {
    return _firestore
        .collection(_collection)
        .doc(productId)
        .collection('reviews')
        .snapshots()
        .map((snapshot) {
      final reviews =
          snapshot.docs.map((doc) => ProductReview.fromMap(doc.data())).toList();
      reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return reviews;
    });
  }

  Future<void> addProductReview({
    required String productId,
    required String userId,
    required String userName,
    required double rating,
    required String comment,
  }) async {
    final review = ProductReview(
      id: userId,
      userId: userId,
      userName: userName,
      rating: rating,
      comment: comment.trim(),
      createdAt: DateTime.now(),
    );

    final productRef = _firestore.collection(_collection).doc(productId);
    final reviewRef = productRef.collection('reviews').doc(userId);
    await reviewRef.set(review.toMap());

    final reviewsSnapshot = await productRef.collection('reviews').get();
    final reviews = reviewsSnapshot.docs
        .map((doc) => ProductReview.fromMap(doc.data()))
        .where((item) => item.rating > 0)
        .toList();

    final averageRating = reviews.isEmpty
        ? 0.0
        : reviews.map((item) => item.rating).reduce((a, b) => a + b) /
            reviews.length;

    await productRef.update({
      'rating': averageRating,
      'reviewCount': reviews.length,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }
}
