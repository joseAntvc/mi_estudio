import 'package:flutter/material.dart';

class Themes {
  // Tema claro
  static ThemeData lightTheme() {
    const primaryColor = Color(0xFF2E7D32);
    const secondaryColor = Color(0xFF66BB6A); 
    return ThemeData.light().copyWith(
      scaffoldBackgroundColor: Colors.white,
      primaryColor: primaryColor,
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
      ),
      dividerTheme: DividerThemeData(
        color: Colors.grey
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.bold, color: primaryColor),
        displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.bold, color: Colors.black),
        displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: primaryColor),
        headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
        headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
        headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.black),
        titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black54),
        titleSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: primaryColor),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black54),
        bodyMedium: TextStyle(fontSize: 14, color: Colors.black54),
        bodySmall: TextStyle(fontSize: 12, color: Colors.black45),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primaryColor),
        labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryColor),
        labelSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.grey[600]),
        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
      cardTheme: CardTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey[400]!, width: 1),
        ),
      ),
    );
  }


  // Tema oscuro
  static ThemeData darkTheme() {
    const primaryColor = Color(0xFF66BB6A);      
    const secondaryColor = Color(0xFF81C784);    
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: Color(0xFF121212),
      primaryColor: primaryColor,
      colorScheme: ColorScheme.dark(
        primary: primaryColor,
        secondary: secondaryColor,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.bold, color: primaryColor),
        displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.bold, color: Colors.white),
        displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: primaryColor),
        headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
        headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
        headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
        titleSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: primaryColor),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
        bodyMedium: TextStyle(fontSize: 14, color: Colors.white70),
        bodySmall: TextStyle(fontSize: 12, color: Colors.white60),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primaryColor),
        labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryColor),
        labelSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.grey[400]),
        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
      cardTheme: CardTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.white, width: 1),
        ),
      ),
    );
  }

  static ThemeData blueTheme() {
    const primaryColor = Color(0xFF1565C0); // Azul fuerte
    const secondaryColor = Color(0xFF42A5F5); // Azul claro

    return ThemeData.light().copyWith(
      scaffoldBackgroundColor: Colors.lightBlue[50],
      primaryColor: primaryColor,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.lightBlue[50],
      ),
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
      ),
      dividerTheme: DividerThemeData(
        color: Colors.blueGrey[200],
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 57, fontWeight: FontWeight.bold, color: primaryColor),
        displayMedium: TextStyle(fontSize: 45, fontWeight: FontWeight.bold, color: Colors.black),
        displaySmall: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: primaryColor),
        headlineLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black),
        headlineMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.black),
        headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
        titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.black),
        titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black54),
        titleSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: primaryColor),
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black54),
        bodyMedium: TextStyle(fontSize: 14, color: Colors.black54),
        bodySmall: TextStyle(fontSize: 12, color: Colors.black45),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primaryColor),
        labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryColor),
        labelSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.grey[600]),
        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.red, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
      cardTheme: CardTheme(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.blueGrey[100]!, width: 1),
        ),
      ),
    );
  }
}