// Función para oscurecer colores (para texto/íconos)
import 'package:flutter/material.dart';

Color darken(Color color, [double amount = 0.3]) {
  final hsl = HSLColor.fromColor(color);
  final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
  return hslDark.toColor();
}