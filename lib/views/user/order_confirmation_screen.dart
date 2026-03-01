// lib/views/user/order_confirmation_screen.dart
// Screen 11 of 20

import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/routes/app_routes.dart';
import '../../widgets/custom_button.dart';

class OrderConfirmationScreen extends StatelessWidget {
  const OrderConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderId = 'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              // Success animation
              Container(
                width: 120, height: 120,
                decoration: BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
                child: const Icon(Icons.check_circle_rounded, size: 72, color: AppColors.primary),
              ),
              const SizedBox(height: 28),
              const Text('Order Placed!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 10),
              const Text(
                "Your halal order has been confirmed.\nWe'll notify you once it's shipped.",
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textSecondary, height: 1.6, fontSize: 15),
              ),
              const SizedBox(height: 28),
              // Order ID card
              Container(
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                child: Column(children: [
                  const Text('Order ID', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  const SizedBox(height: 6),
                  Text(orderId, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary, letterSpacing: 1.5)),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 12),
                  _ConfirmRow(icon: Icons.local_shipping_outlined, text: 'Estimated delivery: 2-3 business days'),
                  const SizedBox(height: 8),
                  _ConfirmRow(icon: Icons.verified_outlined, text: 'All products are halal certified'),
                  const SizedBox(height: 8),
                  _ConfirmRow(icon: Icons.notifications_outlined, text: 'You\'ll receive SMS updates'),
                ]),
              ),
              const Spacer(),
              CustomButton(
                label: 'Continue Shopping',
                onPressed: () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false),
              ),
              const SizedBox(height: 12),
              CustomButton(
                label: 'View Orders',
                isOutlined: true,
                onPressed: () => Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (_) => false),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConfirmRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _ConfirmRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 18, color: AppColors.primary),
    const SizedBox(width: 10),
    Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
  ]);
}
