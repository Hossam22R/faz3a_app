import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/forex_analysis_report.dart';
import '../models/forex_signal_alert.dart';
import '../services/forex_alert_history_store.dart';
import '../services/live_forex_signal_monitor.dart';

class LiveForexMonitorController extends ChangeNotifier {
  final LiveForexSignalMonitor monitor;
  final ForexAlertHistoryStore? alertHistoryStore;
  final int maxPersistedAlerts;

  StreamSubscription<ForexAnalysisReport>? _reportSubscription;
  StreamSubscription<ForexSignalAlert>? _alertSubscription;
  StreamSubscription<Object>? _errorSubscription;
  bool _historyLoaded = false;
  bool _isDisposed = false;

  ForexAnalysisReport? latestReport;
  ForexSignalAlert? latestAlert;
  Object? lastError;
  final List<ForexSignalAlert> _alertHistory = <ForexSignalAlert>[];

  LiveForexMonitorController({
    required this.monitor,
    this.alertHistoryStore,
    this.maxPersistedAlerts = 200,
  });

  bool get isRunning => monitor.isRunning;
  List<ForexSignalAlert> get alertHistory =>
      List<ForexSignalAlert>.unmodifiable(_alertHistory);

  void start({bool runImmediately = true}) {
    _ensureBindings();
    _loadHistoryIfNeeded();
    monitor.start(runImmediately: runImmediately);
    _notifyIfActive();
  }

  void stop() {
    monitor.stop();
    _notifyIfActive();
  }

  Future<void> refreshNow() async {
    await monitor.refreshNow();
  }

  Future<void> reloadHistory() async {
    final ForexAlertHistoryStore? store = alertHistoryStore;
    if (store == null) {
      return;
    }

    try {
      final List<ForexSignalAlert> loaded =
          await store.loadAlerts(maxItems: maxPersistedAlerts);
      _alertHistory
        ..clear()
        ..addAll(loaded);
      _historyLoaded = true;
      _notifyIfActive();
    } catch (error) {
      lastError = error;
      _notifyIfActive();
    }
  }

  Future<void> clearAlertHistory() async {
    _alertHistory.clear();
    _notifyIfActive();

    final ForexAlertHistoryStore? store = alertHistoryStore;
    if (store == null) {
      return;
    }

    try {
      await store.clear();
    } catch (error) {
      lastError = error;
      _notifyIfActive();
    }
  }

  void clearLastError() {
    lastError = null;
    _notifyIfActive();
  }

  void clearLatestAlert() {
    latestAlert = null;
    _notifyIfActive();
  }

  void _ensureBindings() {
    _reportSubscription ??= monitor.reports.listen((ForexAnalysisReport report) {
      latestReport = report;
      _notifyIfActive();
    });

    _alertSubscription ??= monitor.alerts.listen((ForexSignalAlert alert) {
      latestAlert = alert;
      _appendAlertToHistory(alert);
      _notifyIfActive();
    });

    _errorSubscription ??= monitor.errors.listen((Object error) {
      lastError = error;
      _notifyIfActive();
    });
  }

  @override
  void dispose() {
    _isDisposed = true;
    _reportSubscription?.cancel();
    _alertSubscription?.cancel();
    _errorSubscription?.cancel();
    monitor.dispose();
    super.dispose();
  }

  void _loadHistoryIfNeeded() {
    if (_historyLoaded || alertHistoryStore == null) {
      return;
    }

    reloadHistory();
  }

  void _appendAlertToHistory(ForexSignalAlert alert) {
    _alertHistory.insert(0, alert);
    if (_alertHistory.length > maxPersistedAlerts) {
      _alertHistory.removeRange(maxPersistedAlerts, _alertHistory.length);
    }

    _persistAlertHistory();
  }

  void _persistAlertHistory() {
    final ForexAlertHistoryStore? store = alertHistoryStore;
    if (store == null) {
      return;
    }

    store
        .saveAlerts(_alertHistory, maxItems: maxPersistedAlerts)
        .catchError((Object error) {
      lastError = error;
      _notifyIfActive();
    });
  }

  void _notifyIfActive() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }
}
