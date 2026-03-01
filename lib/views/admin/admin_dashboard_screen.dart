// lib/views/admin/admin_dashboard_screen.dart
// Screen 17 of 20

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/status_chip.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      drawer: AppDrawer(
        role: 'admin',
        name: user?.name ?? 'Admin',
        email: user?.email ?? '',
        items: [
          DrawerItem(icon: Icons.dashboard_outlined, label: 'Dashboard', route: AppRoutes.adminDashboard),
          DrawerItem(icon: Icons.verified_outlined, label: 'Certificate Review', route: AppRoutes.certificateReview),
          DrawerItem(icon: Icons.inventory_2_outlined, label: 'Product Approval', route: AppRoutes.productApproval),
          DrawerItem(icon: Icons.people_outlined, label: 'User Management', route: AppRoutes.userManagement),
        ],
      ),
      backgroundColor: AppColors.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF1E3A5F), Color(0xFF2563EB)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Admin Panel', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13)),
                const SizedBox(height: 4),
                Text(user?.name ?? 'Admin', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('HalalVerify Administrator', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ])),
              const Icon(Icons.admin_panel_settings, color: Colors.white54, size: 48),
            ]),
          ),
          const SizedBox(height: 20),

          // Stats
          const Text('Platform Overview', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.5,
            children: [
              _AdminStat('Total Users', '1,248', Icons.people_outline, AppColors.primaryLight, AppColors.primary),
              _AdminStat('Sellers', '87', Icons.storefront_outlined, AppColors.accentLight, AppColors.accent),
              _AdminStat('Products', '342', Icons.inventory_2_outlined, const Color(0xFFE0F2FE), const Color(0xFF0284C7)),
              _AdminStat('Pending Certs', '14', Icons.pending_outlined, const Color(0xFFFCE7F3), const Color(0xFFBE185D)),
            ],
          ),
          const SizedBox(height: 20),

          // Quick actions
          const Text('Actions Required', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          _ActionCard(
            icon: Icons.verified_outlined, color: AppColors.primary,
            title: 'Certificate Reviews', subtitle: '14 pending reviews',
            onTap: () => Navigator.pushNamed(context, AppRoutes.certificateReview),
          ),
          const SizedBox(height: 8),
          _ActionCard(
            icon: Icons.inventory_2_outlined, color: AppColors.accent,
            title: 'Product Approvals', subtitle: '7 awaiting approval',
            onTap: () => Navigator.pushNamed(context, AppRoutes.productApproval),
          ),
          const SizedBox(height: 8),
          _ActionCard(
            icon: Icons.people_outlined, color: const Color(0xFF7C3AED),
            title: 'User Management', subtitle: '1,248 total users',
            onTap: () => Navigator.pushNamed(context, AppRoutes.userManagement),
          ),
          const SizedBox(height: 20),

          const Text('Recent Activity', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          ...['Certificate approved for Al-Barakah Store', 'New seller registered: Salam Foods', 'Product rejected: Missing cert details'].asMap().map((i, text) => MapEntry(i, Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
            child: Row(children: [
              Icon([Icons.check_circle, Icons.person_add, Icons.cancel][i], color: [AppColors.primary, AppColors.accent, AppColors.error][i], size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
              Text('${i + 1}h ago', style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
            ]),
          ))).values.toList(),
        ]),
      ),
    );
  }
}

class _AdminStat extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color bg, fg;
  const _AdminStat(this.label, this.value, this.icon, this.bg, this.fg);

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

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title, subtitle;
  final VoidCallback onTap;
  const _ActionCard({required this.icon, required this.color, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 22)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
        ])),
        const Icon(Icons.chevron_right, color: AppColors.textLight),
      ]),
    ),
  );
}
