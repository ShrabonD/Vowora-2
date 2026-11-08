import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class VoworaColors {
  // Brand Primary Palette & Luxury Design System
  static const Color darkBackground = Color(0xFF101014); // Deep Midnight Black
  static const Color darkCardBackground = Color(0xFF1C1B20); // Rich Charcoal
  static const Color champagneGold = Color(0xFFD8B65C); // Champagne Gold
  static const Color softIvory = Color(0xFFF7F2E9); // Soft Ivory
  static const Color mutedRoseGold = Color(0xFFC99585); // Muted Rose Gold
  static const Color textPrimary = Color(0xFFFAF8F4); // Warm White
  static const Color textSecondary = Color(0xFFB7B3B0); // Soft Gray

  static const Color lightGold = Color(0xFFE5C158);
  static const Color deepGold = Color(0xFFB38F24);
  static const Color deepForestGreen = Color(0xFF1C352D);
  static const Color dustyRose = Color(0xFFD8A7B1);
  static const Color mutedMauve = Color(0xFFB87D93);
  static const Color warmBeige = Color(0xFFF7F2E9);
  static const Color ivoryCream = Color(0xFFFFFDF9);
  static const Color softBeige = Color(0xFFF9F6F0);
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color darkGlassBackground = Color(0xCC1C1B20);
  static const Color darkGlassBorder = Color(0x33D8B65C);
  static const Color textLight = Color(0xFFFAF8F4);
  static const Color textLightMuted = Color(0xB3FAF8F4);

  // Functional Status
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFE53935);
}

class VoworaTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: VoworaColors.champagneGold,
        secondary: VoworaColors.dustyRose,
        surface: VoworaColors.darkCardBackground,
        error: VoworaColors.error,
        onPrimary: Colors.black,
        onSecondary: Colors.white,
        onSurface: Colors.white,
      ),
      scaffoldBackgroundColor: VoworaColors.darkBackground,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: GoogleFonts.playfairDisplay(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF181513),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: BorderSide(color: VoworaColors.champagneGold.withValues(alpha: 0.3)),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Color(0xFF181513),
        modalBackgroundColor: Color(0xFF181513),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      cardTheme: CardThemeData(
        color: const Color(0xFF1C1917),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.08),
        hintStyle: GoogleFonts.plusJakartaSans(
          color: Colors.white38,
          fontSize: 14,
        ),
        labelStyle: GoogleFonts.plusJakartaSans(
          color: Colors.white70,
          fontSize: 13,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: VoworaColors.champagneGold, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(color: VoworaColors.error, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: VoworaColors.champagneGold,
          foregroundColor: const Color(0xFF141210),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.3,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.white12,
        disabledColor: Colors.grey.shade800,
        selectedColor: VoworaColors.champagneGold,
        secondarySelectedColor: VoworaColors.champagneGold,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        labelStyle: GoogleFonts.plusJakartaSans(color: Colors.white, fontSize: 12),
        secondaryLabelStyle: GoogleFonts.plusJakartaSans(color: const Color(0xFF141210), fontSize: 12, fontWeight: FontWeight.bold),
        elevation: 0,
        pressElevation: 0,
        showCheckmark: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
        ),
      ),
    );
  }
}
