import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product_model.dart';

class CartItem {
  final ProductModel product;
  int quantity;

  CartItem({
    required this.product,
    this.quantity = 1,
  });
}

class CartProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final List<CartItem> _items = [];
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _cartSubscription;
  String? _boundUserId;

  List<CartItem> get items => _items;

  /// TOTAL ITEMS COUNT (for badge)
  int get itemCount =>
      _items.fold(0, (sum, item) => sum + item.quantity);

  /// TOTAL PRICE
  double get totalPrice =>
      _items.fold(0, (sum, item) =>
      sum + (item.product.finalPrice * item.quantity));

  CollectionReference<Map<String, dynamic>>? get _cartItemsRef {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;

    return _firestore.collection('carts').doc(uid).collection('items');
  }

  void bindUserCart(String? userId) {
    if (_boundUserId == userId) return;

    _cartSubscription?.cancel();
    _boundUserId = userId;
    _items.clear();

    if (userId == null || userId.isEmpty) {
      return;
    }

    _cartSubscription = _firestore
        .collection('carts')
        .doc(userId)
        .collection('items')
        .snapshots()
        .listen((snapshot) {
      _items
        ..clear()
        ..addAll(snapshot.docs.map((doc) {
          final data = doc.data();
          return CartItem(
            product: ProductModel.fromMap(data),
            quantity: (data['quantity'] as num?)?.toInt() ?? 1,
          );
        }));
      notifyListeners();
    });
  }

  /// ADD PRODUCT
  void addProduct(ProductModel product) {
    final index =
    _items.indexWhere((e) => e.product.id == product.id);

    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItem(product: product));
    }

    notifyListeners();
    _saveCartItem(product, index >= 0 ? _items[index].quantity : 1);
  }

  /// REMOVE PRODUCT COMPLETELY
  void removeProduct(String productId) {
    _items.removeWhere((e) => e.product.id == productId);
    notifyListeners();
    _cartItemsRef?.doc(productId).delete();
  }

  /// INCREASE QUANTITY
  void increaseQuantity(String productId) {
    final index =
    _items.indexWhere((e) => e.product.id == productId);

    if (index >= 0) {
      _items[index].quantity++;
      notifyListeners();
      _saveCartItem(_items[index].product, _items[index].quantity);
    }
  }

  /// DECREASE QUANTITY
  void decreaseQuantity(String productId) {
    final index =
    _items.indexWhere((e) => e.product.id == productId);

    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
        _saveCartItem(_items[index].product, _items[index].quantity);
      } else {
        final productIdToRemove = _items[index].product.id;
        _items.removeAt(index);
        _cartItemsRef?.doc(productIdToRemove).delete();
      }
      notifyListeners();
    }
  }

  /// CLEAR CART
  void clearCart() {
    final cartItemsRef = _cartItemsRef;
    if (cartItemsRef != null) {
      for (final item in List<CartItem>.from(_items)) {
        cartItemsRef.doc(item.product.id).delete();
      }
    }
    _items.clear();
    notifyListeners();
  }

  Future<void> clearCartFromDatabase() async {
    final cartItemsRef = _cartItemsRef;
    if (cartItemsRef == null) {
      clearCart();
      return;
    }

    final snapshot = await cartItemsRef.get();
    final batch = _firestore.batch();
    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
    _items.clear();
    notifyListeners();
  }

  Future<void> _saveCartItem(ProductModel product, int quantity) async {
    final cartItemsRef = _cartItemsRef;
    final uid = _auth.currentUser?.uid;
    if (cartItemsRef == null || uid == null) return;

    await _firestore.collection('carts').doc(uid).set({
      'userId': uid,
      'updatedAt': DateTime.now().toIso8601String(),
    }, SetOptions(merge: true));

    await cartItemsRef.doc(product.id).set({
      ...product.toMap(),
      'productId': product.id,
      'quantity': quantity,
      'unitPrice': product.finalPrice,
      'lineTotal': product.finalPrice * quantity,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  @override
  void dispose() {
    _cartSubscription?.cancel();
    super.dispose();
  }
}
