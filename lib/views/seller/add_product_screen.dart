// lib/views/seller/add_product_screen.dart
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../models/product_model.dart';
import '../../providers/auth_provider.dart';
import '../../services/product_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/ean13_barcode.dart';
import '../../widgets/input_field.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _discountPriceCtrl = TextEditingController();
  final _barcodeCtrl = TextEditingController();
  String _selectedCategory = AppConstants.categories.first;
  XFile? _imageFile;
  Uint8List? _imagePreviewBytes;
  bool _isSaving = false;

  final ProductService _productService = ProductService();

  @override
  void initState() {
    super.initState();
    _barcodeCtrl.text = Ean13Barcode.generate(
      DateTime.now().millisecondsSinceEpoch.toString(),
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _priceCtrl.dispose();
    _discountPriceCtrl.dispose();
    _barcodeCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final previewBytes = await pickedFile.readAsBytes();
      setState(() {
        _imageFile = pickedFile;
        _imagePreviewBytes = previewBytes;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a product image'), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      final user = context.read<AuthProvider>().user;
      if (user == null) throw Exception("User not logged in");

      final product = ProductModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sellerId: user.uid,
        sellerName: user.shopName?.isNotEmpty == true ? user.shopName! : user.name,
        sellerStoreImageUrl: user.photoUrl,
        name: _nameCtrl.text.trim(),
        slug: _nameCtrl.text.trim().toLowerCase().replaceAll(' ', '-'),
        description: _descCtrl.text.trim(),
        price: double.parse(_priceCtrl.text),
        discountPrice: _discountPriceCtrl.text.isNotEmpty ? double.parse(_discountPriceCtrl.text) : null,
        category: _selectedCategory,
        imageUrl: '', // Will be updated by service
        barcode: _barcodeCtrl.text.trim(),
        certStatus: CertificationStatus.pending,
        createdAt: DateTime.now(),
      );

      await _productService.addProduct(product, _imageFile);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product added! Pending halal verification.'), backgroundColor: AppColors.primary),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Product')),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(children: [
            // Image picker
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                height: 160, width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary, style: BorderStyle.solid),
                  image: _imagePreviewBytes != null ? DecorationImage(image: MemoryImage(_imagePreviewBytes!), fit: BoxFit.cover) : null,
                ),
                child: _imageFile == null ? const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.add_photo_alternate_outlined, size: 48, color: AppColors.primary),
                  SizedBox(height: 8),
                  Text('Tap to upload product image', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500)),
                ]) : null,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: theme.colorScheme.surface, borderRadius: BorderRadius.circular(14)),
              child: Column(children: [
                InputField(label: 'Product Name', controller: _nameCtrl, prefixIcon: Icons.inventory_2_outlined,
                    validator: (v) => v!.isEmpty ? 'Required' : null),
                const SizedBox(height: 14),
                InputField(label: 'Description', controller: _descCtrl, prefixIcon: Icons.description_outlined, maxLines: 3,
                    validator: (v) => v!.isEmpty ? 'Required' : null),
                const SizedBox(height: 14),
                InputField(label: 'Price (USD)', controller: _priceCtrl, prefixIcon: Icons.attach_money, keyboardType: TextInputType.number,
                    validator: (v) => v!.isEmpty ? 'Required' : null),
                const SizedBox(height: 14),
                InputField(label: 'Discount Price (Optional)', controller: _discountPriceCtrl, prefixIcon: Icons.money_off, keyboardType: TextInputType.number),
                const SizedBox(height: 14),
                InputField(
                  label: 'Auto Generated Barcode',
                  controller: _barcodeCtrl,
                  prefixIcon: Icons.qr_code_2_outlined,
                  keyboardType: TextInputType.number,
                  onChanged: (_) => setState(() {}),
                  validator: (v) => Ean13Barcode.isValid(v ?? '')
                      ? null
                      : 'Barcode must be a valid 13 digit EAN code',
                ),
                const SizedBox(height: 10),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Ean13Barcode(code: _barcodeCtrl.text),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(labelText: 'Category', prefixIcon: Icon(Icons.category_outlined)),
                  items: AppConstants.categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                  onChanged: (v) => setState(() => _selectedCategory = v!),
                ),
              ]),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.accentLight, borderRadius: BorderRadius.circular(12)),
              child: const Row(children: [
                Icon(Icons.info_outline, color: AppColors.accent),
                SizedBox(width: 10),
                Expanded(child: Text('Your product will be reviewed for halal certification before listing.', style: TextStyle(fontSize: 13, color: AppColors.textSecondary))),
              ]),
            ),
            const SizedBox(height: 24),
            CustomButton(label: 'Submit Product', onPressed: _isSaving ? null : _save, isLoading: _isSaving),
            const SizedBox(height: 24),
          ]),
        ),
      ),
    );
  }
}
