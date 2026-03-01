// lib/views/seller/seller_dashboard_screen.dart
// Screen 13 of 20

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/status_chip.dart';

class SellerDashboardScreen extends StatelessWidget {
  const SellerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Dashboard'),
        actions: [IconButton(icon: const Icon(Icons.notifications_outlined), onPressed: () {})],
      ),
      drawer: AppDrawer(
        role: 'seller',
        name: user?.name ?? 'Seller',
        email: user?.email ?? '',
        items: [
          DrawerItem(icon: Icons.dashboard_outlined, label: 'Dashboard', route: AppRoutes.sellerDashboard),
          DrawerItem(icon: Icons.add_box_outlined, label: 'Add Product', route: AppRoutes.addProduct),
          DrawerItem(icon: Icons.receipt_long_outlined, label: 'My Orders', route: AppRoutes.sellerOrders),
          DrawerItem(icon: Icons.verified_outlined, label: 'Upload Certificate', route: AppRoutes.uploadCertificate),
        ],
      ),
      backgroundColor: AppColors.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Welcome
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [AppColors.primaryDark, AppColors.primary]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Welcome back,', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
                const SizedBox(height: 4),
                Text(user?.name ?? 'Seller', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Al-Barakah Store', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ])),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                child: Column(children: const [
                  Text('4.8 ★', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('Rating', style: TextStyle(color: Colors.white70, fontSize: 10)),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 20),

          // Stats grid
          const Text('Overview', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.5,
            children: [
              _StatTile('Total Sales', '\$3,240', Icons.trending_up, AppColors.primaryLight, AppColors.primary),
              _StatTile('Orders', '47', Icons.shopping_bag_outlined, AppColors.accentLight, AppColors.accent),
              _StatTile('Products', '12', Icons.inventory_2_outlined, const Color(0xFFE0F2FE), const Color(0xFF0284C7)),
              _StatTile('Pending', '3', Icons.hourglass_empty_outlined, const Color(0xFFFCE7F3), const Color(0xFFBE185D)),
            ],
          ),
          const SizedBox(height: 20),

          // Quick actions
          const Text('Quick Actions', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          Row(children: [
            _ActionBtn(icon: Icons.add_circle_outline, label: 'Add Product', onTap: () => Navigator.pushNamed(context, AppRoutes.addProduct)),
            const SizedBox(width: 10),
            _ActionBtn(icon: Icons.receipt_outlined, label: 'View Orders', onTap: () => Navigator.pushNamed(context, AppRoutes.sellerOrders)),
            const SizedBox(width: 10),
            _ActionBtn(icon: Icons.upload_file_outlined, label: 'Certificate', onTap: () => Navigator.pushNamed(context, AppRoutes.uploadCertificate)),
          ]),
          const SizedBox(height: 20),

          // Recent orders
          const Text('Recent Orders', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          ...List.generate(3, (i) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
            child: Row(children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('ORD-00${i + 1}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 3),
                Text(['Ahmed Ali', 'Fatima H.', 'Omar S.'][i], style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
              ]),
              const Spacer(),
              Text(['\$31.47', '\$26.97', '\$18.99'][i], style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryDark)),
              const SizedBox(width: 10),
              StatusChip(status: ['pending', 'processing', 'delivered'][i]),
            ]),
          )),
        ]),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color bg, fg;
  const _StatTile(this.label, this.value, this.icon, this.bg, this.fg);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: fg, size: 26),
      const Spacer(),
      Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: fg)),
      Text(label, style: TextStyle(fontSize: 12, color: fg.withOpacity(0.7))),
    ]),
  );
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _ActionBtn({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)]),
        child: Column(children: [
          Icon(icon, color: AppColors.primary, size: 26),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textSecondary), textAlign: TextAlign.center),
        ]),
      ),
    ),
  );
}
