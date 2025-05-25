import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mi_estudio/firebase_options.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static final FirebaseMessaging _firebaseMessaging =
      FirebaseMessaging.instance;

  // Handler para notificaciones en segundo plano
  @pragma('vm:entry-point')
  static Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    await _initializeLocalNotifications();
    await _showFlutterLocalNotification(message);
  }

  static Future<void> initializeNotification() async {
    await _firebaseMessaging.requestPermission();

    // Mostrar notificaciones en primer plano
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      await _showFlutterLocalNotification(message);
    });

    await _getFcmToken();
    await _initializeLocalNotifications();
    await _getInitialNotification();
  }

  static Future<void> _getFcmToken() async {
    String? token = await _firebaseMessaging.getToken();
    print('FCM Token: $token');
  }

  static Future<void> _showFlutterLocalNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    Map<String, dynamic>? data = message.data;

    String title = notification?.title ?? data['title'] ?? 'No Title';
    String body = notification?.body ?? data['body'] ?? 'No Body';

    AndroidNotificationDetails androidDetails = const AndroidNotificationDetails(
      'CHANNEL_ID', // Debe coincidir con el del Manifest
      'CHANNEL_NAME',
      channelDescription: 'Notification channel description',
      importance: Importance.max,
      priority: Priority.high,
    );

    DarwinNotificationDetails iOSDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      notificationDetails,
    );
  }

  static Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidInit =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosInit = DarwinInitializationSettings();

    final InitializationSettings initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    // Aquí usamos el callback definido como función global
    await flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveBackgroundNotificationResponse: onDidReceiveBackgroundNotificationResponse,
    );

    // (Opcional) Registrar canal manualmente si quieres control adicional
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(AndroidNotificationChannel(
          'CHANNEL_ID',
          'CHANNEL_NAME',
          description: 'Notification channel description',
          importance: Importance.max,
        ));
  }

  static Future<void> _getInitialNotification() async {
    RemoteMessage? message = await FirebaseMessaging.instance.getInitialMessage();

    if (message != null) {
      print('Notification tapped from terminated state: ${message.data}');
    }
  }
}

// Callback para manejar la acción de la notificación en segundo plano
@pragma('vm:entry-point')
void onDidReceiveBackgroundNotificationResponse(NotificationResponse response) {
  print('Notification tapped in background: ${response.payload}');
}
