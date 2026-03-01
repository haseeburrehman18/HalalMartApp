// lib/views/user/product_detail_screen.dart
// Screen 8 of 20

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routes/app_routes.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/custom_button.dart';

class ProductDetailScreen extends StatelessWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  ProductModel get _product {
    return ProductModel.mockProducts.firstWhere(
      (p) => p.id == productId,
      orElse: () => ProductModel.mockProducts.first,
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = _product;
    final cart = context.read<CartProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(product.imageUrl, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(color: AppColors.surface,
                      child: const Icon(Icons.image_outlined, size: 64, color: AppColors.textLight))),
            ),
            actions: [
              IconButton(icon: const Icon(Icons.favorite_border, color: Colors.white), onPressed: () {}),
              IconButton(icon: const Icon(Icons.share, color: Colors.white), onPressed: () {}),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Halal badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(20)),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.verified, size: 14, color: AppColors.primary),
                      SizedBox(width: 4),
                      Text('Halal Certified', style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                  const SizedBox(height: 12),
                  Text(product.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  const SizedBox(height: 4),
                  Text(product.category, style: const TextStyle(color: AppColors.textSecondary)),
                  const SizedBox(height: 12),
                  Row(children: [
                    Text('\$${product.price.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
                    const Spacer(),
                    Row(children: [
                      ...List.generate(5, (i) => Icon(
                        i < product.rating.round() ? Icons.star : Icons.star_border,
                        color: AppColors.accent, size: 18,
                      )),
                      const SizedBox(width: 6),
                      Text('${product.rating} (${product.reviewCount} reviews)',
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    ]),
                  ]),
                  const SizedBox(height: 20),
                  const Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(product.description, style: const TextStyle(color: AppColors.textSecondary, height: 1.6)),
                  const SizedBox(height: 20),
                  // Seller info
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                    child: Row(children: [
                      const CircleAvatar(backgroundColor: AppColors.primaryLight, radius: 22,
                          child: Icon(Icons.storefront, color: AppColors.primary)),
                      const SizedBox(width: 12),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(product.sellerName, style: const TextStyle(fontWeight: FontWeight.w600)),
                        const Text('Verified Seller ✓', style: TextStyle(color: AppColors.primary, fontSize: 12)),
                      ])),
                      TextButton(onPressed: () {}, child: const Text('View Shop')),
                    ]),
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 12, offset: const Offset(0, -4))]),
        child: Row(children: [
          Expanded(
            child: CustomButton(
              label: 'Add to Cart', isOutlined: true,
              onPressed: () {
                cart.addProduct(product);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Added to cart'), backgroundColor: AppColors.primary),
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: CustomButton(
              label: 'Buy Now',
              onPressed: () {
                cart.addProduct(product);
                Navigator.pushNamed(context, AppRoutes.checkout);
              },
            ),
          ),
        ]),
      ),
    );
  }
}
