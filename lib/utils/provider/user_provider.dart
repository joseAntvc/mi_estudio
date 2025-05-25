// profile_provider.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mi_estudio/firebase/auth_firebase.dart';
import 'package:mi_estudio/supabase/storage_services.dart';

class UserProvider extends ChangeNotifier {
  late User _user;
  File? _photo;
  bool _editandoNombre = false;
  late bool _isEmailUser;
  final TextEditingController conNombre = TextEditingController();

  UserProvider() {
    _user = AuthFirebase().getUser()!;
    conNombre.text = _user.displayName ?? '';
    _isEmailUser = _user.providerData[0].providerId == "password";
  }

  User get user => _user;
  File? get photo => _photo;
  bool get editandoNombre => _editandoNombre;
  bool get isEmailUser => _isEmailUser;

  void toggleDesNombre(){
    _editandoNombre = false;
    notifyListeners();
  }

  void toggleEditarNombre() {
    _editandoNombre = !_editandoNombre;
    notifyListeners();
  }

  void clearInfo(){
    _editandoNombre = false;
    conNombre.text = _user.displayName ?? '';
    _photo = null;
    notifyListeners();
  }

  Future<void> pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source);
    if (picked != null) {
      _photo = File(picked.path);
      notifyListeners();
    }
  }

  Future<void> guardarCambios() async {
    String? nuevaFotoUrl;
    if (_photo != null) {
      nuevaFotoUrl = await StorageServices().updoadFile(_photo!, _user.uid);
      if (nuevaFotoUrl != null) {
        await _user.updatePhotoURL(nuevaFotoUrl);
      }
    }
    if (conNombre.text != _user.displayName || conNombre.text.isNotEmpty) {
      await _user.updateDisplayName(conNombre.text.trim());
    }
    await _user.reload();
    _user = AuthFirebase().getUser()!;
    _editandoNombre = false;
    _photo = null;
    notifyListeners();
  }

  Future<void> refreshUser() async {
    _user = AuthFirebase().getUser()!;
    conNombre.text = _user.displayName ?? '';
    _isEmailUser = _user.providerData[0].providerId == "password";
    _photo = null;
    _editandoNombre = false;
    notifyListeners();
  }
}
