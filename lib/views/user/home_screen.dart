// lib/views/user/home_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routes/app_routes.dart';
import '../../core/constants/app_constants.dart';
import '../../models/product_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/product_service.dart';
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
    final theme = Theme.of(context);
    context.read<CartProvider>().bindUserCart(
          context.watch<AuthProvider>().user?.uid,
        );
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: IndexedStack(index: _idx, children: _tabs),

      /// SCANNER BUTTON
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
              color: AppColors.primary.withOpacity(0.5),
              blurRadius: 25,
              spreadRadius: 2,
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
        padding: EdgeInsets.zero,
        child: Container(
          height: 72,
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
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

class _HomeTab extends StatefulWidget {
  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> {
  final TextEditingController _searchController = TextEditingController();
  final ProductService _productService = ProductService();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _sortBy = 'Latest';
  bool _discountOnly = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilters() {
    String category = _selectedCategory;
    String sortBy = _sortBy;
    bool discountOnly = _discountOnly;

    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter Products',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: category,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    items: ['All', ...AppConstants.categories]
                        .map((item) =>
                            DropdownMenuItem(value: item, child: Text(item)))
                        .toList(),
                    onChanged: (value) =>
                        setSheetState(() => category = value ?? 'All'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: sortBy,
                    decoration: const InputDecoration(
                      labelText: 'Sort by',
                      prefixIcon: Icon(Icons.sort),
                    ),
                    items: const [
                      'Latest',
                      'Price: Low to High',
                      'Price: High to Low',
                      'Rating',
                    ]
                        .map((item) =>
                            DropdownMenuItem(value: item, child: Text(item)))
                        .toList(),
                    onChanged: (value) =>
                        setSheetState(() => sortBy = value ?? 'Latest'),
                  ),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Discounted products only'),
                    value: discountOnly,
                    onChanged: (value) =>
                        setSheetState(() => discountOnly = value),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _selectedCategory = 'All';
                              _sortBy = 'Latest';
                              _discountOnly = false;
                            });
                            Navigator.pop(context);
                          },
                          child: const Text('Reset'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedCategory = category;
                              _sortBy = sortBy;
                              _discountOnly = discountOnly;
                            });
                            Navigator.pop(context);
                          },
                          child: const Text('Apply'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<ProductModel> _applyFilters(List<ProductModel> products) {
    final query = _searchQuery.trim().toLowerCase();
    final filtered = products.where((p) {
      final matchesSearch = query.isEmpty ||
          p.name.toLowerCase().contains(query) ||
          p.category.toLowerCase().contains(query) ||
          p.description.toLowerCase().contains(query);
      final matchesCategory =
          _selectedCategory == 'All' || p.category == _selectedCategory;
      final matchesDiscount = !_discountOnly || p.hasDiscount;
      return matchesSearch && matchesCategory && matchesDiscount;
    }).toList();

    switch (_sortBy) {
      case 'Price: Low to High':
        filtered.sort((a, b) => a.finalPrice.compareTo(b.finalPrice));
        break;
      case 'Price: High to Low':
        filtered.sort((a, b) => b.finalPrice.compareTo(a.finalPrice));
        break;
      case 'Rating':
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      default:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cart = context.read<CartProvider>();
    final theme = Theme.of(context);
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
                  AnimatedOpacity(
                    duration:
                    const Duration(milliseconds: 800),
                    opacity: 1,
                    child: Text(
                      "Hi👋",
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
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
            child: AnimatedContainer(
              duration:
              const Duration(milliseconds: 400),
              height: 52,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius:
                BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary
                        .withOpacity(0.08),
                    blurRadius: 15,
                  )
                ],
                border:
                Border.all(color: AppColors.border),
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
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
                    color: AppColors.textSecondary,
                  ),
                  suffixIcon: InkWell(
                    onTap: _showFilters,
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
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
                  ),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ),

        if (_selectedCategory != 'All' || _discountOnly || _sortBy != 'Latest')
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (_selectedCategory != 'All')
                    Chip(label: Text(_selectedCategory)),
                  if (_discountOnly)
                    const Chip(label: Text('Discounts')),
                  if (_sortBy != 'Latest')
                    Chip(label: Text(_sortBy)),
                ],
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

        StreamBuilder<List<ProductModel>>(
          stream: _productService.getApprovedProducts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Center(child: CircularProgressIndicator()),
                ),
              );
            }

            if (snapshot.hasError) {
              return SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'Could not load products: ${snapshot.error}',
                    style: const TextStyle(color: AppColors.error),
                  ),
                ),
              );
            }

            final filteredProducts = _applyFilters(snapshot.data ?? []);

            if (filteredProducts.isEmpty) {
              return const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20, 12, 20, 0),
                  child: Center(
                    child: Text(
                      'No approved products found.',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ),
              );
            }

            return SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.56,
                ),
                delegate: SliverChildBuilderDelegate(
                  (_, i) => ProductCard(
                    product: filteredProducts[i],
                    onAddToCart: () {
                      cart.addProduct(filteredProducts[i]);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${filteredProducts[i].name} added'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                    },
                  ),
                  childCount: filteredProducts.length,
                ),
              ),
            );
          },
        ),

        const SliverToBoxAdapter(
            child: SizedBox(height: 40)),
      ],
    );
  }
}

/// ================= NAV ITEM =================

class _NavItem extends StatefulWidget {
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
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration:
      const Duration(milliseconds: 200),
    );

    _scale = Tween<double>(begin: 1, end: 1.2)
        .animate(_controller);
  }

  @override
  void didUpdateWidget(
      covariant _NavItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.active) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final color =
    widget.active ? AppColors.primary : Colors.grey;

    return Expanded(
      child: GestureDetector(
        onTap: widget.onTap,
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                ScaleTransition(
                  scale: _scale,
                  child: Icon(
                    widget.icon,
                    color: color,
                    size: 24,
                  ),
                ),
                if (widget.badgeCount > 0)
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
                        widget.badgeCount > 9
                            ? "9+"
                            : widget.badgeCount
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
              widget.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: widget.active
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
