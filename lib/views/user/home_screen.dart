// lib/views/user/home_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routes/app_routes.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/product_card.dart';
import 'categories_screen.dart';
import 'cart_screen.dart';
import 'user_profile_screen.dart';
import 'scan_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _idx = 0;

  final _tabs = [
    _HomeTab(),
    const CategoriesScreen(),
    const CartScreen(),
    const UserProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(index: _idx, children: _tabs),

      /// CENTER SCANNER BUTTON
      floatingActionButtonLocation:
      FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        height: 66,
        width: 66,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            colors: [Color(0xFF0BA360), Color(0xFF3CBA92)],
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.4),
              blurRadius: 20,
            )
          ],
        ),
        child: FloatingActionButton(
          elevation: 0,
          backgroundColor: Colors.transparent,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ScanScreen(),
              ),
            );
          },
          child: const Icon(
            Icons.qr_code_scanner_rounded,
            size: 30,
            color: Colors.white,
          ),
        ),
      ),

      /// NAVBAR
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        elevation: 15,
        child: Container(
          height: 72,
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: AppColors.border),
            ),
          ),
          child: Row(
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: "Home",
                active: _idx == 0,
                onTap: () => setState(() => _idx = 0),
              ),
              _NavItem(
                icon: Icons.grid_view_rounded,
                label: "Categories",
                active: _idx == 1,
                onTap: () => setState(() => _idx = 1),
              ),
              const SizedBox(width: 40),
              Consumer<CartProvider>(
                builder: (_, cart, __) => _NavItem(
                  icon: Icons.shopping_cart_rounded,
                  label: "Cart",
                  active: _idx == 2,
                  badgeCount: cart.itemCount,
                  onTap: () => setState(() => _idx = 2),
                ),
              ),
              _NavItem(
                icon: Icons.person_rounded,
                label: "Profile",
                active: _idx == 3,
                onTap: () => setState(() => _idx = 3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ================= HOME TAB =================

class _HomeTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cart = context.read<CartProvider>();
    final products = ProductModel.mockProducts;

    return CustomScrollView(
      slivers: [

        /// HEADER
        SliverToBoxAdapter(
          child: SafeArea(
            child: Padding(
              padding:
              const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    "Assalamu Alaikum 👋",
                    style: GoogleFonts.dmSans(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    auth.user?.name ?? "Guest",
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        /// SEARCH BAR
        SliverToBoxAdapter(
          child: Padding(
            padding:
            const EdgeInsets.fromLTRB(
                20, 24, 20, 0),
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black
                        .withOpacity(0.05),
                    blurRadius: 10,
                  )
                ],
                border: Border.all(
                    color: AppColors.border),
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText:
                  "Search halal products...",
                  hintStyle: GoogleFonts.dmSans(
                    color:
                    AppColors.textSecondary,
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Colors.grey,
                  ),
                  suffixIcon: Container(
                    margin:
                    const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius:
                      BorderRadius
                          .circular(10),
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ),

        /// FEATURED HEADER
        SliverToBoxAdapter(
          child: Padding(
            padding:
            const EdgeInsets.fromLTRB(
                20, 30, 20, 12),
            child: HvSectionHeader(
              title: 'Featured Products',
              action: 'View All',
              onAction: () =>
                  Navigator.pushNamed(
                      context,
                      AppRoutes.productList,
                      arguments: 'All'),
            ),
          ),
        ),

        /// PRODUCT GRID
        SliverPadding(
          padding:
          const EdgeInsets.symmetric(
              horizontal: 20),
          sliver: SliverGrid(
            gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 14,
              crossAxisSpacing: 14,
              childAspectRatio: 0.65,
            ),
            delegate:
            SliverChildBuilderDelegate(
                  (_, i) => ProductCard(
                product: products[i],
                onAddToCart: () {
                  cart.addProduct(
                      products[i]);
                  ScaffoldMessenger.of(
                      context)
                      .showSnackBar(
                    SnackBar(
                      content: Text(
                          '${products[i].name} added'),
                      backgroundColor:
                      AppColors.primary,
                    ),
                  );
                },
              ),
              childCount:
              products.length,
            ),
          ),
        ),

        const SliverToBoxAdapter(
            child: SizedBox(height: 40)),
      ],
    );
  }
}

/// ================= NAV ITEM =================

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;
  final int badgeCount;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final color =
    active ? AppColors.primary : Colors.grey;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                Icon(icon,
                    color: color, size: 24),
                if (badgeCount > 0)
                  Positioned(
                    right: -6,
                    top: -4,
                    child: Container(
                      padding:
                      const EdgeInsets.all(4),
                      decoration:
                      const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        badgeCount > 9
                            ? "9+"
                            : badgeCount
                            .toString(),
                        style:
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: active
                    ? FontWeight.w600
                    : FontWeight.w400,
                color: color,
              ),
            )
          ],
        ),
      ),
    );
  }
}

/// ================= SECTION HEADER =================

class HvSectionHeader extends StatelessWidget {
  final String title;
  final String action;
  final VoidCallback onAction;

  const HvSectionHeader({
    super.key,
    required this.title,
    required this.action,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
      MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: GoogleFonts.dmSans(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        GestureDetector(
          onTap: onAction,
          child: Text(
            action,
            style: GoogleFonts.dmSans(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}