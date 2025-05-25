import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'dart:io';

class ConnectivityProvider extends ChangeNotifier {
  bool _isOnline = true;
  late StreamSubscription _subscription;

  bool get isOnline => _isOnline;

  ConnectivityProvider() {
    _checkConnection();
    _subscription = Connectivity().onConnectivityChanged.listen((_) => _checkConnection());
  }

  Future<void> _checkConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      _isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      _isOnline = false;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}