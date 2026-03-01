// lib/widgets/custom_button.dart
import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? color;
  final double? width;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.color,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final btn = isOutlined
        ? OutlinedButton(
            onPressed: isLoading ? null : onPressed,
            style: OutlinedButton.styleFrom(
              minimumSize: Size(width ?? double.infinity, 52),
              side: BorderSide(color: color ?? AppColors.primary, width: 2),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _child(color ?? AppColors.primary),
          )
        : ElevatedButton(
            onPressed: isLoading ? null : onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: color ?? AppColors.primary,
              minimumSize: Size(width ?? double.infinity, 52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _child(Colors.white),
          );
    return btn;
  }

  Widget _child(Color textColor) => isLoading
      ? SizedBox(
          height: 22, width: 22,
          child: CircularProgressIndicator(color: textColor, strokeWidth: 2.5),
        )
      : Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 16));
}
