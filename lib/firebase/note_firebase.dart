import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:file_picker/file_picker.dart';
import 'package:mi_estudio/supabase/storage_services.dart';

class NoteFirebase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final StorageServices _storage = StorageServices();

  // Referencia a las notas del usuario
  CollectionReference get _userNotes => 
      _firestore.collection('miestudio').doc(_auth.currentUser?.uid).collection('notes');

  // Referencia a las materias del usuario
  CollectionReference get _userSubjects => 
      _firestore.collection('miestudio').doc(_auth.currentUser?.uid).collection('subjects');

  // Guardar nueva nota con archivos en Supabase
  Future<void> addNote(
    Map<String, dynamic> noteData, {
    List<PlatformFile>? files,
  }) async {
    final noteRef = await _userNotes.add(noteData);
    if (files != null && files.isNotEmpty) {
      final urls = await _storage.uploadNoteFiles(
        userId: _auth.currentUser!.uid,
        noteId: noteRef.id,
        files: files,
      );
      // Actualizar nota con las URLs de los archivos
      await noteRef.update({
        'fileUrls': urls,
        'hasAttachments': true,
      });
    }
  }

  // Obtener notas del usuario
  Stream<QuerySnapshot> selectNotes() {
    print(_userNotes.orderBy('createdAt', descending: true).snapshots());
    return _userNotes.orderBy('createdAt', descending: true).snapshots();
  }

  // Eliminar nota
  Future<void> deleteNote(String noteId, {List<String>? fileUrls}) async {
    // Eliminar archivos en Supabase si hay URLs
    if (fileUrls != null && fileUrls.isNotEmpty) {
      await _storage.deleteNoteFiles(
        userId: _auth.currentUser!.uid,
        noteId: noteId,
      );
    }
    // Eliminar la nota de Firestore
    await _userNotes.doc(noteId).delete();
  }

  // Actualizar nota (puedes actualizar archivos si lo necesitas)
  Future<void> updateNote(
    String noteId,
    Map<String, dynamic> noteData, {
    List<PlatformFile>? files,
  }) async {
    // Si hay archivos nuevos, súbelos y actualiza las URLs
    if (files != null && files.isNotEmpty) {
      await _storage.deleteNoteFiles(
        userId: _auth.currentUser!.uid,
        noteId: noteId,
      );
      if (files.isNotEmpty) {
        final urls = await _storage.uploadNoteFiles(
          userId: _auth.currentUser!.uid,
          noteId: noteId,
          files: files,
        );
        noteData['fileUrls'] = urls;
        noteData['hasAttachments'] = true;
      } else {
        noteData['fileUrls'] = [];
        noteData['hasAttachments'] = false;
      }
    }
    await _userNotes.doc(noteId).update(noteData);
  }

  // Obtener materias del usuario
  Stream<QuerySnapshot> getSubjectsStream() {
    return _userSubjects.orderBy('nombre').snapshots();
  }
}