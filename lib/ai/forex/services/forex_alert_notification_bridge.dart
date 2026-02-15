import 'dart:async';

import '../models/forex_signal_alert.dart';
import 'forex_local_notifications_service.dart';
import 'live_forex_signal_monitor.dart';

class ForexAlertNotificationBridge {
  final LiveForexSignalMonitor monitor;
  final ForexLocalNotificationsService notificationsService;
  final void Function(Object error)? onNotificationError;

  StreamSubscription<ForexSignalAlert>? _alertsSubscription;

  ForexAlertNotificationBridge({
    required this.monitor,
    required this.notificationsService,
    this.onNotificationError,
  });

  bool get isRunning => _alertsSubscription != null;

  Future<void> start() async {
    if (_alertsSubscription != null) {
      return;
    }

    await notificationsService.initialize();

    _alertsSubscription = monitor.alerts.listen(_handleAlert);
  }

  void stop() {
    _alertsSubscription?.cancel();
    _alertsSubscription = null;
  }

  void _handleAlert(ForexSignalAlert alert) {
    notificationsService.showAlert(alert).catchError((Object error) {
      if (onNotificationError != null) {
        onNotificationError!(error);
      }
    });
  }

  void dispose() {
    stop();
  }
}
