import 'package:flutter/material.dart';
import 'package:mi_estudio/firebase/pay_firebase.dart';

class SubscriptionProvider extends ChangeNotifier {
  Map<String, dynamic>? _plan;
  bool get isActive => _plan?['isActive'] == true;
  String? get type => _plan?['type'];
  DateTime? get endDate => _plan?['endDate'];

  Future<void> loadSubscription() async {
    final plan = await PayFirebase().getLastPay();
    _plan = plan;
    notifyListeners();
  }
}