import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mi_estudio/firebase/subject_firebase.dart';

class SubjectFromProvider extends ChangeNotifier {
  final TextEditingController conName = TextEditingController();
  Color _color = const Color(0xFFE0BBE4); // color predeterminado
  IconData _icono = Icons.school;
  String? _docId;

  bool isDelete = false;

  Color get getColor => _color;
  IconData get getIcono => _icono;
  String? get getDocId => _docId;


  void loadExistingData(Map<String, dynamic> data) {
    conName.text = data['nombre'];
    _color = Color(data['color']);
    _icono = IconData(data['icono'], fontFamily: 'MaterialIcons');
    _docId = data['docId'];
    notifyListeners();
  }

  void setIsDelete(bool value){
    isDelete = value;
    notifyListeners();
  }

  void setNombre(String value) {
    conName.text = value;
    notifyListeners();
  }

  void setColor(Color value) {
    _color = value;
    notifyListeners();
  }

  void setIcono(IconData value) {
    _icono = value;
    notifyListeners();
  }

  bool isValid() {
    return conName.text.isNotEmpty;
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre': conName.text.trim(),
      // ignore: deprecated_member_use
      'color': _color.value,
      'icono': _icono.codePoint,
      if(_docId == null) 'createdAt': FieldValue.serverTimestamp(),
    };
  }

  Future<void> saveSubject() async {
    SubjectFirebase subjectService = SubjectFirebase();
    if(_docId != null) {
      await subjectService.updateSubject(_docId!, toMap());
    } else {
      await subjectService.addSubject(toMap());
    }
    clear();
  }

  void clear() {
    conName.text = '';
    _color = const Color(0xFFE0BBE4);
    _icono = Icons.school;
    _docId = null;
    notifyListeners();
  }
}
