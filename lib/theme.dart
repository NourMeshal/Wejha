import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Dark Teal Gulf palette — every VK constant is the dark value so widgets
/// that reference VK.ink / VK.ink2 directly get the correct colour.
class VK {
  static const ink = Color(0xFFE5EEEB);         // primary text
  static const ink2 = Color(0xFF7A9E9B);        // secondary / muted text
  static const sea = Color(0xFF73BBC3);         // accent
  static const glass = Color(0xFF2E5F68);
  static const bg = Color(0xFF0B1C21);          // scaffold background
  static const card = Color(0xFF12282F);        // card / nav-rail surface
  static const surface2 = Color(0xFF1A3840);    // nav indicator / selected chip
  static const saffron = Color(0xFFD4A017);
  static const saffronBg = Color(0xFF2E2208);
  static const line = Color(0xFF1E3D47);
  static const danger = Color(0xFFCF6679);
  static const ok = Color(0xFF52C99A);
}

ThemeData buildTheme() {
  const primary = VK.sea;
  const onPrimary = VK.bg;
  const surface = VK.card;
  const onSurface = VK.ink;

  final scheme = ColorScheme.fromSeed(
    seedColor: primary,
    brightness: Brightness.dark,
    primary: primary,
    onPrimary: onPrimary,
    surface: surface,
    onSurface: onSurface,
    error: VK.danger,
  );
  // Cairo covers both Latin and Arabic, so one font for both languages.
  final text = GoogleFonts.cairoTextTheme()
      .apply(bodyColor: VK.ink, displayColor: VK.ink);
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: VK.bg,
    textTheme: text.copyWith(
      headlineLarge:  text.headlineLarge?.copyWith(fontWeight: FontWeight.w700, height: 1.2),
      headlineMedium: text.headlineMedium?.copyWith(fontWeight: FontWeight.w700, height: 1.25),
      titleLarge:  text.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      titleMedium: text.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      bodyLarge:   text.bodyLarge?.copyWith(fontSize: 17, height: 1.5),
      bodyMedium:  text.bodyMedium?.copyWith(fontSize: 15, height: 1.5),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: VK.bg,
      foregroundColor: VK.ink,
      elevation: 0,
      scrolledUnderElevation: 0,
    ),
    cardTheme: CardThemeData(
      color: VK.card,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        minimumSize: const Size(64, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 16),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(64, 50),
        foregroundColor: VK.ink,
        side: const BorderSide(color: VK.line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: GoogleFonts.cairo(fontWeight: FontWeight.w700, fontSize: 16),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: VK.card,
      selectedColor: VK.sea,
      labelStyle: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w600, color: VK.ink2),
      secondaryLabelStyle: GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w600, color: VK.bg),
      side: const BorderSide(color: VK.line),
      shape: const StadiumBorder(),
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: VK.card,
      indicatorColor: Colors.transparent,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return const IconThemeData(color: VK.sea);
        return const IconThemeData(color: VK.ink2);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600, color: VK.sea);
        }
        return GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600, color: VK.ink2);
      }),
    ),
    navigationRailTheme: NavigationRailThemeData(
      backgroundColor: VK.card,
      indicatorColor: VK.surface2,
      selectedIconTheme: const IconThemeData(color: VK.sea),
      unselectedIconTheme: const IconThemeData(color: VK.ink2),
      selectedLabelTextStyle:
          GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600, color: VK.sea),
      unselectedLabelTextStyle:
          GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600, color: VK.ink2),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: VK.card,
      hintStyle: const TextStyle(color: VK.ink2),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: VK.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: VK.line),
      ),
    ),
  );
}
