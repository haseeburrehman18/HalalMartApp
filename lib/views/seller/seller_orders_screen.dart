// lib/views/seller/seller_orders_screen.dart
// Screen 15 of 20

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../models/order_model.dart';
import '../../widgets/status_chip.dart';

class SellerOrdersScreen extends StatefulWidget {
  const SellerOrdersScreen({super.key});

  @override
  State<SellerOrdersScreen> createState() => _SellerOrdersScreenState();
}

class _SellerOrdersScreenState extends State<SellerOrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _statuses = ['All', 'Pending', 'Processing', 'Delivered'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statuses.length, vsync: this);
  }

  @override
  void dispose() { _tabController.dispose(); super.dispose(); }

  List<Map<String, dynamic>> _filtered(String status) {
    if (status == 'All') return OrderModel.mockSellerOrders;
    return OrderModel.mockSellerOrders.where((o) => (o['status'] as String).toLowerCase() == status.toLowerCase()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: _statuses.map((s) => Tab(text: s)).toList(),
        ),
      ),
      backgroundColor: AppColors.surface,
      body: TabBarView(
        controller: _tabController,
        children: _statuses.map((status) {
          final orders = _filtered(status);
          return orders.isEmpty
              ? const Center(child: Text('No orders', style: TextStyle(color: AppColors.textSecondary)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  itemBuilder: (_, i) {
                    final order = orders[i];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            Text(order['id'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            const Spacer(),
                            StatusChip(status: order['status'] as String),
                          ]),
                          const SizedBox(height: 8),
                          Row(children: [
                            const Icon(Icons.person_outline, size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(order['customerName'] as String, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                          ]),
                          const SizedBox(height: 4),
                          Row(children: [
                            const Icon(Icons.receipt_outlined, size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(order['items'] as String, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                          ]),
                          const SizedBox(height: 10),
                          Row(children: [
                            Text('\$${(order['total'] as double).toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primaryDark)),
                            const Spacer(),
                            Text(order['date'] as String, style: const TextStyle(color: AppColors.textLight, fontSize: 11)),
                          ]),
                          if ((order['status'] as String) == 'pending') ...[
                            const SizedBox(height: 10),
                            Row(children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {},
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 8), minimumSize: const Size(0, 36)),
                                  child: const Text('Accept', style: TextStyle(fontSize: 13)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {},
                                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error), padding: const EdgeInsets.symmetric(vertical: 8), minimumSize: const Size(0, 36)),
                                  child: const Text('Decline', style: TextStyle(fontSize: 13)),
                                ),
                              ),
                            ]),
                          ],
                        ]),
                      ),
                    );
                  },
                );
        }).toList(),
      ),
    );
  }
}
