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
    return _userNotes.orderBy('createdAt', descending: true).snapshots();
  }

  // Eliminar nota
  Future<void> deleteNote(String noteId) async {
    await _storage.deleteNoteFiles(
      userId: _auth.currentUser!.uid,
      noteId: noteId,
    );
    // Eliminar la nota de Firestore
    await _userNotes.doc(noteId).delete();
  }

  // Actualizar nota
  Future<void> updateNote(
    String noteId,
    Map<String, dynamic> noteData, {
    List<PlatformFile>? files,
    List<String>? existingFileUrls,
  }) async {
    final List<String> newUrls = [];
    // Si hay archivos nuevos, súbelos y actualiza las URLs
    if (files != null && files.isNotEmpty) {
      final urls = await _storage.uploadNoteFiles(
        userId: _auth.currentUser!.uid,
        noteId: noteId,
        files: files,
      );
      newUrls.addAll(urls);
    }
    final allUrls = [ //Son todos los archivos
      if (existingFileUrls != null) ...existingFileUrls,
      ...newUrls,
    ];
    noteData['fileUrls'] = allUrls;
    noteData['hasAttachments'] = allUrls.isNotEmpty;
    final String folderPath = "${_auth.currentUser!.uid}/notes/$noteId";
    final filesInStorage = await _storage.supabase.storage.from('miestudio').list(path: folderPath);
    final filesToDelete = filesInStorage //Compara lo que son los archivos asignados con los cargados para borrarlos
        .where((f) => !allUrls.any((url) => url.contains(f.name)))
        .map((f) => '$folderPath/${f.name}')
        .toList();
    if (filesToDelete.isNotEmpty) {
      await _storage.supabase.storage.from('miestudio').remove(filesToDelete);
    }
    await _userNotes.doc(noteId).update(noteData);
  }

  Stream<DocumentSnapshot> getNoteById(String noteId) {
    return _userNotes.doc(noteId).snapshots();
  }

  Future<void> clearSubjectFromNotes(String subjectId) async{
    final notes = await _userNotes.where('subjectId', isEqualTo: subjectId).get();
    for(final doc in notes.docs){
      await doc.reference.update({'subjectId': null});
    }
  }
}