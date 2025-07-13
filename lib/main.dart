// lib/main.dart - UPDATED WITH PROFESSIONAL OCEAN THEME
// lib/main.dart - UPDATED to use Ocean Theme
/*
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'splash_screen.dart';
import 'home_screen.dart';
import 'mood_data_service.dart';
import 'theme/app_theme.dart'; // ADD THIS LINE
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  
  // Configure system UI for consistent theming
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFFF8FCFF), // Ocean background
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  // Set preferred device orientations (mobile-first)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const EmoAidApp());
}

class EmoAidApp extends StatelessWidget {
  const EmoAidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MoodDataService(),
      child: MaterialApp(
        title: 'EmoAid - AI Mental Health Companion',
        
        // 🌊 CHANGE THIS LINE - Use Ocean Theme
        theme: AppTheme.lightTheme, // CHANGE FROM YOUR OLD THEME TO THIS
        
        // Routes for better navigation management
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/home': (context) => const HomeScreen(),
        },
        
        // Error handling
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaleFactor: MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2),
            ),
            child: child!,
          );
        },
        
        // Remove debug banner
        debugShowCheckedModeBanner: false,
        
        // App metadata for MSAI showcase
        onGenerateTitle: (context) => 'EmoAid - MSAI Project',
      ),
    );
  }
}
*/
// lib/main.dart - FIXED VERSION with your separate files
// lib/main.dart - CORRECTED VERSION with your actual MoodDataService
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'splash_screen.dart';
import 'home_screen.dart';
import 'mood_data_service.dart'; // Your actual service
// REMOVED: import 'theme/app_theme.dart'; // We'll create this or use built-in theme
// TEMPORARILY REMOVED Firebase until we test basic functionality
// import 'firebase_options.dart';
// import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // TEMPORARILY COMMENTED OUT Firebase initialization for testing
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  // Configure system UI for consistent theming
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFFF8FCFF), // Ocean background
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  // Set preferred device orientations (mobile-first)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const EmoAidApp());
}

class EmoAidApp extends StatelessWidget {
  const EmoAidApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MoodDataService()..initialize(), // FIXED: Initialize your actual service
      child: MaterialApp(
        title: 'EmoAid - AI Mental Health Companion',
        
        // FIXED: Use built-in ocean theme until we create AppTheme
        theme: ThemeData(
          primarySwatch: Colors.cyan,
          primaryColor: const Color(0xFF00BCD4),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF00BCD4),
            brightness: Brightness.light,
          ),
          scaffoldBackgroundColor: const Color(0xFFF8FCFF),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF00BCD4),
            foregroundColor: Colors.white,
            elevation: 0,
            systemOverlayStyle: SystemUiOverlayStyle.light,
          ),
          cardTheme: CardThemeData(
            elevation: 8,
            shadowColor: const Color(0xFF00BCD4).withOpacity(0.2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.white,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00BCD4),
              foregroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: const Color(0xFF00BCD4).withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF00BCD4), width: 2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
            ),
          ),
          textTheme: const TextTheme(
            headlineLarge: TextStyle(
              color: Color(0xFF1A365D),
              fontWeight: FontWeight.bold,
            ),
            headlineMedium: TextStyle(
              color: Color(0xFF1A365D),
              fontWeight: FontWeight.w600,
            ),
            bodyLarge: TextStyle(
              color: Color(0xFF2D3748),
            ),
            bodyMedium: TextStyle(
              color: Color(0xFF4A5568),
            ),
          ),
          useMaterial3: true,
        ),
        
        // Routes for better navigation management - KEEP YOUR ORIGINAL STRUCTURE
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/home': (context) => const HomeScreen(),
        },
        
        // Error handling
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(
                MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.2),
              ),
            ),
            child: child!,
          );
        },
        
        // Remove debug banner
        debugShowCheckedModeBanner: false,
        
        // App metadata for MSAI showcase
        onGenerateTitle: (context) => 'EmoAid - MSAI Project',
      ),
    );
  }
}

// SIMPLE AppTheme class to avoid import errors from mood_tracker_screen.dart
class AppTheme {
  // Primary Colors
  static const Color primaryCyan = Color(0xFF00BCD4);
  static const Color primaryCyanLight = Color(0xFF26C6DA);
  static const Color primaryCyanDark = Color(0xFF0097A7);
  
  // Secondary Colors
  static const Color secondaryCyan = Color(0xFF4DD0E1);
  static const Color accentCyan = Color(0xFF80DEEA);
  
  // Background Colors
  static const Color backgroundCyan = Color(0xFFF8FCFF);
  static const Color surfaceLight = Color(0xFFF0FDFF);
  static const Color cardWhite = Colors.white;
  
  // Text Colors
  static const Color textPrimary = Color(0xFF1A365D);
  static const Color textSecondary = Color(0xFF4A5568);
  static const Color textTertiary = Color(0xFF9CA3AF);
  
  // Status Colors
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color errorRed = Color(0xFFF44336);
  static const Color warningAmber = Color(0xFFFF9800);
  static const Color infoBlue = Color(0xFF2196F3);
  
  // Mood Colors
  static const Color moodExcellent = Color(0xFF4CAF50);
  static const Color moodGood = Color(0xFF8BC34A);
  static const Color moodNeutral = Color(0xFFFFEB3B);
  static const Color moodBad = Color(0xFFFF9800);
  static const Color moodTerrible = Color(0xFFF44336);
  
  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF4DD0E1),
      Color(0xFF26C6DA),
      Color(0xFF00BCD4),
    ],
  );
  
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF00BCD4),
      Color(0xFFF8FCFF),
    ],
  );
  
  // Shadows
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: primaryCyan.withOpacity(0.08),
      blurRadius: 32,
      offset: const Offset(0, 8),
      spreadRadius: 0,
    ),
  ];
  
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: primaryCyan.withOpacity(0.1),
      blurRadius: 10,
      offset: const Offset(0, 4),
    ),
  ];
  
  // Theme Data
  static ThemeData get lightTheme {
    return ThemeData(
      primarySwatch: Colors.cyan,
      primaryColor: primaryCyan,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryCyan,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: backgroundCyan,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryCyan,
        foregroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      cardTheme: CardThemeData(
        elevation: 8,
        shadowColor: primaryCyan.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        color: cardWhite,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryCyan,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryCyan.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryCyan, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: textPrimary,
        ),
        bodyMedium: TextStyle(
          color: textSecondary,
        ),
      ),
      useMaterial3: true,
    );
  }
}