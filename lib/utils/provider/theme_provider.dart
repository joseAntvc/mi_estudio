import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AppTheme { system, light, dark, blue }

class ThemeProvider extends ChangeNotifier {
  AppTheme _appTheme = AppTheme.system; 
  String _font = 'Roboto';

  AppTheme get appTheme => _appTheme;
  String get font => _font;

  void setAppTheme(AppTheme theme) {
    _appTheme = theme;
    saveTheme(theme.name);
    notifyListeners();
  }

  void setFont(String font) {
    _font = font;
    saveFont(font);
    notifyListeners();
  }

  ThemeMode get themeMode {
    switch (_appTheme) {
      case AppTheme.light:
        return ThemeMode.light;
      case AppTheme.dark:
        return ThemeMode.dark;
      case AppTheme.system:
        return ThemeMode.system; 
      default:
        return ThemeMode.light;
    }
  }

  // Saber si el tema es personalizado
  bool get isCustomTheme {
    return ![AppTheme.system, AppTheme.dark].contains(_appTheme);
  }


  //Funcion para guardar el tema
  Future<void> saveTheme(String themeName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeName', themeName);
  }

  //Funcion para guardar el tema de fuente
  Future<void> saveFont(String themeFont) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('themeFont', themeFont);
  }

  //Funcion para cargar el tema
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeName = prefs.getString('themeName') ?? 'system';
      _appTheme = AppTheme.values.firstWhere(
      (e) => e.name == themeName,
      orElse: () => AppTheme.system,
    );
    _font = prefs.getString('themeFont') ?? 'Roboto';
    notifyListeners();
  }
}