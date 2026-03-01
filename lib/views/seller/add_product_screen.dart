// lib/views/seller/add_product_screen.dart
// Screen 14 of 20

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/custom_button.dart';
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
  String _selectedCategory = AppConstants.categories.first;
  bool _isSaving = false;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _isSaving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Product added! Pending halal verification.'), backgroundColor: AppColors.primary),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add New Product')),
      backgroundColor: AppColors.surface,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(children: [
            // Image picker placeholder
            GestureDetector(
              onTap: () {},
              child: Container(
                height: 160, width: double.infinity,
                decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.primary, style: BorderStyle.solid)),
                child: const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.add_photo_alternate_outlined, size: 48, color: AppColors.primary),
                  SizedBox(height: 8),
                  Text('Tap to upload product image', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w500)),
                ]),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
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
            CustomButton(label: 'Submit Product', onPressed: _save, isLoading: _isSaving),
            const SizedBox(height: 24),
          ]),
        ),
      ),
    );
  }
}
