// lib/views/admin/product_approval_screen.dart
// Screen 19 of 20

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routes/app_routes.dart';
import '../../models/product_model.dart';
import '../../widgets/status_chip.dart';
import '../../providers/admin_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/admin_service.dart';
import '../../widgets/ean13_barcode.dart';

class ProductApprovalScreen extends StatefulWidget {
  const ProductApprovalScreen({super.key});

  @override
  State<ProductApprovalScreen> createState() => _ProductApprovalScreenState();
}

class _ProductApprovalScreenState extends State<ProductApprovalScreen> {
  final TextEditingController _rejectionReasonController = TextEditingController();
  final AdminService _adminService = AdminService();
  String? _processingProductId;

  @override
  void initState() {
    super.initState();
    // Listen to pending products on screen load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AdminProvider>().listenToPendingProducts();
    });
  }

  @override
  void dispose() {
    _rejectionReasonController.dispose();
    super.dispose();
  }

  void _showRejectionDialog(String productId, String productName) {
    _rejectionReasonController.clear();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Product'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Are you sure you want to reject "$productName"?',
                style: const TextStyle(fontSize: 14, color: AppColors.textSecondary)),
            const SizedBox(height: 16),
            TextField(
              controller: _rejectionReasonController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Enter rejection reason (e.g., Missing halal certificate, Invalid documentation)',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              if (_rejectionReasonController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a rejection reason')),
                );
                return;
              }

              Navigator.pop(context);
              await _rejectProduct(productId, _rejectionReasonController.text);
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  Future<void> _approveProduct(String productId) async {
    setState(() => _processingProductId = productId);
    try {
      final adminProvider = context.read<AdminProvider>();
      await adminProvider.approveProduct(
        productId,
        adminId: context.read<AuthProvider>().user?.uid,
      );
      await adminProvider.loadDashboardStats();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product approved successfully'), backgroundColor: Colors.green),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _processingProductId = null);
    }
  }

  Future<void> _rejectProduct(String productId, String reason) async {
    setState(() => _processingProductId = productId);
    try {
      final adminProvider = context.read<AdminProvider>();
      await adminProvider.rejectProduct(
        productId,
        reason,
        adminId: context.read<AuthProvider>().user?.uid,
      );
      await adminProvider.loadDashboardStats();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product rejected'), backgroundColor: Colors.orange),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: AppColors.error),
      );
    } finally {
      if (mounted) setState(() => _processingProductId = null);
    }
  }

  Widget _buildProductImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return _buildImageFallback();
    }

    final imageProvider = imageUrl.startsWith('http')
        ? NetworkImage(imageUrl)
        : AssetImage(imageUrl) as ImageProvider;

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image(
        image: imageProvider,
        width: 64,
        height: 64,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildImageFallback(),
      ),
    );
  }

  Widget _buildImageFallback() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(
        Icons.fastfood_outlined,
        color: AppColors.primary,
        size: 28,
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final value = dateTime.toLocal();
    final month = value.month.toString().padLeft(2, '0');
    final day = value.day.toString().padLeft(2, '0');
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '${value.year}-$month-$day $hour:$minute';
  }

  Widget _buildPreviewProductImage(String imageUrl) {
    if (imageUrl.isEmpty) return _buildImageFallback();
    final imageProvider = imageUrl.startsWith('http')
        ? NetworkImage(imageUrl)
        : AssetImage(imageUrl) as ImageProvider;
    return Image(
      image: imageProvider,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _buildImageFallback(),
    );
  }

  void _showProductPreview(ProductModel product) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.82,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (context, controller) {
            return ListView(
              controller: controller,
              padding: const EdgeInsets.all(20),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    StatusChip(status: product.certStatus.name),
                  ],
                ),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: SizedBox(
                    height: 210,
                    width: double.infinity,
                    child: _buildPreviewProductImage(product.imageUrl),
                  ),
                ),
                const SizedBox(height: 16),
                _PreviewRow(label: 'Category', value: product.category),
                _PreviewRow(
                  label: product.hasDiscount ? 'Original price' : 'Price',
                  value: product.formattedOriginalPrice,
                ),
                if (product.hasDiscount)
                  _PreviewRow(
                    label: 'Sale price',
                    value: product.formattedPrice,
                  ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primaryLight,
                      backgroundImage: product.sellerStoreImageUrl?.isNotEmpty == true
                          ? NetworkImage(product.sellerStoreImageUrl!)
                          : null,
                      child: product.sellerStoreImageUrl?.isNotEmpty == true
                          ? null
                          : const Icon(Icons.storefront, color: AppColors.primary),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _PreviewRow(label: 'Seller', value: product.sellerName),
                    ),
                  ],
                ),
                _PreviewRow(label: 'Product ID', value: product.id),
                _PreviewRow(
                  label: 'Submitted',
                  value: _formatDateTime(product.createdAt),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Description',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  product.description,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
                if (product.barcode?.isNotEmpty == true) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Ean13Barcode(code: product.barcode!),
                  ),
                ],
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Product Approval')),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Consumer<AdminProvider>(
        builder: (context, adminProvider, _) {
          if (adminProvider.isLoadingProducts && adminProvider.pendingProducts.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (adminProvider.productsError != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                  const SizedBox(height: 16),
                  Text('Error: ${adminProvider.productsError}', textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => adminProvider.listenToPendingProducts(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (adminProvider.pendingProducts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle_outline, size: 64, color: AppColors.primary.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  const Text('No pending products', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                  const SizedBox(height: 8),
                  const Text('All products have been reviewed', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.approvedProducts),
                    icon: const Icon(Icons.verified_outlined),
                    label: const Text('View Approved Products'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: adminProvider.pendingProducts.length,
            itemBuilder: (_, i) {
              final product = adminProvider.pendingProducts[i];
              final isProcessing = _processingProductId == product.id;

              return Card(
                margin: const EdgeInsets.only(bottom: 14),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _buildProductImage(product.imageUrl),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                FutureBuilder<String>(
                                  future: _adminService.getSellerStoreName(
                                    product.sellerId,
                                    product.sellerName,
                                  ),
                                  builder: (context, snapshot) {
                                    final storeName = snapshot.data ?? product.sellerName;
                                    return Text(
                                      'Store: $storeName',
                                      style: const TextStyle(
                                        color: AppColors.primary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    );
                                  },
                                ),
                                Text('${product.category} • \$${product.price.toStringAsFixed(2)}',
                                    style: const TextStyle(color: AppColors.textLight, fontSize: 12)),
                              ],
                            ),
                          ),
                          StatusChip(status: product.certStatus.name),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(product.description,
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.info_outline, size: 14, color: AppColors.primary),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text('ID: ${product.id}',
                                      style: const TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w500)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.schedule, size: 14, color: AppColors.primary),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Submitted: ${_formatDateTime(product.createdAt)}',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            const Row(
                              children: [
                                Icon(Icons.archive_outlined, size: 14, color: AppColors.primary),
                                SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Approved product information is kept until manually deleted.',
                                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: isProcessing
                              ? null
                              : () => _showProductPreview(product),
                          icon: const Icon(Icons.visibility_outlined),
                          label: const Text('Preview Product Details'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: isProcessing ? null : () => _approveProduct(product.id),
                              icon: isProcessing ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.check),
                              label: const Text('Approve'),
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: isProcessing ? null : () => _showRejectionDialog(product.id, product.name),
                              icon: isProcessing ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.close),
                              label: const Text('Reject'),
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _PreviewRow extends StatelessWidget {
  final String label;
  final String value;

  const _PreviewRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
