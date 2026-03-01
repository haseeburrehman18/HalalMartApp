 // lib/views/user/user_profile_screen.dart
// Screen 12 of 20

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/auth_provider.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 60, 24, 32),
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.primaryDark, AppColors.primary]),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
              ),
              child: Column(children: [
                CircleAvatar(
                  radius: 44, backgroundColor: Colors.white,
                  child: Text(user?.name.isNotEmpty == true ? user!.name[0].toUpperCase() : '?',
                      style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.primary)),
                ),
                const SizedBox(height: 14),
                Text(user?.name ?? 'Guest', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(user?.email ?? '', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                  decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(20)),
                  child: Text(user?.role.toUpperCase() ?? '', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ),
              ]),
            ),
            const SizedBox(height: 16),

            // Stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [
                _StatCard('12', 'Orders'),
                const SizedBox(width: 12),
                _StatCard('3', 'Wishlist'),
                const SizedBox(width: 12),
                _StatCard('8', 'Reviews'),
              ]),
            ),
            const SizedBox(height: 16),

            // Menu
            _ProfileMenu(items: [
              _MenuItem(icon: Icons.shopping_bag_outlined, label: 'My Orders', onTap: () {}),
              _MenuItem(icon: Icons.location_on_outlined, label: 'Saved Addresses', onTap: () {}),
              _MenuItem(icon: Icons.payment_outlined, label: 'Payment Methods', onTap: () {}),
              _MenuItem(icon: Icons.favorite_border, label: 'Wishlist', onTap: () {}),
              _MenuItem(icon: Icons.notifications_outlined, label: 'Notifications', onTap: () {}),
              _MenuItem(icon: Icons.help_outline, label: 'Help & Support', onTap: () {}),
              _MenuItem(icon: Icons.settings_outlined, label: 'Settings', onTap: () {}),
            ]),
            const SizedBox(height: 16),

            // Logout
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListTile(
                tileColor: const Color(0xFFFEE2E2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                leading: const Icon(Icons.logout, color: AppColors.error),
                title: const Text('Logout', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w600)),
                onTap: () {
                  auth.logout();
                  Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
                },
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value, label;
  const _StatCard(this.value, this.label);

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)]),
      child: Column(children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: AppColors.primary)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
      ]),
    ),
  );
}

class _ProfileMenu extends StatelessWidget {
  final List<_MenuItem> items;
  const _ProfileMenu({required this.items});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6)]),
    child: Column(
      children: items.map((item) => Column(children: [
        ListTile(
          leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(8)),
              child: Icon(item.icon, size: 20, color: AppColors.primary)),
          title: Text(item.label, style: const TextStyle(fontWeight: FontWeight.w500)),
          trailing: const Icon(Icons.chevron_right, color: AppColors.textLight),
          onTap: item.onTap,
        ),
        if (item != items.last) const Divider(height: 1, indent: 64),
      ])).toList(),
    ),
  );
}

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuItem({required this.icon, required this.label, required this.onTap});
}
