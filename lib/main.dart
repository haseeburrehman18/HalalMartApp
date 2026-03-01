// lib/main.dart
// App entry point — wires providers, theme, and routing

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/routes/app_routes.dart';
import 'core/routes/route_generator.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // TODO: Uncomment when Firebase is configured
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const HalalVerifyApp());
}

class HalalVerifyApp extends StatelessWidget {
  const HalalVerifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        title: 'HalalVerify Marketplace',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: RouteGenerator.generateRoute,
      ),
    );
  }
}
