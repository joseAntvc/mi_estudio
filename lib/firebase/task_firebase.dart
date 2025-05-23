import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mi_estudio/firebase/auth_firebase.dart';

class TaskFirebase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final user = AuthFirebase().getUser();


  // Referencia a la colección de materias del usuario
  CollectionReference get _collection => 
      _firestore.collection('miestudio').doc(user!.uid).collection('task');

  // Agregar nueva tarea, examen...
  Future<void> addTask(Map<String, dynamic> taskData) async {
    await _collection.add(taskData);
  }

  // Actualizar 
  Future<void> updateTask(String docId, Map<String, dynamic> taskData) async {
    await _collection.doc(docId).update(taskData);
  }

  // Eliminar 
  Future<void> deleteTask(String docId) async {
    await _collection.doc(docId).delete();
  }

  // Obtener toda las tareas del usuario (stream)
  Stream<QuerySnapshot> selectTask() {
    return _collection.orderBy('createdAt', descending: true).snapshots();
  }

  Future<void> clearSubjectFromTask(String subjectId) async{
    final notes = await _collection.where('subjectId', isEqualTo: subjectId).get();
    for(final doc in notes.docs){
      await doc.reference.update({'subjectId': null});
    }
  }
}