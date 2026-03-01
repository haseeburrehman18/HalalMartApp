// lib/views/admin/product_approval_screen.dart
// Screen 19 of 20

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/status_chip.dart';

class ProductApprovalScreen extends StatefulWidget {
  const ProductApprovalScreen({super.key});

  @override
  State<ProductApprovalScreen> createState() => _ProductApprovalScreenState();
}

class _ProductApprovalScreenState extends State<ProductApprovalScreen> {
  final List<Map<String, dynamic>> _products = [
    {'id': 'PROD-201', 'name': 'Premium Halal Beef', 'seller': 'Al-Barakah Store', 'category': 'Meat & Poultry', 'price': 24.99, 'cert': 'CERT-101', 'status': 'pending'},
    {'id': 'PROD-202', 'name': 'Camel Milk Powder', 'seller': 'Desert Delights', 'category': 'Dairy', 'price': 32.00, 'cert': 'CERT-105', 'status': 'pending'},
    {'id': 'PROD-203', 'name': 'Honey Date Biscuits', 'seller': 'Salam Foods', 'category': 'Snacks', 'price': 7.49, 'cert': 'CERT-102', 'status': 'approved'},
    {'id': 'PROD-204', 'name': 'Rose Water Syrup', 'seller': 'Blessed Market', 'category': 'Beverages', 'price': 5.99, 'cert': 'CERT-103', 'status': 'rejected'},
  ];

  void _setStatus(int i, String status) => setState(() => _products[i]['status'] = status);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Approval')),
      backgroundColor: AppColors.surface,
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _products.length,
        itemBuilder: (_, i) {
          final p = _products[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 14),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(width: 56, height: 56, decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.fastfood_outlined, color: AppColors.primary, size: 28)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(p['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(p['seller'] as String, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                    Text('${p['category']} • \$${(p['price'] as double).toStringAsFixed(2)}',
                        style: const TextStyle(color: AppColors.textLight, fontSize: 12)),
                  ])),
                  StatusChip(status: p['status'] as String),
                ]),
                const SizedBox(height: 10),
                Row(children: [
                  const Icon(Icons.verified_user_outlined, size: 14, color: AppColors.primary),
                  const SizedBox(width: 4),
                  Text('Linked Certificate: ${p['cert']}',
                      style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w500)),
                ]),
                if ((p['status'] as String) == 'pending') ...[
                  const SizedBox(height: 12),
                  Row(children: [
                    Expanded(child: CustomButton(label: 'Approve', onPressed: () => _setStatus(i, 'approved'))),
                    const SizedBox(width: 10),
                    Expanded(child: CustomButton(label: 'Reject', color: AppColors.error, onPressed: () => _setStatus(i, 'rejected'))),
                  ]),
                ],
              ]),
            ),
          );
        },
      ),
    );
  }
}
