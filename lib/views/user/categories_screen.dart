// lib/views/user/categories_screen.dart

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routes/app_routes.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  static const _categoryData = [
    {
      'name': 'Meat & Poultry',
      'count': 48,
      'image': 'assets/categories/meat.jpg'
    },
    {
      'name': 'Dairy',
      'count': 32,
      'image': 'assets/categories/dairy.jpg'
    },
    {
      'name': 'Snacks',
      'count': 67,
      'image': 'assets/categories/snacks.jpg'
    },
    {
      'name': 'Beverages',
      'count': 41,
      'image': 'assets/categories/beverages.jpg'
    },
    {
      'name': 'Frozen Foods',
      'count': 29,
      'image': 'assets/categories/frozen.jpg'
    },
    {
      'name': 'Bakery',
      'count': 55,
      'image': 'assets/categories/bakery.jpg'
    },
    {
      'name': 'Grains & Cereals',
      'count': 38,
      'image': 'assets/categories/grains.jpg'
    },
    {
      'name': 'Condiments',
      'count': 23,
      'image': 'assets/categories/condiments.jpg'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Categories'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          itemCount: _categoryData.length,
          gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 0.95,
          ),
          itemBuilder: (_, i) {
            final cat = _categoryData[i];

            return GestureDetector(
              onTap: () => Navigator.pushNamed(
                context,
                AppRoutes.productList,
                arguments: cat['name'] as String,
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    )
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Stack(
                    children: [

                      /// BACKGROUND IMAGE
                      Positioned.fill(
                        child: Image.asset(
                          cat['image'] as String,
                          fit: BoxFit.cover,
                        ),
                      ),

                      /// DARK GRADIENT OVERLAY
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.2),
                                Colors.black.withOpacity(0.75),
                              ],
                            ),
                          ),
                        ),
                      ),

                      /// HALAL BADGE
                      Positioned(
                        top: 12,
                        left: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius:
                            BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'HALAL',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                      ),

                      /// CATEGORY TEXT
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              cat['name'] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${cat['count']} products',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}