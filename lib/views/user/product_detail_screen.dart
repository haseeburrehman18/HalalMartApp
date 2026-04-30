// lib/views/user/product_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routes/app_routes.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/product_service.dart';
import '../../services/user_data_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/ean13_barcode.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  final ProductService _productService = ProductService();
  final UserDataService _userDataService = UserDataService();
  final TextEditingController _reviewCtrl = TextEditingController();
  late final Future<ProductModel?> _productFuture;
  double _selectedRating = 5;
  bool _isSubmittingReview = false;

  @override
  void initState() {
    super.initState();
    _productFuture = _productService.getProductById(widget.productId);
  }

  @override
  void dispose() {
    _reviewCtrl.dispose();
    super.dispose();
  }

  Widget _buildProductImage(ProductModel product) {
    if (product.imageUrl.startsWith('http')) {
      return Image.network(
        product.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildImageFallback(),
      );
    }

    return Image.asset(
      product.imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildImageFallback(),
    );
  }

  Widget _buildImageFallback() {
    return Container(
      color: AppColors.surface,
      child: const Icon(
        Icons.image_outlined,
        size: 64,
        color: AppColors.textLight,
      ),
    );
  }

  String _shareLink(ProductModel product) {
    final baseUri = Uri.base;
    final base = baseUri.hasScheme &&
            (baseUri.scheme == 'http' || baseUri.scheme == 'https') &&
            baseUri.host.isNotEmpty
        ? '${baseUri.scheme}://${baseUri.host}${baseUri.hasPort ? ':${baseUri.port}' : ''}'
        : 'https://halalmart.app';
    return '$base/product-detail/${product.id}';
  }

  Future<void> _shareProduct(ProductModel product) async {
    final link = _shareLink(product);
    await Clipboard.setData(
      ClipboardData(text: '${product.name}\n$link'),
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product link copied')),
    );
  }

  Future<void> _submitReview(ProductModel product) async {
    final user = context.read<AuthProvider>().user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login to review products')),
      );
      return;
    }

    if (_reviewCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Write a short review first')),
      );
      return;
    }

    setState(() => _isSubmittingReview = true);
    try {
      await _productService.addProductReview(
        productId: product.id,
        userId: user.uid,
        userName: user.name,
        rating: _selectedRating,
        comment: _reviewCtrl.text,
      );
      _reviewCtrl.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Review submitted'),
          backgroundColor: AppColors.primary,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmittingReview = false);
    }
  }

  Widget _buildPrice(ProductModel product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 10,
          runSpacing: 4,
          children: [
            Text(
              product.formattedPrice,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
            ),
            if (product.hasDiscount) ...[
              Text(
                product.formattedOriginalPrice,
                style: const TextStyle(
                  color: AppColors.textLight,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ],
          ],
        ),
        if (product.hasDiscount)
          Text(
            '${product.discountPercent}% discount',
            style: const TextStyle(
              color: AppColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }

  Widget _buildReviews(ProductModel product, AuthProvider auth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Reviews',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        if (auth.user != null)
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: List.generate(5, (index) {
                    final rating = index + 1.0;
                    return IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 34,
                        minHeight: 34,
                      ),
                      onPressed: () => setState(() => _selectedRating = rating),
                      icon: Icon(
                        rating <= _selectedRating
                            ? Icons.star
                            : Icons.star_border,
                        color: AppColors.accent,
                      ),
                    );
                  }),
                ),
                TextField(
                  controller: _reviewCtrl,
                  minLines: 2,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Share your product experience',
                  ),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed:
                        _isSubmittingReview ? null : () => _submitReview(product),
                    child: Text(_isSubmittingReview ? 'Saving...' : 'Submit'),
                  ),
                ),
              ],
            ),
          ),
        const SizedBox(height: 12),
        StreamBuilder<List<ProductReview>>(
          stream: _productService.watchProductReviews(product.id),
          builder: (context, snapshot) {
            final reviews = snapshot.data ?? [];
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (reviews.isEmpty) {
              return const Text(
                'No reviews yet.',
                style: TextStyle(color: AppColors.textSecondary),
              );
            }

            return Column(
              children: reviews.map((review) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    backgroundColor: AppColors.primaryLight,
                    child: Icon(Icons.person, color: AppColors.primary),
                  ),
                  title: Text(review.userName),
                  subtitle: Text(review.comment),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: AppColors.accent, size: 16),
                      Text(review.rating.toStringAsFixed(1)),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildRatingSummary(ProductModel product) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 6,
      runSpacing: 4,
      children: [
        ...List.generate(
          5,
          (i) => Icon(
            i < product.rating.round() ? Icons.star : Icons.star_border,
            color: AppColors.accent,
            size: 18,
          ),
        ),
        Text(
          '${product.rating.toStringAsFixed(1)} (${product.reviewCount} reviews)',
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    final auth = context.watch<AuthProvider>();
    final theme = Theme.of(context);

    return FutureBuilder<ProductModel?>(
      future: _productFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: AppBar(),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        final product = snapshot.data;
        if (snapshot.hasError || product == null) {
          return Scaffold(
            backgroundColor: theme.scaffoldBackgroundColor,
            appBar: AppBar(title: const Text('Product')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  snapshot.hasError
                      ? 'Could not load product: ${snapshot.error}'
                      : 'This product is not available.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: AppColors.primary,
                flexibleSpace: FlexibleSpaceBar(
                  background: _buildProductImage(product),
                ),
                actions: [
                  if (auth.user != null)
                    StreamBuilder<bool>(
                      stream: _userDataService.watchWishlistProduct(
                          auth.user!.uid, product.id),
                      builder: (context, wishlistSnapshot) {
                        final isWishlisted = wishlistSnapshot.data ?? false;
                        return IconButton(
                          icon: Icon(
                            isWishlisted
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: Colors.white,
                          ),
                          onPressed: () => _userDataService.toggleWishlist(
                              auth.user!.uid, product),
                        );
                      },
                    ),
                  IconButton(
                    icon: const Icon(Icons.share, color: Colors.white),
                    onPressed: () => _shareProduct(product),
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified,
                                size: 14, color: AppColors.primary),
                            SizedBox(width: 4),
                            Text(
                              'Halal Certified',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(product.category,
                          style:
                              const TextStyle(color: AppColors.textSecondary)),
                      const SizedBox(height: 12),
                      _buildPrice(product),
                      const SizedBox(height: 10),
                      _buildRatingSummary(product),
                      const SizedBox(height: 20),
                      const Text('Description',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                        product.description,
                        style: const TextStyle(
                            color: AppColors.textSecondary, height: 1.6),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.primaryLight,
                              radius: 22,
                              backgroundImage: product.sellerStoreImageUrl?.isNotEmpty == true
                                  ? NetworkImage(product.sellerStoreImageUrl!)
                                  : null,
                              child: product.sellerStoreImageUrl?.isNotEmpty == true
                                  ? null
                                  : const Icon(Icons.storefront,
                                      color: AppColors.primary),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.sellerName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600),
                                  ),
                                  const Text(
                                    'Verified Seller',
                                    style: TextStyle(
                                        color: AppColors.primary, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            TextButton(onPressed: () {}, child: const Text('View Shop')),
                          ],
                        ),
                      ),
                      if (product.barcode?.isNotEmpty == true) ...[
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Ean13Barcode(code: product.barcode!),
                        ),
                      ],
                      const SizedBox(height: 20),
                      _buildReviews(product, auth),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: CustomButton(
                    label: 'Add to Cart',
                    isOutlined: true,
                    onPressed: () {
                      cart.addProduct(product);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Added to cart'),
                          backgroundColor: AppColors.primary,
                        ),
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
              ],
            ),
          ),
        );
      },
    );
  }
}
