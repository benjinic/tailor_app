// main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart'; // <-- 引入 provider
import 'package:tailor_app/providers/cart_provider.dart'; // <-- 引入 cart provider
import 'package:tailor_app/screens/dashboard_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // --- 確保使用 ChangeNotifierProvider 將 CartProvider 注入到 App 的最頂層 ---
  runApp(
    ChangeNotifierProvider(
      create: (context) => CartProvider(),
      child: const AlexisBespokeApp(),
    ),
  );
}

class AlexisBespokeApp extends StatelessWidget {
  const AlexisBespokeApp({super.key});

  @override
  Widget build(BuildContext context) {
    const MaterialColor alexisPurple = MaterialColor(
      0xFF4A244A,
      <int, Color>{
          50: Color(0xFFE9E4E9), 100: Color(0xFFC9BFC8),
          200: Color(0xFFA596A4), 300: Color(0xFF816D80),
          400: Color(0xFF664F65), 500: Color(0xFF4A244A),
          600: Color(0xFF432043), 700: Color(0xFF3B1C3B),
          800: Color(0xFF331833), 900: Color(0xFF241024),
      },
    );

    return MaterialApp(
      title: 'ALEXIS BESPOKE',
      theme: ThemeData(
        primarySwatch: alexisPurple,
        scaffoldBackgroundColor: Colors.grey[100],
        visualDensity: VisualDensity.adaptivePlatformDensity,
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 1,
          centerTitle: true,
        ),
      ),
      home: const DashboardScreen(),
      debugShowCheckedModeBanner: false, 
    );
  }
}

