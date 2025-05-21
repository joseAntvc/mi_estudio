import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class NoteFormProvider extends ChangeNotifier {
  String _title = '';
  String _content = '';
  String? _subjectId;
  final List<PlatformFile> _attachments = [];
  bool _isLoading = false;
  String? _docId;
  List<String> _existingFileUrls = [];
  
  String? _selectedSubjectId;

  String? get selectedSubjectId => _selectedSubjectId;
  List<String> get existingFileUrls => _existingFileUrls;

  String get title => _title;
  String get content => _content;
  String? get subjectId => _subjectId;
  List<PlatformFile> get attachments => _attachments;
  bool get isLoading => _isLoading;
  String? get getDocId => _docId;

  void loadExistingData(Map<String, dynamic> data) {
    _title = data['title'] ?? '';
    _content = data['content'] ?? '';
    _subjectId = data['subjectId'];
    _docId = data['docId'];
    _existingFileUrls = List<String>.from(data['fileUrls'] ?? []);
    notifyListeners();
  }

  void setTitle(String value) {
    _title = value;
    notifyListeners();
  }

  void setContent(String value) {
    _content = value;
    notifyListeners();
  }

  void setSubject(String? value) {
    _subjectId = value;
    notifyListeners();
  }

  void addAttachment(PlatformFile file) {
    _attachments.add(file);
    notifyListeners();
  }

  void removeAttachment(int index) {
    _attachments.removeAt(index);
    notifyListeners();
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setSubjectId(String? value) {
    _selectedSubjectId = value;
    notifyListeners();
  }

  void removeExistingFile(int index) {
    _existingFileUrls.removeAt(index);
    notifyListeners();
  }

  Map<String, dynamic> toMap() {
    return {
      'title': _title,
      'content': _content,
      'subjectId': _subjectId,
      if(_docId == null) 'createdAt': FieldValue.serverTimestamp(),
      'hasAttachments': false,
    };
  }

  void clear() {
    _title = '';
    _content = '';
    _subjectId = null;
    _attachments.clear();
    _docId = null;
    _existingFileUrls.clear();
    notifyListeners();
  }
}