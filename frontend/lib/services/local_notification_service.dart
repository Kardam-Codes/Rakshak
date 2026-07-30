import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../engine/models/risk_level.dart';
import 'dart:developer' as developer;
import 'dart:ui';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  
  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
    
    // Setting up generic settings
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    
    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        developer.log('User tapped the local notification! Payload: ${details.payload}');
      }
    );
    
    developer.log("Local Notifications Initialized.");
  }
  
  static Future<void> showHighRiskAlert({required String title, required String body}) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'high_risk_alerts',
      'High Risk Alerts',
      channelDescription: 'Notifications for detected high risk scams',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'Rakshak Alert',
      color: Color(0xFFD32F2F), // Maps to AppColors.danger
    );
    
    const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
    
    await _flutterLocalNotificationsPlugin.show(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000), 
      title: '🚨 $title',
      body: body,
      notificationDetails: platformChannelSpecifics,
      payload: 'high_risk_alert',
    );
  }
}
