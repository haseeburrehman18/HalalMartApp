// lib/views/user/register_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/routes/app_routes.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/input_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  String _selectedRole = AppConstants.roleUser;
  bool _showPasswordStrength = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  double _passwordStrength(String password) {
    if (password.length < 6) return 0.2;
    if (password.length < 8) return 0.5;
    if (password.contains(RegExp(r'[A-Z]')) &&
        password.contains(RegExp(r'[0-9]'))) {
      return 1.0;
    }
    return 0.7;
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.register(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
      role: _selectedRole,
    );

    if (!mounted) return;

    if (success) {
      final role = auth.role;
      if (role == AppConstants.roleAdmin) {
        Navigator.pushReplacementNamed(context, AppRoutes.adminDashboard);
      } else if (role == AppConstants.roleSeller) {
        Navigator.pushReplacementNamed(context, AppRoutes.sellerDashboard);
      } else {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0BA360), Color(0xFF3CBA92)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [

                const SizedBox(height: 40),

                /// TITLE
                const Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  "Join HalalVerify Today",
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 40),

                /// CARD
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [

                        InputField(
                          label: 'Full Name',
                          controller: _nameCtrl,
                          prefixIcon: Icons.person_outline,
                          validator: (v) =>
                          v!.isEmpty ? 'Enter name' : null,
                        ),

                        const SizedBox(height: 18),

                        InputField(
                          label: 'Email Address',
                          controller: _emailCtrl,
                          prefixIcon: Icons.email_outlined,
                          keyboardType:
                          TextInputType.emailAddress,
                          validator: (v) =>
                          v!.isEmpty ? 'Enter email' : null,
                        ),

                        const SizedBox(height: 18),

                        InputField(
                          label: 'Password',
                          controller: _passCtrl,
                          prefixIcon: Icons.lock_outline,
                          isPassword: true,
                          onChanged: (v) =>
                              setState(() =>
                              _showPasswordStrength = true),
                          validator: (v) =>
                          v!.length < 6
                              ? 'Min 6 characters'
                              : null,
                        ),

                        if (_showPasswordStrength) ...[
                          const SizedBox(height: 10),
                          LinearProgressIndicator(
                            value: _passwordStrength(
                                _passCtrl.text),
                            minHeight: 6,
                            backgroundColor:
                            Colors.grey.shade200,
                            color: _passwordStrength(
                                _passCtrl.text) >
                                0.7
                                ? Colors.green
                                : Colors.orange,
                          ),
                        ],

                        const SizedBox(height: 24),

                        /// ROLE SELECTOR
                        Row(
                          children: [
                            _ModernRoleButton(
                              label: "Customer",
                              icon: Icons.person,
                              selected: _selectedRole ==
                                  AppConstants.roleUser,
                              onTap: () => setState(() =>
                              _selectedRole =
                                  AppConstants.roleUser),
                            ),
                            const SizedBox(width: 12),
                            _ModernRoleButton(
                              label: "Seller",
                              icon: Icons.storefront,
                              selected: _selectedRole ==
                                  AppConstants.roleSeller,
                              onTap: () => setState(() =>
                              _selectedRole =
                                  AppConstants.roleSeller),
                            ),
                            const SizedBox(width: 12),
                            _ModernRoleButton(
                              label: "Admin",
                              icon:
                              Icons.admin_panel_settings,
                              selected: _selectedRole ==
                                  AppConstants.roleAdmin,
                              onTap: () => setState(() =>
                              _selectedRole =
                                  AppConstants.roleAdmin),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        CustomButton(
                          label: "Create Account",
                          onPressed: _register,
                          isLoading: isLoading,
                        ),

                        const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.center,
                          children: [
                            const Text(
                                "Already have an account? "),
                            GestureDetector(
                              onTap: () =>
                                  Navigator.pop(context),
                              child: const Text(
                                "Login",
                                style: TextStyle(
                                  color:
                                  Color(0xFF0BA360),
                                  fontWeight:
                                  FontWeight.bold,
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Role Button
class _ModernRoleButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ModernRoleButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: selected
                ? const LinearGradient(
              colors: [
                Color(0xFF0BA360),
                Color(0xFF3CBA92)
              ],
            )
                : null,
            color:
            selected ? null : Colors.grey.shade100,
          ),
          child: Column(
  //new
            children: [
              Icon(icon,
                  color: selected
                      ? Colors.white
                      : Colors.grey),
              const SizedBox(height: 6),
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: selected
                      ? Colors.white
                      : Colors.grey,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}