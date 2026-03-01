// lib/views/user/categories_screen.dart
// Screen 6 of 20

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routes/app_routes.dart';
import '../../core/constants/app_constants.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  static const _categoryData = [
    {'name': 'Meat & Poultry', 'icon': Icons.kebab_dining, 'count': 48},
    {'name': 'Dairy', 'icon': Icons.local_drink, 'count': 32},
    {'name': 'Snacks', 'icon': Icons.cookie, 'count': 67},
    {'name': 'Beverages', 'icon': Icons.sports_bar, 'count': 41},
    {'name': 'Frozen Foods', 'icon': Icons.ac_unit, 'count': 29},
    {'name': 'Bakery', 'icon': Icons.bakery_dining, 'count': 55},
    {'name': 'Grains & Cereals', 'icon': Icons.grain, 'count': 38},
    {'name': 'Condiments', 'icon': Icons.lunch_dining, 'count': 23},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categories')),
      backgroundColor: AppColors.background,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Browse by Category',
                style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, mainAxisSpacing: 14, crossAxisSpacing: 14, childAspectRatio: 1.15,
              ),
              itemCount: _categoryData.length,
              itemBuilder: (_, i) {
                final cat = _categoryData[i];
                final colors = [
                  [AppColors.primaryLight, AppColors.primary],
                  [AppColors.accentLight, AppColors.accent],
                  [const Color(0xFFE0F2FE), const Color(0xFF0284C7)],
                  [const Color(0xFFFCE7F3), const Color(0xFFBE185D)],
                  [const Color(0xFFF0FDF4), const Color(0xFF15803D)],
                  [const Color(0xFFFFF7ED), const Color(0xFFEA580C)],
                  [const Color(0xFFF5F3FF), const Color(0xFF7C3AED)],
                  [const Color(0xFFF0FDFA), const Color(0xFF0F766E)],
                ];
                return GestureDetector(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.productList, arguments: cat['name'] as String),
                  child: Container(
                    decoration: BoxDecoration(
                      color: (colors[i][0] as Color),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(cat['icon'] as IconData, color: colors[i][1] as Color, size: 36),
                        const Spacer(),
                        Text(cat['name'] as String,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: colors[i][1] as Color)),
                        const SizedBox(height: 2),
                        Text('${cat['count']} products',
                            style: TextStyle(fontSize: 12, color: (colors[i][1] as Color).withOpacity(0.7))),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
