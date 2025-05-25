import 'package:flutter/material.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationProvider extends ChangeNotifier {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  late SharedPreferences _prefs;

  final Map<String, bool> _topicSubscriptions = {
    'general': false,
    'actualizacion': false,
    'motivacion': false,
    'calendario': false,
    'Sin': false,
  };

  Map<String, bool> get topicSubscriptions => _topicSubscriptions;

  NotificationProvider() {
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    _prefs = await SharedPreferences.getInstance();
    for (var topic in _topicSubscriptions.keys) {
      _topicSubscriptions[topic] = _prefs.getBool(topic) ?? false;
    }
    notifyListeners();
  }

  Future<void> _syncFirebaseSubscriptions() async {
    for (var topic in _topicSubscriptions.keys) {
      if (topic == 'general' || topic == 'Sin') continue;
      if (_topicSubscriptions[topic]! && _topicSubscriptions['general']!) {
        await _firebaseMessaging.subscribeToTopic(topic);
      } else {
        await _firebaseMessaging.unsubscribeFromTopic(topic);
      }
    }
  }

  Future<void> clearAllSubscriptions() async {
    for (var topic in _topicSubscriptions.keys) {
      if (topic != 'Sin' && topic != 'general') {
        await _firebaseMessaging.unsubscribeFromTopic(topic);
      }
      _topicSubscriptions[topic] = false;
      for (var key in _topicSubscriptions.keys) {
      await _prefs.setBool(key, false);
    }
    }
    notifyListeners();
}

  Future<void> handleSubscriptionChange(String topic, bool newValue) async {
    _topicSubscriptions[topic] = newValue;

    // Lógica de switches (igual que antes)
    if (topic == 'Sin' && newValue) {
      _topicSubscriptions['general'] = false;
      _topicSubscriptions['actualizacion'] = false;
      _topicSubscriptions['motivacion'] = false;
      _topicSubscriptions['calendario'] = false;
    }
    if (topic == 'general' && newValue) {
      _topicSubscriptions['Sin'] = false;
      _topicSubscriptions['actualizacion'] = true;
      _topicSubscriptions['motivacion'] = true;
      _topicSubscriptions['calendario'] = true;
    }
    if ((topic == 'actualizacion' || topic == 'motivacion' || topic == 'calendario') && !newValue) {
      _topicSubscriptions['general'] = false;
    }
    if ((topic == 'actualizacion' || topic == 'motivacion' || topic == 'calendario') && newValue) {
      _topicSubscriptions['Sin'] = false;
    }
    if (_topicSubscriptions['actualizacion']! &&
        _topicSubscriptions['motivacion']! &&
        _topicSubscriptions['calendario']!) {
      _topicSubscriptions['general'] = true;
    }
    if (!_topicSubscriptions['actualizacion']! &&
        !_topicSubscriptions['motivacion']! &&
        !_topicSubscriptions['calendario']!) {
      _topicSubscriptions['Sin'] = true;
    }

    // Guardar en SharedPreferences
    for (var key in _topicSubscriptions.keys) {
      await _prefs.setBool(key, _topicSubscriptions[key]!);
    }
    notifyListeners();
    await _syncFirebaseSubscriptions();
  }
}