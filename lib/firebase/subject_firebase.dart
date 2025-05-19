import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mi_estudio/firebase/auth_firebase.dart';

class SubjectFirebase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final user = AuthFirebase().getUser();


  // Referencia a la colección de materias del usuario
  CollectionReference get _collection => 
      _firestore.collection('miestudio').doc(user!.uid).collection('subjects');

  // Agregar nueva materia
  Future<void> addSubject(Map<String, dynamic> subjectData) async {
    await _collection.add(subjectData);
  }

  // Actualizar materia
  Future<void> updateSubject(String docId, Map<String, dynamic> subjectData) async {
    await _collection.doc(docId).update(subjectData);
  }

  // Eliminar materia
  Future<void> deleteSubject(String docId) async {
    await _collection.doc(docId).delete();
  }

  // Obtener todas las materias del usuario (stream)
  Stream<QuerySnapshot> selectSubject() {
    return _collection.orderBy('createdAt', descending: true).snapshots();
  }
}