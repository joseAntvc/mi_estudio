import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

class CustomToast {
  static ToastificationType _getType(String type) {
    switch (type) {
      case "e":
        return ToastificationType.error;
      case "w":
        return ToastificationType.warning;
      case "i":
        return ToastificationType.info;
      default:
        return ToastificationType.success;
    }
  }
  //Muestra el mensaje de toast personalizado
  static void show(BuildContext context, String message, {String? descrip, String type = "success", bool disa = true}) {
    toastification.show(
      context: context,
      type: _getType(type),
      style: ToastificationStyle.minimal,
      title: Text(message),
      description: descrip != null ? Text(descrip) : null,
      alignment: Alignment.topLeft,
      animationDuration: const Duration(milliseconds: 300),
      autoCloseDuration: const Duration(seconds: 3),
      borderRadius: BorderRadius.circular(12),
      showProgressBar: true, 
      // ignore: deprecated_member_use
      closeButtonShowType: disa ? null : CloseButtonShowType.none,
      dragToClose: disa, // Puede lanzar a un lado el toast al soltarlo
      pauseOnHover: disa, // Pausa el toast cuando el usuario se encuentra encima
    );
  }
}