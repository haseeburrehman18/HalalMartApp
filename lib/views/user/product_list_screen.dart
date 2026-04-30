// lib/views/user/product_list_screen.dart
// Premium Styled Product List Screen (UI Upgraded)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../services/product_service.dart';
import '../../widgets/product_card.dart';

class ProductListScreen extends StatefulWidget {
  final String category;
  const ProductListScreen({super.key, required this.category});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final ProductService _productService = ProductService();
  String _sortBy = 'Latest';
  final _sorts = [
    'Latest',
    'Price: Low to High',
    'Price: High to Low',
    'Rating'
  ];

  List<ProductModel> _sortProducts(List<ProductModel> products) {
    final list = widget.category == 'All'
        ? List<ProductModel>.from(products)
        : products.where((p) => p.category == widget.category).toList();
    switch (_sortBy) {
      case 'Price: Low to High':
        list.sort((a, b) => a.finalPrice.compareTo(b.finalPrice));
        break;
      case 'Price: High to Low':
        list.sort((a, b) => b.finalPrice.compareTo(a.finalPrice));
        break;
      case 'Rating':
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      default:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      /// PREMIUM GRADIENT APPBAR
      appBar: AppBar(
        elevation: 0,
        title: Text(
          widget.category == 'All'
              ? 'All Products'
              : widget.category,
          style: const TextStyle(
              fontWeight: FontWeight.w600),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF0BA360),
                Color(0xFF3CBA92),
              ],
            ),
          ),
        ),
      ),

      body: StreamBuilder<List<ProductModel>>(
        stream: _productService.getApprovedProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Could not load products: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            );
          }

          final products = _sortProducts(snapshot.data ?? []);

          return Column(
            children: [

          /// FILTER / SORT CARD
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius:
              BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.black
                      .withOpacity(0.05),
                  blurRadius: 15,
                )
              ],
            ),
            child: Row(
              children: [

                /// ITEM COUNT BADGE
                Container(
                  padding:
                  const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(
                        0xFFE8F5E9),
                    borderRadius:
                    BorderRadius.circular(
                        20),
                  ),
                  child: Text(
                    '${products.length} items',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight:
                      FontWeight.w500,
                      color: Color(
                          0xFF0BA360),
                    ),
                  ),
                ),

                const Spacer(),

                const Icon(Icons.sort,
                    size: 18,
                    color: Colors.grey),

                const SizedBox(width: 6),

                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _sortBy,
                    borderRadius:
                    BorderRadius.circular(
                        12),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight:
                      FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                    items: _sorts
                        .map((s) =>
                        DropdownMenuItem(
                          value: s,
                          child: Text(s),
                        ))
                        .toList(),
                    onChanged: (v) =>
                        setState(() =>
                        _sortBy = v!),
                  ),
                ),
              ],
            ),
          ),

          /// PRODUCTS OR EMPTY
          Expanded(
            child: products.isEmpty

            /// EMPTY STATE
                ? Center(
              child: Column(
                mainAxisSize:
                MainAxisSize.min,
                children: [
                  Container(
                    padding:
                    const EdgeInsets
                        .all(20),
                    decoration:
                    const BoxDecoration(
                      shape:
                      BoxShape.circle,
                      color: Color(
                          0xFFE8F5E9),
                    ),
                    child: const Icon(
                      Icons.search_off_rounded,
                      size: 50,
                      color: Color(
                          0xFF0BA360),
                    ),
                  ),
                  const SizedBox(
                      height: 16),
                  const Text(
                    'No products found',
                    style:
                    TextStyle(
                      fontSize: 16,
                      fontWeight:
                      FontWeight
                          .w500,
                    ),
                  ),
                  const SizedBox(
                      height: 6),
                  const Text(
                    'Try adjusting filters or category',
                    style:
                    TextStyle(
                      fontSize: 13,
                      color: Colors
                          .grey,
                    ),
                  ),
                ],
              ),
            )

            /// GRID VIEW
                : GridView.builder(
              padding:
              const EdgeInsets
                  .symmetric(
                  horizontal:
                  16),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio:
                0.56,
              ),
              itemCount:
              products.length,
              itemBuilder:
                  (_, i) {
                return Container(
                  decoration:
                  BoxDecoration(
                    borderRadius:
                    BorderRadius
                        .circular(
                        18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors
                            .black
                            .withOpacity(
                            0.05),
                        blurRadius:
                        15,
                      )
                    ],
                  ),
                  child:
                  ProductCard(
                    product:
                    products[i],
                    onAddToCart:
                        () {
                      cart.addProduct(
                          products[
                          i]);

                      ScaffoldMessenger.of(
                          context)
                          .showSnackBar(
                        SnackBar(
                          content: Text(
                              '${products[i].name} added'),
                          backgroundColor:
                          const Color(
                              0xFF0BA360),
                          duration:
                          const Duration(
                              seconds:
                              1),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
            ],
          );
        },
      ),
    );
  }
}
