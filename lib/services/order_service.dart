// lib/services/order_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/constants/app_constants.dart';
import '../models/user_model.dart';
import '../providers/cart_provider.dart';

class OrderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _collection = 'orders';

  /// Get orders for a specific seller
  /// Note: This assumes orders have a way to identify which items belong to which seller
  /// For simplicity in this mock, we'll just filter by a sellerId if present in the order
  Stream<QuerySnapshot> getSellerOrders(String sellerId) {
    return _firestore
        .collection(_collection)
        // In a real app, you'd likely have a sub-collection or a list of sellerIds in the order
        // .where('sellerIds', arrayContains: sellerId) 
        .where('sellerId', isEqualTo: sellerId) 
        .snapshots();
  }

  Stream<int> watchSellerPendingOrderCount(String sellerId) {
    return _firestore
        .collection(_collection)
        .where('sellerId', isEqualTo: sellerId)
        .where('status', isEqualTo: AppConstants.statusPending)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Update order status
  Future<void> updateOrderStatus(String orderId, String status) async {
    await _firestore.collection(_collection).doc(orderId).update({'status': status});
  }

  /// Create one Firestore order per seller so sellers can see their own orders.
  Future<List<String>> placeOrder({
    required UserModel user,
    required List<CartItem> items,
    required String customerName,
    required String phone,
    required String deliveryAddress,
    required String paymentMethod,
  }) async {
    if (items.isEmpty) {
      throw Exception('Your cart is empty.');
    }

    final groupedBySeller = <String, List<CartItem>>{};
    for (final item in items) {
      groupedBySeller
          .putIfAbsent(item.product.sellerId, () => <CartItem>[])
          .add(item);
    }

    final orderIds = <String>[];
    final batch = _firestore.batch();
    final now = DateTime.now();

    for (final entry in groupedBySeller.entries) {
      final sellerId = entry.key;
      final sellerItems = entry.value;
      final orderRef = _firestore.collection(_collection).doc();
      final totalAmount = sellerItems.fold<double>(
        0,
        (sum, item) => sum + item.product.finalPrice * item.quantity,
      );

      batch.set(orderRef, {
        'id': orderRef.id,
        'userId': user.uid,
        'userName': customerName,
        'userEmail': user.email,
        'phone': phone,
        'sellerId': sellerId,
        'sellerName': sellerItems.first.product.sellerName,
        'sellerIds': [sellerId],
        'items': sellerItems
            .map((item) => {
                  'productId': item.product.id,
                  'name': item.product.name,
                  'price': item.product.finalPrice,
                  'quantity': item.quantity,
                  'imageUrl': item.product.imageUrl,
                  'sellerId': item.product.sellerId,
                  'sellerName': item.product.sellerName,
                  'lineTotal': item.product.finalPrice * item.quantity,
                })
            .toList(),
        'totalAmount': totalAmount,
        'status': AppConstants.statusPending,
        'paymentMethod': paymentMethod,
        'paymentStatus': paymentMethod == 'Cash on Delivery'
            ? 'pending'
            : 'paid',
        'deliveryAddress': deliveryAddress,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      });

      orderIds.add(orderRef.id);
    }

    await batch.commit();
    return orderIds;
  }
}
