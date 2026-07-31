import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../engine/models/risk_level.dart';
import 'dart:developer' as developer;
import 'dart:ui';
import 'notification_service.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  
  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // Setting up generic settings
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    
    await _flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        developer.log('User tapped the local notification! Payload: ${details.payload}');
        if (details.payload != null && details.payload!.startsWith('cancel_alert|')) {
           final alertId = details.payload!.split('|')[1];
           NotificationService.cancelPendingAlert(alertId);
        }
      }
    );
    
    developer.log("Local Notifications Initialized.");
  }
  
  static Future<void> showHighRiskAlert({required String title, required String body, String alertId = ''}) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'high_risk_alerts',
      'High Risk Alerts',
      channelDescription: 'Notifications for detected high risk scams',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'Rakshak Alert',
      color: Color(0xFFD32F2F), // Maps to AppColors.danger
      actions: <AndroidNotificationAction>[
        AndroidNotificationAction(
          'cancel',
          'Dismiss / Cancel Alert',
          cancelNotification: true,
          showsUserInterface: true, // brings app to foreground so `onDidReceiveNotificationResponse` works easily
        ),
      ],
    );
    
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    
    await _flutterLocalNotificationsPlugin.show(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000), 
      title: '🚨 $title',
      body: body,
      notificationDetails: platformChannelSpecifics,
      payload: alertId.isNotEmpty ? 'cancel_alert|$alertId' : 'high_risk_alert',
    );
  }
}
