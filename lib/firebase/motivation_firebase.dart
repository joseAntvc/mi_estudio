import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mi_estudio/firebase/auth_firebase.dart';

class MotivationFirebase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final user = AuthFirebase().getUser();

  // Referencia a la colección de motivaciones del usuario
  CollectionReference get _collection => 
      _firestore.collection('miestudio').doc(user!.uid).collection('motivation');

  // Agregar nueva motivación
  Future<void> addMotivation(Map<String, dynamic> motivationData) async {
    await _collection.add(motivationData);
  }

  // Actualizar motivacion
  Future<void> updateMotivation(String docId, Map<String, dynamic> motivationData) async {
    await _collection.doc(docId).update(motivationData);
  }

  // Eliminar motivacion
  Future<void> deleteMotivation(String docId) async {
    await _collection.doc(docId).delete();
  }

  // Obtener todas del usuario (stream)
  Stream<QuerySnapshot> selectMotivation() {
    return _collection.orderBy('createdAt', descending: true).snapshots();
  }

  Future<String?> getGlobalMotivationOfDay() async {
    final today = DateTime.now();
    final formattedDate = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";
    final frase = await _firestore
        .collection('miestudio').doc('motivation')
        .collection(formattedDate).limit(1).get();
    if (frase.docs.isNotEmpty) {
      return frase.docs.first['frase'];
    } else {
      return null;
    }
  }
}