// lib/views/user/onboarding_screen.dart
// Halal Mart - Clean Premium Onboarding (No Images)

import 'package:flutter/material.dart';
import '../../core/routes/app_routes.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _current = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      "icon": Icons.verified_rounded,
      "title": "Certified Halal Products",
      "desc":
      "All products are verified and approved by trusted halal authorities.",
      "color1": const Color(0xFF0BA360),
      "color2": const Color(0xFF3CBA92),
    },
    {
      "icon": Icons.storefront_rounded,
      "title": "Trusted Halal Vendors",
      "desc":
      "Shop confidently from verified sellers across multiple categories.",
      "color1": const Color(0xFF4F46E5),
      "color2": const Color(0xFF6D28D9),
    },
    {
      "icon": Icons.local_shipping_rounded,
      "title": "Fast & Secure Delivery",
      "desc":
      "Get fresh halal groceries delivered safely to your doorstep.",
      "color1": const Color(0xFFF59E0B),
      "color2": const Color(0xFFD97706),
    },
  ];

  void _next() {
    if (_current < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> page = _pages[_current];

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [page["color1"] as Color, page["color2"] as Color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [

              /// Skip Button
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(
                      context, AppRoutes.login),
                  child: const Text(
                    "Skip",
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ),

              /// Page Content
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (i) =>
                      setState(() => _current = i),
                  itemBuilder: (_, index) {
                    final p = _pages[index];
                    return Padding(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children: [

                          /// Icon Circle
                          Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color.fromRGBO(255, 255, 255, 0.15),
                              border: Border.all(
                                color: const Color.fromRGBO(255, 255, 255, 0.3),
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              p["icon"] as IconData,
                              size: 70,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 50),

                          /// Title
                          Text(
                            p["title"],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),

                          const SizedBox(height: 16),

                          /// Description
                          Text(
                            p["desc"],
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.white70,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              /// Dots Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                      (i) => AnimatedContainer(
                    duration:
                    const Duration(milliseconds: 300),
                    margin: const EdgeInsets.symmetric(
                        horizontal: 4),
                    width: i == _current ? 24 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _current
                          ? Colors.white
                          : Colors.white38,
                      borderRadius:
                      BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              /// Next Button
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 40),
                child: ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: page["color1"] as Color,
                    minimumSize:
                    const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    _current == _pages.length - 1
                        ? "Get Started"
                        : "Next",
                    style: const TextStyle(
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}