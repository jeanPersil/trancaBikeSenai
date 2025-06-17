import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );
    await _plugin.initialize(settings);

    await _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
      const AndroidNotificationChannel(
        'alerta_channel',
        'Alertas de Segurança',
        description: 'Notificações quando movimento é detectado',
        importance: Importance.high,
      ),
    );
  }

  Future<void> showAlertaNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'alerta_channel',
      'Alertas de Segurança',
      channelDescription: 'Notificações de movimento detectado',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      1,
      'Alerta de Movimento!',
      'Movimento detectado na área monitorada',
      details,
    );
  }
}
