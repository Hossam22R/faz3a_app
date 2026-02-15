import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/forex_analysis_report.dart';
import '../models/forex_signal_alert.dart';

class ForexNotificationChannelConfig {
  final String channelId;
  final String channelName;
  final String channelDescription;
  final String androidIcon;

  const ForexNotificationChannelConfig({
    this.channelId = 'forex_signals_channel',
    this.channelName = 'Forex Signals',
    this.channelDescription = 'Live forex analysis alerts',
    this.androidIcon = '@mipmap/ic_launcher',
  });
}

class ForexLocalNotificationsService {
  final FlutterLocalNotificationsPlugin _plugin;
  final ForexNotificationChannelConfig channelConfig;

  bool _initialized = false;

  ForexLocalNotificationsService({
    FlutterLocalNotificationsPlugin? plugin,
    this.channelConfig = const ForexNotificationChannelConfig(),
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }

    final AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings(channelConfig.androidIcon);
    const DarwinInitializationSettings darwinSettings =
        DarwinInitializationSettings();

    final InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _plugin.initialize(initSettings);
    _initialized = true;
  }

  Future<void> showAlert(ForexSignalAlert alert) async {
    if (!_initialized) {
      throw StateError(
        'ForexLocalNotificationsService is not initialized. '
        'Call initialize() before showing notifications.',
      );
    }

    final NotificationDetails details = NotificationDetails(
      android: AndroidNotificationDetails(
        channelConfig.channelId,
        channelConfig.channelName,
        channelDescription: channelConfig.channelDescription,
        importance: Importance.max,
        priority: Priority.high,
      ),
      iOS: const DarwinNotificationDetails(),
      macOS: const DarwinNotificationDetails(),
    );

    final int id = DateTime.now().millisecondsSinceEpoch % 2147483647;

    await _plugin.show(
      id,
      _buildTitle(alert),
      _buildBody(alert),
      details,
      payload: jsonEncode(alert.toJson()),
    );
  }

  String _buildTitle(ForexSignalAlert alert) {
    final String signal = _signalLabel(alert.signal);
    return '${alert.symbol} ${alert.timeframe} - $signal';
  }

  String _buildBody(ForexSignalAlert alert) {
    return '${alert.message} (Confidence: ${alert.confidence.toStringAsFixed(1)}%)';
  }

  String _signalLabel(ForexSignal signal) {
    switch (signal) {
      case ForexSignal.buy:
        return 'BUY';
      case ForexSignal.sell:
        return 'SELL';
      case ForexSignal.neutral:
        return 'NEUTRAL';
    }
  }
}
