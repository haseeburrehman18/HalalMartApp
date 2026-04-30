// lib/views/user/user_profile_screen.dart
// Screen 12 of 20

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../services/user_data_service.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  static final UserDataService _userDataService = UserDataService();

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
              onPressed: () {
                Navigator.of(dialogContext).pop();
                final auth = context.read<AuthProvider>();
                auth.logout();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.login,
                  (_) => false,
                );
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
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final photoUrl = user?.photoUrl ?? '';
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [

            /// HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 70, 24, 40),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primaryDark, AppColors.primary],
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(28),
                ),
              ),
              child: Column(
                children: [

                  /// PROFILE AVATAR
                  CircleAvatar(
                    radius: 44,
                    backgroundColor: Colors.white,
                    backgroundImage:
                        photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                    child: photoUrl.isEmpty
                        ? Text(
                            user?.name.isNotEmpty == true
                                ? user!.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          )
                        : null,
                  ),

                  const SizedBox(height: 14),

                  /// NAME
                  Text(
                    user?.name ?? 'Guest',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  /// EMAIL
                  Text(
                    user?.email ?? '',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// ROLE BADGE
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      user?.role.toUpperCase() ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  /// EDIT PROFILE BUTTON
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pushNamed(
                        context,
                        AppRoutes.editProfile,
                      );
                    },
                    icon: const Icon(Icons.edit, color: Colors.white),
                    label: const Text(
                      "Edit Profile",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// STATS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: user == null
                  ? const Row(
                      children: [
                        _StatCard('0', 'Orders'),
                        SizedBox(width: 12),
                        _StatCard('0', 'Wishlist'),
                        SizedBox(width: 12),
                        _StatCard('0', 'Reviews'),
                      ],
                    )
                  : StreamBuilder<UserProfileStats>(
                      stream: _userDataService.watchProfileStats(user.uid),
                      builder: (context, snapshot) {
                        final stats = snapshot.data;
                        return Row(
                          children: [
                            _StatCard(
                                (stats?.ordersCount ?? 0).toString(),
                                'Orders'),
                            const SizedBox(width: 12),
                            _StatCard(
                                (stats?.wishlistCount ?? 0).toString(),
                                'Wishlist'),
                            const SizedBox(width: 12),
                            _StatCard(
                                (stats?.reviewsCount ?? 0).toString(),
                                'Reviews'),
                          ],
                        );
                      },
                    ),
            ),

            const SizedBox(height: 16),

            /// MENU
            _ProfileMenu(items: [

              _MenuItem(
                icon: Icons.shopping_bag_outlined,
                label: 'My Orders',
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.myOrders);
                },
              ),

              _MenuItem(
                icon: Icons.location_on_outlined,
                label: 'Saved Addresses',
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.savedAddresses);
                },
              ),

              _MenuItem(
                icon: Icons.payment_outlined,
                label: 'Payment Methods',
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.paymentMethods);
                },
              ),

              _MenuItem(
                icon: Icons.favorite_border,
                label: 'Wishlist',
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.wishlist);
                },
              ),

              _MenuItem(
                icon: Icons.notifications_outlined,
                label: 'Notifications',
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.notifications);
                },
              ),

              _MenuItem(
                icon: Icons.help_outline,
                label: 'Help & Support',
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.helpSupport);
                },
              ),

              _MenuItem(
                icon: Icons.settings_outlined,
                label: 'Settings',
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.settings);
                },
              ),

            ]),

            const SizedBox(height: 16),

            /// LOGOUT
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ListTile(
                tileColor: const Color(0xFFFEE2E2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                leading: const Icon(Icons.logout, color: AppColors.error),
                title: const Text(
                  'Logout',
                  style: TextStyle(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () => _showLogoutConfirmation(context),
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
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
          )
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    ),
  );
}

class _ProfileMenu extends StatelessWidget {
  final List<_MenuItem> items;

  const _ProfileMenu({required this.items});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 6,
        )
      ],
    ),
    child: Column(
      children: items
          .map(
            (item) => Column(
          children: [
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  item.icon,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
              title: Text(
                item.label,
                style:
                const TextStyle(fontWeight: FontWeight.w500),
              ),
              trailing: const Icon(
                Icons.chevron_right,
                color: AppColors.textLight,
              ),
              onTap: item.onTap,
            ),
            if (item != items.last)
              const Divider(height: 1, indent: 64),
          ],
        ),
      )
          .toList(),
    ),
  );
}

class _MenuItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}
