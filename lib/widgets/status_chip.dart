// lib/widgets/status_chip.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/theme/app_theme.dart';

class StatusChip extends StatelessWidget {
  final String status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    switch (status.toLowerCase()) {
      case 'approved':
      case 'delivered':
        bg = AppColors.primaryLight; fg = AppColors.primaryDark;
        break;
      case 'rejected':
      case 'cancelled':
        bg = const Color(0xFFFEE2E2); fg = AppColors.error;
        break;
      case 'processing':
      case 'shipped':
        bg = const Color(0xFFDCFCE7); fg = const Color(0xFF15803D);
        break;
      default: // pending
        bg = AppColors.accentLight; fg = const Color(0xFFB45309);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(status.toUpperCase(),
          style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
    );
  }
}

/// Seller drawer scaffold shared between seller and admin views
class AppDrawer extends StatelessWidget {
  final String role;
  final String name;
  final String email;
  final List<DrawerItem> items;

  const AppDrawer({
    super.key,
    required this.role,
    required this.name,
    required this.email,
    required this.items,
  });

  Future<void> _showLogoutConfirmation(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Logout Confirmation'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('No', style: TextStyle(color: Colors.blue)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await FirebaseAuth.instance.signOut();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
                }
              },
              child: const Text('Yes', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primary),
            accountName: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: Text(email),
            currentAccountPicture: CircleAvatar(
              backgroundColor: AppColors.primaryLight,
              child: Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
                  style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold, fontSize: 22)),
            ),
          ),
          ...items.map((item) => ListTile(
                leading: Icon(item.icon, color: AppColors.primary),
                title: Text(item.label),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, item.route);
                },
              )),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text('Logout', style: TextStyle(color: AppColors.error)),
            onTap: () => _showLogoutConfirmation(context),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class DrawerItem {
  final IconData icon;
  final String label;
  final String route;
  const DrawerItem({required this.icon, required this.label, required this.route});
}
