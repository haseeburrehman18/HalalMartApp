// lib/views/user/checkout_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/order_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/input_field.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final OrderService _orderService = OrderService();

  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();

  String _paymentMethod = 'Online Banking';
  bool _isPlacing = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _placeOrder(CartProvider cart) async {
    if (!_formKey.currentState!.validate()) return;
    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your cart is empty')),
      );
      return;
    }

    final user = context.read<AuthProvider>().user;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login before checkout')),
      );
      return;
    }

    setState(() => _isPlacing = true);

    try {
      final orderIds = await _orderService.placeOrder(
        user: user,
        items: List.of(cart.items),
        customerName: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        deliveryAddress: _addressCtrl.text.trim(),
        paymentMethod: _paymentMethod,
      );

      await cart.clearCartFromDatabase();

      if (!mounted) return;

      setState(() => _isPlacing = false);

      Navigator.pushReplacementNamed(
        context,
        AppRoutes.orderConfirmation,
        arguments: orderIds,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isPlacing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not place order: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final user = context.watch<AuthProvider>().user;
    if (_nameCtrl.text.isEmpty && user != null) {
      _nameCtrl.text = user.name;
    }

    return Scaffold(
      backgroundColor: const Color(0xffF6F8FB),
      appBar: AppBar(
        title: const Text('Checkout'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// HEADER
              const Text(
                "Complete Your Order",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 16),

              /// DELIVERY DETAILS
              _Section(
                title: 'Delivery Details',
                child: Column(
                  children: [
                    InputField(
                      label: 'Full Name',
                      controller: _nameCtrl,
                      prefixIcon: Icons.person_outline,
                      validator: (v) =>
                      v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 14),
                    InputField(
                      label: 'Phone',
                      controller: _phoneCtrl,
                      prefixIcon: Icons.phone_outlined,
                      keyboardType:
                      TextInputType.phone,
                      validator: (v) =>
                      v!.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 14),
                    InputField(
                      label: 'Address',
                      controller: _addressCtrl,
                      prefixIcon:
                      Icons.location_on_outlined,
                      maxLines: 2,
                      validator: (v) =>
                      v!.isEmpty ? 'Required' : null,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              /// PAYMENT METHOD
              _Section(
                title: 'Payment Method',
                child: Column(
                  children: [
                    _paymentTile(
                        "Online Banking",
                        Icons.account_balance),
                    _paymentTile(
                        "Credit/Debit Card",
                        Icons.credit_card),
                    _paymentTile(
                        "Cash on Delivery",
                        Icons.payments_outlined),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              /// ORDER SUMMARY
              _Section(
                title: 'Order Summary',
                child: Column(
                  children: [
                    ...cart.items.map(
                          (item) => Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 6),
                        padding:
                        const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color:
                          const Color(0xffF3F6FA),
                          borderRadius:
                          BorderRadius.circular(
                              10),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.product.name,
                                style:
                                const TextStyle(
                                  fontSize: 13,
                                  fontWeight:
                                  FontWeight.w500,
                                ),
                              ),
                            ),
                            Text(
                              'x${item.quantity}',
                              style:
                              const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(
                                width: 8),
                            Text(
                              '\$${(item.product.price * item.quantity).toStringAsFixed(2)}',
                              style:
                              const TextStyle(
                                fontWeight:
                                FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,
                      children: [
                        const Text(
                          'Total Amount',
                          style: TextStyle(
                            fontWeight:
                            FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          '\$${cart.totalPrice.toStringAsFixed(2)}',
                          style:
                          const TextStyle(
                            fontWeight:
                            FontWeight.bold,
                            fontSize: 20,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              /// PLACE ORDER BUTTON
              CustomButton(
                label:
                'Place Order — \$${cart.totalPrice.toStringAsFixed(2)}',
                onPressed: () =>
                    _placeOrder(cart),
                isLoading: _isPlacing,
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  ////////////////////////////////////////////////////////////
  /// BEAUTIFUL PAYMENT TILE
  ////////////////////////////////////////////////////////////

  Widget _paymentTile(String title, IconData icon) {
    return Container(
      margin:
      const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xffF3F6FA),
        borderRadius:
        BorderRadius.circular(12),
      ),
      child: RadioListTile<String>(
        value: title,
        groupValue: _paymentMethod,
        onChanged: (v) =>
            setState(() =>
            _paymentMethod = v!),
        title: Row(
          children: [
            Icon(icon,
                size: 20,
                color: AppColors.primary),
            const SizedBox(width: 10),
            Text(title),
          ],
        ),
        activeColor: AppColors.primary,
        contentPadding:
        const EdgeInsets.symmetric(
            horizontal: 12),
      ),
    );
  }
}

////////////////////////////////////////////////////////////
/// SECTION CARD
////////////////////////////////////////////////////////////

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
      const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(0.05),
            blurRadius: 10,
            offset:
            const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight:
              FontWeight.bold,
              fontSize: 15,
              color:
              AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
