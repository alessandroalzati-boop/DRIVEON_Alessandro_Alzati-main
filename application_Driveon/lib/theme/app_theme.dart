import 'package:flutter/material.dart';

class AppTheme {
  static const Color background = Color(0xFF090B0C);
  static const Color surface = Color(0xFF141719);
  static const Color primary = Color(0xFFD5FC51);
  static const Color textprimary = Color(0xFFF5F6F2);
static const Color textsecondary = Color(0xFF969E9F);
static const Color border = Color(0xFF2A3033);

  static ThemeData get darkTheme{
    TextTheme baseTextTheme = ThemeData.dark().textTheme;
    return ThemeData(
      brightness: Brightness.dark, // tells Flutter this is a dark mode app
      scaffoldBackgroundColor: background,
      primaryColor: primary,

      colorScheme: const ColorScheme.dark(
        primary: primary,
        surface: surface,
        onPrimary: Colors.black,
         onSurface: textprimary,
         ),

         textTheme: baseTextTheme.copyWith(
          displayLarge:baseTextTheme.displayLarge?.copyWith(
            fontSize:32,
            fontWeight:FontWeight.bold,
            color:textprimary,
            height:1.2,

          ),
           titleMedium: baseTextTheme.titleMedium?.copyWith(
           color: textprimary,
           fontWeight: FontWeight.w600,
          ),
           bodyMedium: baseTextTheme.bodyMedium?.copyWith(
           color: textsecondary,
          ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: const TextStyle(color: textsecondary),
        labelStyle: const TextStyle(color: textprimary),
        floatingLabelStyle: const TextStyle(color: primary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16,vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary,width: 1.5),
        ),
      ),
     
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: textprimary),
        titleTextStyle: TextStyle(
          color: textprimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 16,horizontal: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(
            fontWeight:FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),

      cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
      side: const BorderSide(color: border),
    ),  
    ),

     textSelectionTheme:const TextSelectionThemeData(
      cursorColor: primary,
      selectionColor: primary,
      selectionHandleColor: primary,
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: surface,
      selectedItemColor: primary,
      unselectedItemColor: textsecondary,
      type: BottomNavigationBarType.fixed,
    ),
    );
  
  }
}