import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Cores semente turquesa #0FA3A3 para o Material 3.
/// Tokens de status usados em todo o app.
class AppColors {
  // Tokens de classificação da glicemia
  static const Color criticaBaixaGrave = Color(0xFFD32F2F); // vermelho - icone warning
  static const Color baixa = Color(0xFF1E88E5); // azul - icone arrow_downward
  static const Color naMeta = Color(0xFF2E9E5B); // verde - icone check_circle
  static const Color acimaMeta = Color(0xFFF9A825); // amarelo - icone arrow_upward
  static const Color altaOCriticaAlta = Color(0xFFEF6C00); // laranja
  static const Color alta = Color(0xFFD32F2F); // vermelho intenso

  // Cores de fundo / superficies
  static const Color surfaceDefault = Color(0xFFF5F5F5);
  static const Color surfaceDark = Color(0xFF121212);
}

/// Tipografia base: Nunito (corpo) e Poppins (títulos), 16sp base, acessível para idosos.
final TextTheme textTheme = TextTheme(
  displayLarge: TextStyle(
    fontFamily: 'Nunito',
    fontSize: 57,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  ),
  displayMedium: TextStyle(
    fontFamily: 'Nunito',
    fontSize: 45,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  ),
  displaySmall: TextStyle(
    fontFamily: 'Nunito',
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  ),
  headlineLarge: TextStyle(
    fontFamily: 'Poppins',
    fontSize: 32,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  ),
  headlineMedium: TextStyle(
    fontFamily: 'Poppins',
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  ),
  headlineSmall: TextStyle(
    fontFamily: 'Poppins',
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  ),
  titleLarge: TextStyle(
    fontFamily: 'Poppins',
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: Colors.black87,
  ),
  titleMedium: TextStyle(
    fontFamily: 'Poppins',
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.black87,
  ),
  titleSmall: TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: Colors.black87,
  ),
  bodyLarge: TextStyle(
    fontFamily: 'Nunito',
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: Colors.black87,
    height: 1.5,
  ),
  bodyMedium: TextStyle(
    fontFamily: 'Nunito',
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: Colors.black87,
    height: 1.4,
  ),
  bodySmall: TextStyle(
    fontFamily: 'Nunito',
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: Colors.black54,
    height: 1.3,
  ),
  labelLarge: TextStyle(
    fontFamily: 'Poppins',
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  ),
  labelMedium: TextStyle(
    fontFamily: 'Poppins',
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  ),
  labelSmall: TextStyle(
    fontFamily: 'Poppins',
    fontSize: 10,
    fontWeight: FontWeight.bold,
    color: Colors.white70,
  ),
);

/// ColorScheme semente a partir de #0FA3A3, com paleta expandida para status.
final ColorScheme appColorScheme = ColorScheme.fromSeed(
  seedColor: const Color(0xFF0FA3A3),
  brightness: Brightness.light,
  primary: const Color(0xFF0FA3A3),
  secondary: const Color(0xFF673AB7), // roxo complementar
  tertiary: const Color(0xFF008374),
  error: const Color(0xFFB00020),
  surface: AppColors.surfaceDefault,
  onSurface: Colors.black87,
  onPrimary: Colors.white,
  onSecondary: Colors.white,
  onTertiary: Colors.white,
  onError: Colors.white,
  outline: Colors.grey[300]!,
);

/// Tema claro completo.
final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  colorScheme: appColorScheme,
  textTheme: textTheme,
  scaffoldBackgroundColor: AppColors.surfaceDefault,
  cardTheme: CardTheme(
    color: Colors.white,
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
  ),
  iconTheme: const IconThemeData(color: Colors.black87),
  dividerTheme: const DividerThemeData(color: Color(0xFFE0E0E0), space: 8),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      minimumSize: const Size(double.infinity, 56),
      textStyle: const TextStyle(fontSize: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      minimumSize: const Size(double.infinity, 56),
      textStyle: const TextStyle(fontSize: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),
  appBarTheme: const AppBarTheme(
    titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    backgroundColor: Colors.white,
    foregroundColor: Colors.black87,
    elevation: 0,
  ),
  cardTheme: CardTheme(
    color: Colors.white,
    elevation: 2,
    margin: const EdgeInsets.all(8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
  ),
);

/// Tema escuro completo.
final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  colorScheme: appColorScheme.copyWith(brightness: Brightness.dark),
  textTheme: textTheme.copyWith(
    bodyLarge: TextStyle(
      fontFamily: 'Nunito',
      fontSize: 16,
      color: Colors.white70,
      height: 1.5,
    ),
  ),
  scaffoldBackgroundColor: AppColors.surfaceDark,
  cardTheme: CardTheme(
    color: Color(0xFF1E1E1E),
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
  ),
  iconTheme: const IconThemeData(color: Colors.white70),
  dividerTheme: const DividerThemeData(color: Color(0xFF333333), space: 8),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      minimumSize: const Size(double.infinity, 56),
      textStyle: const TextStyle(fontSize: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      minimumSize: const Size(double.infinity, 56),
      textStyle: const TextStyle(fontSize: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),
  appBarTheme: const AppBarTheme(
    titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    backgroundColor: Colors.white,
    foregroundColor: Colors.black87,
    elevation: 0,
  ),
  cardTheme: CardTheme(
    color: Colors.white,
    elevation: 2,
    margin: const EdgeInsets.all(8),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
  ),
);