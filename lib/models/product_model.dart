// lib/models/product_model.dart

import 'package:flutter/material.dart';

enum CertificationStatus { pending, approved, rejected }

class ProductModel {
  final String id;
  final String sellerId;
  final String sellerName;

  final String name;
  final String slug;
  final String description;

  final double price;
  final double? discountPrice;

  final String category;
  final String imageUrl;

  final CertificationStatus certStatus;

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
    required this.name,
    required this.slug,
    required this.description,
    required this.price,
    this.discountPrice,
    required this.category,
    required this.imageUrl,
    required this.certStatus,
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

  bool get hasDiscount => discountPrice != null;

  String get formattedPrice => "\$${finalPrice.toStringAsFixed(2)}";

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
  /// CopyWith (Professional Pattern)
  /// -------------------------------

  ProductModel copyWith({
    String? name,
    double? price,
    double? discountPrice,
    bool? isAvailable,
    double? rating,
    int? reviewCount,
    CertificationStatus? certStatus,
  }) {
    return ProductModel(
      id: id,
      sellerId: sellerId,
      sellerName: sellerName,
      name: name ?? this.name,
      slug: slug,
      description: description,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      category: category,
      imageUrl: imageUrl,
      certStatus: certStatus ?? this.certStatus,
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
      name: map['name'] ?? '',
      slug: map['slug'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      discountPrice: map['discountPrice'] != null
          ? (map['discountPrice']).toDouble()
          : null,
      category: map['category'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      certStatus: CertificationStatus.values.firstWhere(
            (e) => e.name == map['certStatus'],
        orElse: () => CertificationStatus.pending,
      ),
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
      'name': name,
      'slug': slug,
      'description': description,
      'price': price,
      'discountPrice': discountPrice,
      'category': category,
      'imageUrl': imageUrl,
      'certStatus': certStatus.name,
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

  static List<ProductModel> mockProducts = List.generate(10, (i) {
    final names = [
      'Halal Chicken Breast',
      'Organic Goat Milk',
      'Premium Date Mix',
      'Rose Water Drink',
      'Whole Grain Bread',
      'Fresh Lamb Chops',
      'Greek Style Yoghurt',
      'Honey Crackers',
      'Pomegranate Juice',
      'Authentic Pita Bread',
    ];

    return ProductModel(
      id: 'prod_$i',
      sellerId: 'seller_1',
      sellerName: 'Al-Barakah Store',
      name: names[i],
      slug: names[i].toLowerCase().replaceAll(' ', '-'),
      description:
      'Premium halal-certified product verified by trusted Islamic authorities. Quality guaranteed.',
      price: 5 + i * 2.5,
      discountPrice: i % 2 == 0 ? (5 + i * 2.5) - 1.5 : null,
      category: 'Food & Grocery',
      imageUrl: 'https://picsum.photos/seed/halal$i/400/400',
      certStatus: CertificationStatus.approved,
      rating: 3.5 + (i % 3) * 0.5,
      reviewCount: 15 + i * 8,
      searchKeywords: ['halal', 'food', 'certified'],
      createdAt: DateTime.now().subtract(Duration(days: i * 2)),
    );
  });
}