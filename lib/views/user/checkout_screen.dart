// lib/views/user/checkout_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routes/app_routes.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/input_field.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl =
  TextEditingController(text: 'Ahmed Ali');
  final _phoneCtrl =
  TextEditingController(text: '+60 12-345 6789');
  final _addressCtrl = TextEditingController(
      text: '123, Jalan Halal, Kuala Lumpur');

  String _paymentMethod = 'Online Banking';
  bool _isPlacing = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  Future<void> _placeOrder(
      CartProvider cart) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isPlacing = true);

    await Future.delayed(
        const Duration(seconds: 2));

    /// FIXED: use clearCart() not clear()
    cart.clearCart();

    if (!mounted) return;

    setState(() => _isPlacing = false);

    Navigator.pushReplacementNamed(
        context, AppRoutes.orderConfirmation);
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar:
      AppBar(title: const Text('Checkout')),
      backgroundColor: AppColors.surface,
      body: SingleChildScrollView(
        padding:
        const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [

              /// DELIVERY DETAILS
              _Section(
                title: 'Delivery Details',
                child: Column(
                  children: [
                    InputField(
                      label: 'Full Name',
                      controller: _nameCtrl,
                      prefixIcon:
                      Icons.person_outline,
                      validator: (v) =>
                      v!.isEmpty
                          ? 'Required'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    InputField(
                      label: 'Phone',
                      controller: _phoneCtrl,
                      prefixIcon:
                      Icons.phone_outlined,
                      keyboardType:
                      TextInputType.phone,
                      validator: (v) =>
                      v!.isEmpty
                          ? 'Required'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    InputField(
                      label: 'Address',
                      controller: _addressCtrl,
                      prefixIcon: Icons
                          .location_on_outlined,
                      maxLines: 2,
                      validator: (v) =>
                      v!.isEmpty
                          ? 'Required'
                          : null,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              /// PAYMENT METHOD
              _Section(
                title: 'Payment Method',
                child: Column(
                  children: [
                    'Online Banking',
                    'Credit/Debit Card',
                    'Cash on Delivery'
                  ]
                      .map(
                        (method) =>
                        RadioListTile<String>(
                          value: method,
                          groupValue:
                          _paymentMethod,
                          onChanged: (v) =>
                              setState(() =>
                              _paymentMethod =
                              v!),
                          title: Text(method),
                          activeColor:
                          AppColors.primary,
                          contentPadding:
                          EdgeInsets.zero,
                        ),
                  )
                      .toList(),
                ),
              ),

              const SizedBox(height: 12),

              /// ORDER SUMMARY
              _Section(
                title: 'Order Summary',
                child: Column(
                  children: [

                    /// FIXED: access product properly
                    ...cart.items.map(
                          (item) => Padding(
                        padding:
                        const EdgeInsets
                            .symmetric(
                            vertical: 4),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                item.product.name,
                                style:
                                const TextStyle(
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            Text(
                              'x${item.quantity}',
                              style:
                              const TextStyle(
                                color: AppColors
                                    .textSecondary,
                              ),
                            ),
                            const SizedBox(
                                width: 8),
                            Text(
                              '\$${(item.product.price * item.quantity).toStringAsFixed(2)}',
                              style:
                              const TextStyle(
                                fontWeight:
                                FontWeight
                                    .w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Divider(),

                    /// FIXED: use totalPrice
                    Row(
                      mainAxisAlignment:
                      MainAxisAlignment
                          .spaceBetween,
                      children: [
                        const Text(
                          'Total',
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
                            fontSize: 18,
                            color: AppColors
                                .primaryDark,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

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
        BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black
                .withOpacity(0.05),
            blurRadius: 6,
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
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}