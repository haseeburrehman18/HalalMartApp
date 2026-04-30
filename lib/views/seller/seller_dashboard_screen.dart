import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../services/order_service.dart';
import '../../services/product_service.dart';
import '../../services/user_data_service.dart';
import '../../widgets/status_chip.dart';

class SellerDashboardScreen extends StatefulWidget {
  const SellerDashboardScreen({super.key});

  @override
  State<SellerDashboardScreen> createState() => _SellerDashboardScreenState();
}

class _SellerDashboardScreenState extends State<SellerDashboardScreen> {
  final ProductService _productService = ProductService();
  final OrderService _orderService = OrderService();
  final UserDataService _userDataService = UserDataService();
  Future<SellerDashboardStats>? _statsFuture;
  String? _loadedSellerId;
  bool _isUploadingStoreImage = false;

  void _loadStats(String sellerId) {
    if (_loadedSellerId == sellerId && _statsFuture != null) return;
    _loadedSellerId = sellerId;
    _statsFuture = _productService.getSellerDashboardStats(sellerId);
  }

  Future<void> _refreshStats(String sellerId) async {
    setState(() {
      _statsFuture = _productService.getSellerDashboardStats(sellerId);
    });
    await _statsFuture;
  }

  Future<void> _changeStoreImage() async {
    final auth = context.read<AuthProvider>();
    final user = auth.user;
    if (user == null || _isUploadingStoreImage) return;

    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    setState(() => _isUploadingStoreImage = true);
    try {
      final url = await _userDataService.uploadProfileImage(user.uid, picked);
      await auth.updateProfile(
        name: user.name,
        email: user.email,
        photoUrl: url,
      );
      await _productService.updateSellerStoreImage(
        sellerId: user.uid,
        imageUrl: url,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Store image updated'),
          backgroundColor: AppColors.primary,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not update store image: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isUploadingStoreImage = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final theme = Theme.of(context);

    if (user != null) {
      _loadStats(user.uid);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Dashboard'),
        actions: [
          if (user != null)
            StreamBuilder<int>(
              stream: _orderService.watchSellerPendingOrderCount(user.uid),
              builder: (context, snapshot) {
                final pendingCount = snapshot.data ?? 0;
                return Stack(
                  clipBehavior: Clip.none,
                  children: [
                    IconButton(
                      icon: Icon(
                        pendingCount > 0
                            ? Icons.notifications_active
                            : Icons.notifications_outlined,
                      ),
                      onPressed: () {
                        if (pendingCount > 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'You have $pendingCount pending order${pendingCount == 1 ? '' : 's'} to complete.',
                              ),
                              backgroundColor: AppColors.error,
                              action: SnackBarAction(
                                label: 'View',
                                textColor: Colors.white,
                                onPressed: () => Navigator.pushNamed(
                                  context,
                                  AppRoutes.sellerOrders,
                                ),
                              ),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('No pending orders right now.'),
                            ),
                          );
                        }
                      },
                    ),
                    if (pendingCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 18,
                            minHeight: 18,
                          ),
                          child: Text(
                            pendingCount > 9 ? '9+' : pendingCount.toString(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
        ],
      ),
      drawer: AppDrawer(
        role: 'seller',
        name: user?.shopName?.isNotEmpty == true ? user!.shopName! : user?.name ?? 'Seller',
        email: user?.email ?? '',
        items: const [
          DrawerItem(
            icon: Icons.dashboard_outlined,
            label: 'Dashboard',
            route: AppRoutes.sellerDashboard,
          ),
          DrawerItem(
            icon: Icons.add_box_outlined,
            label: 'Add Product',
            route: AppRoutes.addProduct,
          ),
          DrawerItem(
            icon: Icons.receipt_long_outlined,
            label: 'My Orders',
            route: AppRoutes.sellerOrders,
          ),
          DrawerItem(
            icon: Icons.inventory_2_outlined,
            label: 'My Products',
            route: '/my-products',
          ),
        ],
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: user == null
          ? const Center(child: Text('Please login again.'))
          : RefreshIndicator(
              onRefresh: () => _refreshStats(user.uid),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _WelcomeCard(
                      sellerName: user.name,
                      storeName: user.shopName?.isNotEmpty == true
                          ? user.shopName!
                          : user.name,
                      email: user.email,
                      storeImageUrl: user.photoUrl,
                      isUploadingStoreImage: _isUploadingStoreImage,
                      onChangeStoreImage: _changeStoreImage,
                      statsFuture: _statsFuture,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Overview',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    _SellerStatsGrid(statsFuture: _statsFuture),
                    const SizedBox(height: 20),
                    const Text(
                      'Quick Actions',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _ActionBtn(
                          icon: Icons.add_circle_outline,
                          label: 'Add Product',
                          onTap: () async {
                            await Navigator.pushNamed(
                                context, AppRoutes.addProduct);
                            if (context.mounted) {
                              await _refreshStats(user.uid);
                            }
                          },
                        ),
                        const SizedBox(width: 10),
                        _ActionBtn(
                          icon: Icons.receipt_outlined,
                          label: 'View Orders',
                          onTap: () => Navigator.pushNamed(
                              context, AppRoutes.sellerOrders),
                        ),
                        const SizedBox(width: 10),
                        _ActionBtn(
                          icon: Icons.inventory_2_outlined,
                          label: 'My Products',
                          onTap: () =>
                              Navigator.pushNamed(context, '/my-products'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Recent Orders',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 10),
                    const Center(
                      child: Text(
                        'No recent orders',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  final String sellerName;
  final String storeName;
  final String email;
  final String? storeImageUrl;
  final bool isUploadingStoreImage;
  final VoidCallback onChangeStoreImage;
  final Future<SellerDashboardStats>? statsFuture;

  const _WelcomeCard({
    required this.sellerName,
    required this.storeName,
    required this.email,
    required this.storeImageUrl,
    required this.isUploadingStoreImage,
    required this.onChangeStoreImage,
    required this.statsFuture,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onChangeStoreImage,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.18),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white.withOpacity(0.28)),
                    image: storeImageUrl?.isNotEmpty == true
                        ? DecorationImage(
                            image: NetworkImage(storeImageUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: storeImageUrl?.isNotEmpty == true
                      ? null
                      : const Icon(
                          Icons.storefront_rounded,
                          color: Colors.white,
                          size: 30,
                        ),
                ),
                Positioned(
                  right: -5,
                  bottom: -5,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: isUploadingStoreImage
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
                  'Welcome back,',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  storeName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Seller: $sellerName',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  email,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: FutureBuilder<SellerDashboardStats>(
              future: statsFuture,
              builder: (context, snapshot) {
                final rating =
                    snapshot.data?.averageRating.toStringAsFixed(1) ?? '0.0';
                return Column(
                  children: [
                    Text(
                      '$rating *',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const Text(
                      'Rating',
                      style: TextStyle(color: Colors.white70, fontSize: 10),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SellerStatsGrid extends StatelessWidget {
  final Future<SellerDashboardStats>? statsFuture;

  const _SellerStatsGrid({required this.statsFuture});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SellerDashboardStats>(
      future: statsFuture,
      builder: (context, snapshot) {
        final stats = snapshot.data;
        final isLoading = snapshot.connectionState == ConnectionState.waiting;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (snapshot.hasError)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Text(
                  'Could not load dashboard values: ${snapshot.error}',
                  style:
                      const TextStyle(color: AppColors.error, fontSize: 12),
                ),
              ),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _StatTile(
                  'Total Sales',
                  isLoading
                      ? '...'
                      : '\$${(stats?.totalSales ?? 0).toStringAsFixed(2)}',
                  Icons.trending_up,
                  AppColors.primaryLight,
                  AppColors.primary,
                ),
                _StatTile(
                  'Orders',
                  isLoading ? '...' : (stats?.ordersCount ?? 0).toString(),
                  Icons.shopping_bag_outlined,
                  AppColors.accentLight,
                  AppColors.accent,
                ),
                _StatTile(
                  'Products',
                  isLoading ? '...' : (stats?.productsCount ?? 0).toString(),
                  Icons.inventory_2_outlined,
                  const Color(0xFFE0F2FE),
                  const Color(0xFF0284C7),
                ),
                _StatTile(
                  'Pending',
                  isLoading
                      ? '...'
                      : (stats?.pendingProductsCount ?? 0).toString(),
                  Icons.hourglass_empty_outlined,
                  const Color(0xFFFCE7F3),
                  const Color(0xFFBE185D),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color bg, fg;

  const _StatTile(this.label, this.value, this.icon, this.bg, this.fg);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: fg, size: 26),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: fg,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: fg.withOpacity(0.7)),
          ),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: AppColors.primary, size: 26),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
