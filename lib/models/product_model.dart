// lib/models/product_model.dart

import 'package:flutter/material.dart';

enum CertificationStatus { pending, approved, rejected }

class ProductModel {
  final String id;
  final String sellerId;
  final String sellerName;
  final String? sellerStoreImageUrl;

  final String name;
  final String slug;
  final String description;

  final double price;
  final double? discountPrice;

  final String category;
  final String imageUrl;
  final String? barcode;

  final CertificationStatus certStatus;
  final String? rejectionReason; // Reason why product was rejected (admin notes)

  final double rating;
  final int reviewCount;

  final bool isAvailable;
  final List<String> searchKeywords;

  final DateTime createdAt;
  final DateTime? updatedAt;

  const ProductModel({
    required this.id,
    required this.sellerId,
    required this.sellerName,
    this.sellerStoreImageUrl,
    required this.name,
    required this.slug,
    required this.description,
    required this.price,
    this.discountPrice,
    required this.category,
    required this.imageUrl,
    this.barcode,
    required this.certStatus,
    this.rejectionReason,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.isAvailable = true,
    this.searchKeywords = const [],
    required this.createdAt,
    this.updatedAt,
  });

  /// -------------------------------
  /// Computed Properties
  /// -------------------------------

  double get finalPrice => discountPrice ?? price;

  bool get hasDiscount => discountPrice != null && discountPrice! < price;

  String get formattedPrice => "\$${finalPrice.toStringAsFixed(2)}";

  String get formattedOriginalPrice => "\$${price.toStringAsFixed(2)}";

  int get discountPercent {
    if (!hasDiscount || price <= 0) return 0;
    return (((price - discountPrice!) / price) * 100).round();
  }

  Color get statusColor {
    switch (certStatus) {
      case CertificationStatus.approved:
        return Colors.green;
      case CertificationStatus.pending:
        return Colors.orange;
      case CertificationStatus.rejected:
        return Colors.red;
    }
  }

  String get statusLabel {
    switch (certStatus) {
      case CertificationStatus.approved:
        return "Halal Certified";
      case CertificationStatus.pending:
        return "Certification Pending";
      case CertificationStatus.rejected:
        return "Not Certified";
    }
  }

  /// -------------------------------
  /// CopyWith
  /// -------------------------------

  ProductModel copyWith({
    String? name,
    double? price,
    double? discountPrice,
    String? imageUrl,
    String? barcode,
    String? sellerStoreImageUrl,
    bool? isAvailable,
    double? rating,
    int? reviewCount,
    CertificationStatus? certStatus,
    String? rejectionReason,
  }) {
    return ProductModel(
      id: id,
      sellerId: sellerId,
      sellerName: sellerName,
      sellerStoreImageUrl: sellerStoreImageUrl ?? this.sellerStoreImageUrl,
      name: name ?? this.name,
      slug: slug,
      description: description,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      category: category,
      imageUrl: imageUrl ?? this.imageUrl,
      barcode: barcode ?? this.barcode,
      certStatus: certStatus ?? this.certStatus,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isAvailable: isAvailable ?? this.isAvailable,
      searchKeywords: searchKeywords,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }

  /// -------------------------------
  /// JSON / Firestore Support
  /// -------------------------------

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] ?? '',
      sellerId: map['sellerId'] ?? '',
      sellerName: map['sellerName'] ?? '',
      sellerStoreImageUrl: map['sellerStoreImageUrl'],
      name: map['name'] ?? '',
      slug: map['slug'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      discountPrice: map['discountPrice'] != null
          ? (map['discountPrice']).toDouble()
          : null,
      category: map['category'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      barcode: map['barcode'],
      certStatus: CertificationStatus.values.firstWhere(
            (e) => e.name == map['certStatus'],
        orElse: () => CertificationStatus.pending,
      ),
      rejectionReason: map['rejectionReason'],
      rating: (map['rating'] ?? 0).toDouble(),
      reviewCount: map['reviewCount'] ?? 0,
      isAvailable: map['isAvailable'] ?? true,
      searchKeywords:
      (map['searchKeywords'] as List<dynamic>?)?.cast<String>() ?? [],
      createdAt:
      DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'sellerStoreImageUrl': sellerStoreImageUrl,
      'name': name,
      'slug': slug,
      'description': description,
      'price': price,
      'discountPrice': discountPrice,
      'category': category,
      'imageUrl': imageUrl,
      'barcode': barcode,
      'certStatus': certStatus.name,
      'rejectionReason': rejectionReason,
      'rating': rating,
      'reviewCount': reviewCount,
      'isAvailable': isAvailable,
      'searchKeywords': searchKeywords,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// -------------------------------
  /// Premium Mock Data
  /// -------------------------------

  static List<ProductModel> mockProducts = [
    ProductModel(
      id: 'prod_0',
      sellerId: 'seller_1',
      sellerName: 'Al-Barakah Store',
      name: 'Halal Chicken Breast',
      slug: 'halal-chicken-breast',
      description: 'Premium halal-certified chicken breast.',
      price: 5.00,
      discountPrice: 3.50,
      category: 'Meat & Poultry',
      imageUrl: 'assets/products/chicken_breast.jpg',
      certStatus: CertificationStatus.approved,
      rating: 3.5,
      reviewCount: 15,
      createdAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod_1',
      sellerId: 'seller_1',
      sellerName: 'Al-Barakah Store',
      name: 'Organic Goat Milk',
      slug: 'organic-goat-milk',
      description: 'Fresh organic goat milk.',
      price: 7.50,
      category: 'Dairy',
      imageUrl: 'assets/products/goat_milk.jpg',
      certStatus: CertificationStatus.approved,
      rating: 4.0,
      reviewCount: 22,
      createdAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod_2',
      sellerId: 'seller_1',
      sellerName: 'Al-Barakah Store',
      name: 'Premium Date Mix',
      slug: 'premium-date-mix',
      description: 'Assorted premium dates.',
      price: 10.00,
      discountPrice: 8.50,
      category: 'Grains & Cereals',
      imageUrl: 'assets/products/dates_mix.jpg',
      certStatus: CertificationStatus.approved,
      rating: 4.2,
      reviewCount: 30,
      createdAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod_3',
      sellerId: 'seller_1',
      sellerName: 'Al-Barakah Store',
      name: 'Rose Water Drink',
      slug: 'rose-water-drink',
      description: 'Refreshing rose water beverage.',
      price: 12.50,
      category: 'Condiments',
      imageUrl: 'assets/products/rose_water.jpg',
      certStatus: CertificationStatus.approved,
      rating: 3.3,
      reviewCount: 12,
      createdAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod_4',
      sellerId: 'seller_1',
      sellerName: 'Al-Barakah Store',
      name: 'Whole Grain Bread',
      slug: 'whole-grain-bread',
      description: 'Healthy whole grain bread.',
      price: 15.00,
      category: 'Bakery',
      imageUrl: 'assets/products/whole_grain_bread.jpg',
      certStatus: CertificationStatus.approved,
      rating: 4.3,
      reviewCount: 40,
      createdAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod_5',
      sellerId: 'seller_1',
      sellerName: 'Al-Barakah Store',
      name: 'Fresh Lamb Chops',
      slug: 'fresh-lamb-chops',
      description: 'Premium halal lamb chops.',
      price: 17.50,
      category: 'Frozen Foods',
      imageUrl: 'assets/products/lamb_chop.jpg',
      certStatus: CertificationStatus.approved,
      rating: 4.5,
      reviewCount: 52,
      createdAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod_6',
      sellerId: 'seller_1',
      sellerName: 'Al-Barakah Store',
      name: 'Greek Style Yoghurt',
      slug: 'greek-style-yoghurt',
      description: 'Creamy Greek yoghurt.',
      price: 20.00,
      category: 'Dairy',
      imageUrl: 'assets/products/greek_yogurt.jpg',
      certStatus: CertificationStatus.approved,
      rating: 3.5,
      reviewCount: 18,
      createdAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod_7',
      sellerId: 'seller_1',
      sellerName: 'Al-Barakah Store',
      name: 'Honey Crackers',
      slug: 'honey-crackers',
      description: 'Crunchy honey crackers.',
      price: 22.50,
      category: 'Snacks',
      imageUrl: 'assets/products/honey_crackers.jpg',
      certStatus: CertificationStatus.approved,
      rating: 4.0,
      reviewCount: 21,
      createdAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod_8',
      sellerId: 'seller_1',
      sellerName: 'Al-Barakah Store',
      name: 'Pomegranate Juice',
      slug: 'pomegranate-juice',
      description: 'Fresh pomegranate juice.',
      price: 12.50,
      category: 'Beverages',
      imageUrl: 'assets/products/pomegranate_juice.jpg',
      certStatus: CertificationStatus.approved,
      rating: 3.3,
      reviewCount: 10,
      createdAt: DateTime.now(),
    ),
    ProductModel(
      id: 'prod_9',
      sellerId: 'seller_1',
      sellerName: 'Al-Barakah Store',
      name: 'Authentic Pita Bread',
      slug: 'authentic-pita-bread',
      description: 'Soft authentic pita bread.',
      price: 18.00,
      category: 'Bakery',
      imageUrl: 'assets/products/pita_bread.jpg',
      certStatus: CertificationStatus.approved,
      rating: 4.2,
      reviewCount: 25,
      createdAt: DateTime.now(),
    ),
  ];
}
