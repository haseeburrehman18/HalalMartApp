import 'package:flutter/material.dart';
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
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  /// TOTAL ITEMS COUNT (for badge)
  int get itemCount =>
      _items.fold(0, (sum, item) => sum + item.quantity);

  /// TOTAL PRICE
  double get totalPrice =>
      _items.fold(0, (sum, item) =>
      sum + (item.product.price * item.quantity));

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
  }

  /// REMOVE PRODUCT COMPLETELY
  void removeProduct(String productId) {
    _items.removeWhere((e) => e.product.id == productId);
    notifyListeners();
  }

  /// INCREASE QUANTITY
  void increaseQuantity(String productId) {
    final index =
    _items.indexWhere((e) => e.product.id == productId);

    if (index >= 0) {
      _items[index].quantity++;
      notifyListeners();
    }
  }

  /// DECREASE QUANTITY
  void decreaseQuantity(String productId) {
    final index =
    _items.indexWhere((e) => e.product.id == productId);

    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  /// CLEAR CART
  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}