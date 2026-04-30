// lib/views/seller/seller_orders_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../services/order_service.dart';
import '../../widgets/status_chip.dart';

class SellerOrdersScreen extends StatefulWidget {
  const SellerOrdersScreen({super.key});

  @override
  State<SellerOrdersScreen> createState() => _SellerOrdersScreenState();
}

class _SellerOrdersScreenState extends State<SellerOrdersScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _statuses = ['All', 'Pending', 'Processing', 'Delivered', 'Cancelled'];
  final OrderService _orderService = OrderService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statuses.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sellerId = context.read<AuthProvider>().user?.uid ?? '';
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Orders'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: _statuses.map((s) => Tab(text: s)).toList(),
        ),
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: TabBarView(
        controller: _tabController,
        children: _statuses.map((status) {
          return StreamBuilder<QuerySnapshot>(
            stream: _orderService.getSellerOrders(sellerId),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final allOrders = snapshot.data?.docs ?? [];
              final filteredOrders = status == 'All' 
                  ? allOrders 
                  : allOrders.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return (data['status'] as String).toLowerCase() == status.toLowerCase();
                    }).toList();

              if (filteredOrders.isEmpty) {
                return const Center(child: Text('No orders', style: TextStyle(color: AppColors.textSecondary)));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredOrders.length,
                itemBuilder: (_, i) {
                  final doc = filteredOrders[i];
                  final order = doc.data() as Map<String, dynamic>;
                  final orderId = doc.id;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start, 
                        children: [
                          Row(children: [
                            Text(order['orderNumber'] ?? orderId, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            const Spacer(),
                            StatusChip(status: order['status'] as String),
                          ]),
                          const SizedBox(height: 8),
                          Row(children: [
                            const Icon(Icons.person_outline, size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Text(order['userName'] ?? 'Unknown Customer', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                          ]),
                          const SizedBox(height: 4),
                          Row(children: [
                            const Icon(Icons.receipt_outlined, size: 14, color: AppColors.textSecondary),
                            const SizedBox(width: 4),
                            Expanded(child: Text(order['itemsDescription'] ?? 'Product Details', style: const TextStyle(color: AppColors.textSecondary, fontSize: 12), overflow: TextOverflow.ellipsis)),
                          ]),
                          const SizedBox(height: 10),
                          Row(children: [
                            Text('\$${(order['totalAmount'] ?? 0).toStringAsFixed(2)}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primaryDark)),
                            const Spacer(),
                            Text(order['createdAt'] ?? '', style: const TextStyle(color: AppColors.textLight, fontSize: 11)),
                          ]),
                          if ((order['status'] as String).toLowerCase() == 'pending') ...[
                            const SizedBox(height: 10),
                            Row(children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _orderService.updateOrderStatus(orderId, 'processing'),
                                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 8), minimumSize: const Size(0, 36)),
                                  child: const Text('Accept', style: TextStyle(fontSize: 13, color: Colors.white)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => _orderService.updateOrderStatus(orderId, 'cancelled'),
                                  style: OutlinedButton.styleFrom(foregroundColor: AppColors.error, side: const BorderSide(color: AppColors.error), padding: const EdgeInsets.symmetric(vertical: 8), minimumSize: const Size(0, 36)),
                                  child: const Text('Decline', style: TextStyle(fontSize: 13)),
                                ),
                              ),
                            ]),
                          ] else if ((order['status'] as String).toLowerCase() == 'processing') ...[
                             const SizedBox(height: 10),
                             SizedBox(
                               width: double.infinity,
                               child: ElevatedButton(
                                 onPressed: () => _orderService.updateOrderStatus(orderId, 'delivered'),
                                 style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, padding: const EdgeInsets.symmetric(vertical: 8), minimumSize: const Size(0, 36)),
                                 child: const Text('Mark as Delivered', style: TextStyle(fontSize: 13, color: Colors.white)),
                               ),
                             ),
                          ],
                        ]
                      ),
                    ),
                  );
                },
              );
            },
          );
        }).toList(),
      ),
    );
  }
}
