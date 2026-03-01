// lib/views/user/login_screen.dart
// Halal Mart - Premium Modern Login UI

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/routes/app_routes.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _rememberMe = true;
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final success =
    await auth.login(_emailCtrl.text.trim(), _passCtrl.text);

    // Debug: print auth result and role
    // Remove or guard these prints in production
    debugPrint('Login attempt for ${_emailCtrl.text.trim()}, success=$success, role=${auth.role}, error=${auth.error}');

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
    } else {
      // Show error, but in debug mode also allow jumping to home to test UI.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? "Login failed"),
          backgroundColor: Colors.red,
        ),
      );

      assert(() {
        // In debug, if login failed, still navigate to home so developer can verify UI
        debugPrint('Debug fallback: navigating to home to test UI');
        Navigator.pushReplacementNamed(context, AppRoutes.home);
        return true;
      }());
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F9),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Form(
              key: _formKey,
              child: Column(
                children: [

                  const SizedBox(height: 30),

                  /// 🌈 Premium Colorful Logo
                  Container(
                    width: 95,
                    height: 95,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF0BA360),
                          Color(0xFF3CBA92),
                          Color(0xFF4F46E5),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0BA360)
                              .withOpacity(0.4),
                          blurRadius: 25,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.shopping_bag_rounded,
                        color: Colors.white,
                        size: 45,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// Stylish Brand Name
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: "Halal ",
                          style: GoogleFonts.poppins(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0BA360),
                          ),
                        ),
                        TextSpan(
                          text: "Mart",
                          style: GoogleFonts.poppins(
                            fontSize: 30,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF4F46E5),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "Trusted Halal Marketplace",
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  const SizedBox(height: 40),

                  /// Sign In Label
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Sign in",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  /// Email Field
                  _buildInputField(
                    controller: _emailCtrl,
                    hint: "abc@email.com",
                    icon: Icons.email_outlined,
                    validator: (v) =>
                    v!.isEmpty ? "Enter email" : null,
                  ),

                  const SizedBox(height: 16),

                  /// Password Field
                  _buildInputField(
                    controller: _passCtrl,
                    hint: "Your password",
                    icon: Icons.lock_outline,
                    obscure: _obscure,
                    suffix: IconButton(
                      icon: Icon(_obscure
                          ? Icons.visibility_off
                          : Icons.visibility),
                      onPressed: () =>
                          setState(() => _obscure = !_obscure),
                    ),
                    validator: (v) =>
                    v!.isEmpty ? "Enter password" : null,
                  ),

                  const SizedBox(height: 10),

                  /// Remember + Forgot
                  Row(
                    children: [
                      Switch(
                        value: _rememberMe,
                        activeColor:
                        const Color(0xFF0BA360),
                        onChanged: (v) =>
                            setState(() => _rememberMe = v),
                      ),
                      Text(
                        "Remember Me",
                        style: GoogleFonts.poppins(
                            fontSize: 13),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          "Forgot Password?",
                          style: GoogleFonts.poppins(
                              fontSize: 13,
                              color: Colors.grey),
                        ),
                      )
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// Sign In Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                        const Color(0xFF4F46E5),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(14),
                        ),
                        elevation: 6,
                      ),
                      child: isLoading
                          ? const CircularProgressIndicator(
                          color: Colors.white)
                          : Text(
                        "SIGN IN",
                        style: GoogleFonts.poppins(
                          fontWeight:
                          FontWeight.bold,
                          letterSpacing: 1,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  Text("OR",
                      style: GoogleFonts.poppins(
                          color: Colors.grey)),

                  const SizedBox(height: 20),

                  _socialButton(
                      icon: Icons.g_mobiledata,
                      text: "Login with Google"),

                  const SizedBox(height: 12),

                  _socialButton(
                      icon: Icons.facebook,
                      text: "Login with Facebook"),

                  const SizedBox(height: 30),

                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: GoogleFonts.poppins(
                            color: Colors.grey),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.register),
                        child: Text(
                          "Sign up",
                          style: GoogleFonts.poppins(
                              fontWeight:
                              FontWeight.bold,
                              color:
                              const Color(0xFF4F46E5)),
                        ),
                      )
                    ],
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
        const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _socialButton({
    required IconData icon,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border:
        Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          Icon(icon),
          const SizedBox(width: 8),
          Text(text,
              style: GoogleFonts.poppins()),
        ],
      ),
    );
  }
}