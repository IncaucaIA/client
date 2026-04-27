import 'package:flutter/material.dart';
import 'package:incauca_labs/core/colors.dart'; 
final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  fontFamily: 'Poppins',
  colorScheme: ColorScheme.light(
    primary: AppColors.primary,       // Azul Incauca (Elementos principales)
    onPrimary: Colors.white,          // Texto sobre azul
    
    secondary: AppColors.secondary,   // Verde Caña (Botones de acción secundaria, FABs, Switches)
    onSecondary: Colors.white,        // Texto sobre verde
    
    tertiary: AppColors.accent,       // Amarillo Energía (Detalles menores)
    
    surface: AppColors.background,    // Fondo de tarjetas/hojas
    onSurface: AppColors.dark,        // Texto principal sobre fondos claros
    
    error: Colors.red.shade700,
    onError: Colors.white,
    
    background: AppColors.background, 
  ),

  // 2. FONDO GENERAL
  scaffoldBackgroundColor: AppColors.background,

  // 3. BARRA DE NAVEGACIÓN (HEADER)
  // En la web es blanca, pero en apps móviles corporativas el azul da más presencia.
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    elevation: 0,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontFamily: 'Poppins',
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
    iconTheme: IconThemeData(color: Colors.white),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 2,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4), // Bordes poco redondeados como en la web
      ),
      textStyle: const TextStyle(
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w700, // Bold
        fontSize: 16,
        letterSpacing: 1.0, // Un poco de espaciado para simular mayúsculas sostenidas
      ),
    ),
  ),

  // 5. INPUTS (FORMULARIOS)
  // Estilo limpio y corporativo para "Incauca Labs"
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFFE0E0E0)), // Gris suave
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: AppColors.primary, width: 2), // Azul al enfocar
    ),
    labelStyle: TextStyle(color: AppColors.dark.withOpacity(0.6)),
    prefixIconColor: AppColors.primary,
  ),

  // 6. TEXTOS
  textTheme: const TextTheme(
    displayLarge: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
    displayMedium: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
    bodyLarge: TextStyle(color: AppColors.dark),
    bodyMedium: TextStyle(color: AppColors.dark),
  ),

  // 7. OTROS COMPONENTES
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: AppColors.dark, // Oscuro para contraste
    contentTextStyle: TextStyle(color: Colors.white),
    actionTextColor: AppColors.accent, // Amarillo para la acción del snackbar
    behavior: SnackBarBehavior.floating,
  ),
  
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.secondary, // Verde para acciones flotantes (muy visible)
    foregroundColor: Colors.white,
  ),
);