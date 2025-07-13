// lib/theme/app_theme.dart - PROFESSIONAL OCEAN THEME SYSTEM
// lib/theme/app_theme.dart - PROFESSIONAL OCEAN THEME SYSTEM
// CREATE THIS FILE: lib/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // 🌊 OCEAN COLOR PALETTE - Mental Health Focused
  static const Color primaryCyan = Color(0xFF00BCD4);      // Main cyan
  static const Color primaryCyanLight = Color(0xFF26C6DA);  // Light cyan  
  static const Color primaryCyanDark = Color(0xFF0097A7);   // Dark cyan
  
  static const Color secondaryCyan = Color(0xFF4DD0E1);     // Very light cyan
  static const Color accentCyan = Color(0xFF80DEEA);        // Soft cyan
  static const Color backgroundCyan = Color(0xFFF8FCFF);    // Very light ocean blue
  
  // 🎨 SEMANTIC COLORS
  static const Color successGreen = Color(0xFF4CAF50);      // Calm green
  static const Color warningAmber = Color(0xFFFF9800);      // Warm amber
  static const Color errorRed = Color(0xFFE57373);          // Soft red (not harsh)
  static const Color infoBlue = Color(0xFF42A5F5);          // Information blue
  
  // 🏥 PROFESSIONAL COLORS
  static const Color cardWhite = Color(0xFFFFFFFF);         // Pure white cards
  static const Color surfaceLight = Color(0xFFF0FDFF);      // Very light cyan surface
  static const Color dividerGrey = Color(0xFFE0E0E0);       // Light dividers
  
  // 📝 TEXT COLORS
  static const Color textPrimary = Color(0xFF1A365D);       // Dark blue-grey
  static const Color textSecondary = Color(0xFF4A5568);     // Medium grey
  static const Color textTertiary = Color(0xFF718096);      // Light grey
  static const Color textOnPrimary = Color(0xFFFFFFFF);     // White on cyan
  
  // 💙 MOOD-SPECIFIC COLORS
  static const Color moodExcellent = Color(0xFF4CAF50);     // Green
  static const Color moodGood = Color(0xFF8BC34A);          // Light green
  static const Color moodNeutral = Color(0xFF00BCD4);       // Our cyan
  static const Color moodBad = Color(0xFFFF9800);           // Orange
  static const Color moodTerrible = Color(0xFFE57373);      // Soft red

  // 🎯 MAIN THEME DATA
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      
      // Color Scheme
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryCyan,
        brightness: Brightness.light,
        primary: primaryCyan,
        primaryContainer: secondaryCyan,
        secondary: primaryCyanLight,
        secondaryContainer: accentCyan,
        tertiary: infoBlue,
        surface: cardWhite,
        background: backgroundCyan,
        error: errorRed,
        onPrimary: textOnPrimary,
        onSecondary: textPrimary,
        onSurface: textPrimary,
        onBackground: textPrimary,
        onError: textOnPrimary,
        outline: dividerGrey,
        surfaceVariant: surfaceLight,
      ),
      
      // Scaffold Background
      scaffoldBackgroundColor: backgroundCyan,
      
      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: textOnPrimary),
        titleTextStyle: TextStyle(
          color: textOnPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.3,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          systemNavigationBarColor: backgroundCyan,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: cardWhite,
        elevation: 0,
        shadowColor: primaryCyan.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        margin: const EdgeInsets.all(8),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryCyan,
          foregroundColor: textOnPrimary,
          elevation: 0,
          shadowColor: primaryCyan.withOpacity(0.3),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryCyan,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Outlined Button Theme
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryCyan,
          side: const BorderSide(color: primaryCyan, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: dividerGrey, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: dividerGrey, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryCyan, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: errorRed, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        hintStyle: TextStyle(
          color: textTertiary,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: const TextStyle(
          color: textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      
      // Text Theme
      textTheme: const TextTheme(
        // Headlines
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.8,
          height: 1.2,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: textPrimary,
          letterSpacing: -0.5,
          height: 1.3,
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.3,
          height: 1.3,
        ),
        
        // Titles
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: -0.2,
          height: 1.4,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0,
          height: 1.4,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0.1,
          height: 1.4,
        ),
        
        // Body Text
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: textPrimary,
          letterSpacing: 0,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          letterSpacing: 0,
          height: 1.5,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: textTertiary,
          letterSpacing: 0.2,
          height: 1.4,
        ),
        
        // Labels
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0.5,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textSecondary,
          letterSpacing: 0.5,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: textTertiary,
          letterSpacing: 0.5,
        ),
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: textSecondary,
        size: 24,
      ),
      
      // Primary Icon Theme
      primaryIconTheme: const IconThemeData(
        color: textOnPrimary,
        size: 24,
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: dividerGrey,
        thickness: 1,
        space: 1,
      ),
      
      // Chip Theme
      chipTheme: ChipThemeData(
        backgroundColor: surfaceLight,
        selectedColor: primaryCyan,
        secondarySelectedColor: primaryCyanLight,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        secondaryLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textOnPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: dividerGrey, width: 1),
        ),
      ),
      
      // Floating Action Button Theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryCyan,
        foregroundColor: textOnPrimary,
        elevation: 8,
        shape: CircleBorder(),
      ),
      
      // Switch Theme
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryCyan;
          }
          return Colors.grey[300];
        }),
        trackColor: MaterialStateProperty.resolveWith((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryCyan.withOpacity(0.3);
          }
          return Colors.grey[200];
        }),
      ),
      
      // Slider Theme
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryCyan,
        inactiveTrackColor: primaryCyan.withOpacity(0.3),
        thumbColor: primaryCyan,
        overlayColor: primaryCyan.withOpacity(0.2),
        valueIndicatorColor: primaryCyan,
        valueIndicatorTextStyle: const TextStyle(
          color: textOnPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
      
      // Progress Indicator Theme
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primaryCyan,
        linearTrackColor: dividerGrey,
        circularTrackColor: dividerGrey,
      ),
      
      // Tab Bar Theme
      tabBarTheme: const TabBarThemeData(
        labelColor: primaryCyan,
        unselectedLabelColor: textTertiary,
        indicatorColor: primaryCyan,
        labelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
      
      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: cardWhite,
        selectedItemColor: primaryCyan,
        unselectedItemColor: textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
      
      // Snack Bar Theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textPrimary,
        contentTextStyle: const TextStyle(
          color: textOnPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        actionTextColor: primaryCyanLight,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),
      
      // Dialog Theme
      dialogTheme: DialogThemeData(
        backgroundColor: cardWhite,
        elevation: 24,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: textPrimary,
        ),
        contentTextStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: textSecondary,
          height: 1.5,
        ),
      ),
    );
  }

  // 🌙 DARK THEME (Optional - for future use)
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryCyan,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: const Color(0xFF0A1929),
    );
  }

  // 🎨 HELPER METHODS FOR CUSTOM COLORS
  
  /// Get mood color based on mood value (1-5)
  static Color getMoodColor(int mood) {
    switch (mood) {
      case 5:
        return moodExcellent;
      case 4:
        return moodGood;
      case 3:
        return moodNeutral;
      case 2:
        return moodBad;
      case 1:
        return moodTerrible;
      default:
        return moodNeutral;
    }
  }

  /// Get mood color with opacity
  static Color getMoodColorWithOpacity(int mood, double opacity) {
    return getMoodColor(mood).withOpacity(opacity);
  }

  /// Get gradient for mood
  static LinearGradient getMoodGradient(int mood) {
    final color = getMoodColor(mood);
    return LinearGradient(
      colors: [
        color,
        color.withOpacity(0.7),
      ],
    );
  }

  /// Primary gradient for headers and important sections
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      primaryCyanLight,
      primaryCyan,
      primaryCyanDark,
    ],
  );

  /// Soft background gradient
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      primaryCyan,
      primaryCyanLight,
    ],
    stops: [0.0, 0.3],
  );

  /// Card shadow
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: primaryCyan.withOpacity(0.08),
      blurRadius: 32,
      offset: const Offset(0, 8),
      spreadRadius: 0,
    ),
  ];

  /// Soft shadow for floating elements
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: primaryCyan.withOpacity(0.12),
      blurRadius: 24,
      offset: const Offset(0, 4),
      spreadRadius: 0,
    ),
  ];

  /// Heavy shadow for modal dialogs
  static List<BoxShadow> get heavyShadow => [
    BoxShadow(
      color: textPrimary.withOpacity(0.15),
      blurRadius: 40,
      offset: const Offset(0, 20),
      spreadRadius: 0,
    ),
  ];
}

// 🏥 MENTAL HEALTH SPECIFIC THEME EXTENSIONS
class MentalHealthTheme {
  
  /// Calming button style for wellness tools
  static ButtonStyle get calmingButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: AppTheme.primaryCyanLight,
    foregroundColor: AppTheme.textOnPrimary,
    elevation: 0,
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(30),
    ),
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.3,
    ),
  );

  /// Emergency button style for crisis situations
  static ButtonStyle get emergencyButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: AppTheme.errorRed,
    foregroundColor: AppTheme.textOnPrimary,
    elevation: 4,
    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.2,
    ),
  );

  /// Success button style for positive actions
  static ButtonStyle get successButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: AppTheme.successGreen,
    foregroundColor: AppTheme.textOnPrimary,
    elevation: 0,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    ),
    textStyle: const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
    ),
  );

  /// Mood card decoration
  static BoxDecoration moodCardDecoration(int mood) => BoxDecoration(
    color: AppTheme.getMoodColorWithOpacity(mood, 0.1),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: AppTheme.getMoodColorWithOpacity(mood, 0.3),
      width: 1.5,
    ),
    boxShadow: [
      BoxShadow(
        color: AppTheme.getMoodColorWithOpacity(mood, 0.15),
        blurRadius: 16,
        offset: const Offset(0, 4),
      ),
    ],
  );

  /// Professional badge decoration
  static BoxDecoration get professionalBadgeDecoration => BoxDecoration(
    color: AppTheme.surfaceLight,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: AppTheme.primaryCyan.withOpacity(0.2),
      width: 1,
    ),
  );
}