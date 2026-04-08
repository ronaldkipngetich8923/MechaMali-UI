// lib/core/services/notification_service_simple.dart
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/match_model.dart';
import '../theme/app_theme.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
  FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
    DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(settings);
  }

  static Future<void> showMatchReminder(MatchModel match) async {
    final isDerby = _isDerbyMatch(match);

    String title;
    String body;

    if (isDerby) {
      title = '🔥 DERBY ALERT!';
      body = '${match.homeTeam} vs ${match.awayTeam} starts soon!';
    } else if (match.leagueRegion == 'Kenya') {
      title = '⚽ KPL Match Starting';
      body = '${match.homeTeam} vs ${match.awayTeam} at ${_formatTime(match.kickOff)}';
    } else {
      title = '🏆 Match Starting Soon';
      body = '${match.homeTeam} vs ${match.awayTeam}';
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'matches_channel',
      'Match Notifications',
      channelDescription: 'Get alerts for matches and betting tips',
      importance: Importance.high,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      match.hashCode,
      title,
      body,
      details,
    );
  }

  static Future<void> showBettingTip(String title, String body) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'tips_channel',
      'Betting Tips',
      channelDescription: 'AI-generated betting insights',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch.hashCode,
      title,
      body,
      details,
    );
  }

  static bool _isDerbyMatch(MatchModel match) {
    const derbies = [
      ['Gor Mahia', 'AFC Leopards'],
      ['Ulinzi Stars', 'Wazito'],
      ['Bandari', 'Coast Stalions'],
    ];

    for (final derby in derbies) {
      if ((match.homeTeam == derby[0] && match.awayTeam == derby[1]) ||
          (match.homeTeam == derby[1] && match.awayTeam == derby[0])) {
        return true;
      }
    }
    return false;
  }

  static String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}