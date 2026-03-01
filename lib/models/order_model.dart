// lib/models/order_model.dart
class CartItem {
  final String productId;
  final String name;
  final double price;
  final String imageUrl;
  int quantity;

  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
  });

  double get total => price * quantity;
}

class OrderModel {
  final String id;
  final String userId;
  final String userName;
  final List<CartItem> items;
  final double totalAmount;
  final String status;
  final String deliveryAddress;
  final DateTime createdAt;

  OrderModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.deliveryAddress,
    required this.createdAt,
  });

  // Mock seller orders
  static List<Map<String, dynamic>> mockSellerOrders = [
    {
      'id': 'ORD-001',
      'customerName': 'Ahmed Ali',
      'items': '2x Halal Chicken, 1x Goat Milk',
      'total': 31.47,
      'status': 'pending',
      'date': '2024-01-15',
    },
    {
      'id': 'ORD-002',
      'customerName': 'Fatima Hassan',
      'items': '3x Date Mix',
      'total': 26.97,
      'status': 'processing',
      'date': '2024-01-14',
    },
    {
      'id': 'ORD-003',
      'customerName': 'Omar Sheikh',
      'items': '1x Lamb Chops',
      'total': 18.99,
      'status': 'delivered',
      'date': '2024-01-13',
    },
  ];
}
