import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mi_estudio/firebase/auth_firebase.dart';

class PayFirebase {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final user = AuthFirebase().getUser();

  // Referencia a la colección de materias del usuario
  CollectionReference get _collection => 
      _firestore.collection('miestudio').doc(user!.uid).collection('pay');

  // Agregar nuevo pago
  Future<void> addPay(Map<String, dynamic> subjectData) async {
    await _collection.add(subjectData);
  }

  Future<Map<String, dynamic>?> getLastPay() async {
    final query = await _collection.orderBy('createdAt', descending: true).limit(1).get();
    if (query.docs.isNotEmpty) {
      final data = query.docs.first.data() as Map<String, dynamic>;
      // Puedes revisar aquí si está activo
      final endDate = (data['endDate'] as Timestamp?)?.toDate();
      data['isActive'] = endDate != null && endDate.isAfter(DateTime.now());
      return data;
    }
    return null;
  }
}