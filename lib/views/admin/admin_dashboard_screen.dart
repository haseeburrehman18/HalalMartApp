// lib/views/admin/admin_dashboard_screen.dart
// Screen 17 of 20

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routes/app_routes.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/admin_provider.dart';
import '../../services/admin_service.dart';
import '../../widgets/status_chip.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final AdminService _adminService = AdminService();
  bool _isUploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    // Load stats when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().loadDashboardStats();
      context.read<AdminProvider>().listenToPendingProducts();
    });
  }

  Future<void> _changeAdminPhoto() async {
    final auth = context.read<AuthProvider>();
    final user = auth.user;
    if (user == null || _isUploadingPhoto) return;

    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() => _isUploadingPhoto = true);
    try {
      final photoUrl = await _adminService.uploadAdminProfilePhoto(
        adminId: user.uid,
        imageFile: picked,
      );
      await auth.updateProfile(
        name: user.name,
        email: user.email,
        photoUrl: photoUrl,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Admin profile picture updated'),
          backgroundColor: AppColors.primary,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not update photo: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final adminProvider = context.watch<AdminProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      drawer: AppDrawer(
        role: 'admin',
        name: user?.name ?? 'Admin',
        email: user?.email ?? '',
        items: [
          DrawerItem(icon: Icons.dashboard_outlined, label: 'Dashboard', route: AppRoutes.adminDashboard),
          DrawerItem(icon: Icons.inventory_2_outlined, label: 'Product Approval', route: AppRoutes.productApproval),
          DrawerItem(icon: Icons.verified_outlined, label: 'Approved Products', route: AppRoutes.approvedProducts),
          DrawerItem(icon: Icons.people_outlined, label: 'User Management', route: AppRoutes.userManagement),
        ],
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: RefreshIndicator(
        onRefresh: () => context.read<AdminProvider>().loadDashboardStats(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _AdminHeroCard(
            name: user?.name ?? 'Admin',
            email: user?.email ?? '',
            photoUrl: user?.photoUrl,
            isUploading: _isUploadingPhoto,
            pendingCount: adminProvider.pendingCount,
            onChangePhoto: _changeAdminPhoto,
          ),
          const SizedBox(height: 20),

          // Stats
          const Text('Platform Overview', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.5,
            children: [
              _AdminStat(
                'Total Users',
                adminProvider.isLoadingStats ? '...' : adminProvider.totalUsers.toString(),
                Icons.people_outline,
                AppColors.primaryLight,
                AppColors.primary,
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.userManagement,
                  arguments: 'all',
                ),
              ),
              _AdminStat(
                'Sellers',
                adminProvider.isLoadingStats ? '...' : adminProvider.totalSellers.toString(),
                Icons.storefront_outlined,
                AppColors.accentLight,
                AppColors.accent,
                onTap: () => Navigator.pushNamed(
                  context,
                  AppRoutes.userManagement,
                  arguments: AppConstants.roleSeller,
                ),
              ),
              _AdminStat(
                'Products',
                adminProvider.isLoadingStats ? '...' : adminProvider.totalProducts.toString(),
                Icons.inventory_2_outlined,
                const Color(0xFFE0F2FE),
                const Color(0xFF0284C7),
                onTap: () => Navigator.pushNamed(context, AppRoutes.approvedProducts),
              ),
              _AdminStat(
                'Pending Products',
                adminProvider.isLoadingStats ? '...' : adminProvider.pendingCount.toString(),
                Icons.pending_outlined,
                const Color(0xFFFCE7F3),
                const Color(0xFFBE185D),
                onTap: () => Navigator.pushNamed(context, AppRoutes.productApproval),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Quick actions
          const Text('Actions Required', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          _ActionCard(
            icon: Icons.inventory_2_outlined, color: AppColors.accent,
            title: 'Product Approvals', subtitle: '${adminProvider.pendingCount} awaiting approval',
            onTap: () => Navigator.pushNamed(context, AppRoutes.productApproval),
          ),
          const SizedBox(height: 8),
          _ActionCard(
            icon: Icons.people_outlined, color: const Color(0xFF7C3AED),
            title: 'User Management', subtitle: '${adminProvider.totalUsers} total users',
            onTap: () => Navigator.pushNamed(context, AppRoutes.userManagement),
          ),
          const SizedBox(height: 20),

          const Text('Platform Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(10)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.check_circle, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  const Expanded(child: Text('All systems operational', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
                  Text(DateTime.now().toString().split('.')[0], style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
                ]),
                const SizedBox(height: 8),
                Container(
                  height: 2,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [AppColors.primary, AppColors.accent]),
                    borderRadius: BorderRadius.circular(1),
                  ),
                )
              ],
            ),
          ),
          ]),
        ),
      ),
    );
  }
}

class _AdminStat extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color bg, fg;
  final VoidCallback? onTap;
  const _AdminStat(this.label, this.value, this.icon, this.bg, this.fg, {this.onTap});

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Ink(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: fg, size: 26),
          const Spacer(),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: fg)),
          Text(label, style: TextStyle(fontSize: 12, color: fg.withOpacity(0.7))),
        ]),
      ),
    ),
  );
}

class _AdminHeroCard extends StatelessWidget {
  final String name;
  final String email;
  final String? photoUrl;
  final bool isUploading;
  final int pendingCount;
  final VoidCallback onChangePhoto;

  const _AdminHeroCard({
    required this.name,
    required this.email,
    required this.photoUrl,
    required this.isUploading,
    required this.pendingCount,
    required this.onChangePhoto,
  });

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoUrl != null && photoUrl!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF102A43), Color(0xFF0BA360), Color(0xFF3CBA92)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.22),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: onChangePhoto,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 34,
                      backgroundColor: Colors.white.withOpacity(0.18),
                      backgroundImage: hasPhoto ? NetworkImage(photoUrl!) : null,
                      child: !hasPhoto
                          ? const Icon(
                              Icons.admin_panel_settings_rounded,
                              color: Colors.white,
                              size: 34,
                            )
                          : null,
                    ),
                    Positioned(
                      right: -2,
                      bottom: -2,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primary),
                        ),
                        child: isUploading
                            ? const Padding(
                                padding: EdgeInsets.all(5),
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(
                                Icons.camera_alt,
                                size: 14,
                                color: AppColors.primary,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Halal Mart Command Center',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.82),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _HeroPill(
                icon: Icons.pending_actions,
                label: '$pendingCount pending',
              ),
              const SizedBox(width: 10),
              const _HeroPill(
                icon: Icons.verified_user,
                label: 'Manual approval',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeroPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.16),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.18)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
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
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surface, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
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
