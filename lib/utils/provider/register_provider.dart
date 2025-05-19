import 'package:flutter/material.dart';

class RegisterProvider extends ChangeNotifier {
  String _password = '';
  bool _mostrarErrores = false;

  bool get mostrarErrores => _mostrarErrores;

  set password(String value) {
    _password = value;
    notifyListeners();
  }

  void setMostrarErrores(bool value) {
    _mostrarErrores = value;
    notifyListeners();
  }

  bool get esValida =>
    _password.length >= 8 &&
    _password.contains(RegExp(r'[A-Z]')) &&
    _password.contains(RegExp(r'[a-z]')) &&
    _password.contains(RegExp(r'\d')) &&
    _password.contains(RegExp(r'[!@#\$&*~.]'));

  Map<String, bool> get validaciones => {
    'Mínimo 8 caracteres': _password.length >= 8,
    'Una letra mayúscula': _password.contains(RegExp(r'[A-Z]')),
    'Una letra minúscula': _password.contains(RegExp(r'[a-z]')),
    'Un número': _password.contains(RegExp(r'\d')),
    'Un carácter especial (!@#\$&*~.)': _password.contains(RegExp(r'[!@#\$&*~.]')),
  };
}
