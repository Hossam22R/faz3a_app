import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/forex_analysis_report.dart';
import '../models/forex_signal_alert.dart';
import '../services/live_forex_signal_monitor.dart';

class LiveForexMonitorController extends ChangeNotifier {
  final LiveForexSignalMonitor monitor;

  StreamSubscription<ForexAnalysisReport>? _reportSubscription;
  StreamSubscription<ForexSignalAlert>? _alertSubscription;
  StreamSubscription<Object>? _errorSubscription;

  ForexAnalysisReport? latestReport;
  ForexSignalAlert? latestAlert;
  Object? lastError;

  LiveForexMonitorController({
    required this.monitor,
  });

  bool get isRunning => monitor.isRunning;

  void start({bool runImmediately = true}) {
    _ensureBindings();
    monitor.start(runImmediately: runImmediately);
    notifyListeners();
  }

  void stop() {
    monitor.stop();
    notifyListeners();
  }

  Future<void> refreshNow() async {
    await monitor.refreshNow();
  }

  void clearLastError() {
    lastError = null;
    notifyListeners();
  }

  void clearLatestAlert() {
    latestAlert = null;
    notifyListeners();
  }

  void _ensureBindings() {
    _reportSubscription ??= monitor.reports.listen((ForexAnalysisReport report) {
      latestReport = report;
      notifyListeners();
    });

    _alertSubscription ??= monitor.alerts.listen((ForexSignalAlert alert) {
      latestAlert = alert;
      notifyListeners();
    });

    _errorSubscription ??= monitor.errors.listen((Object error) {
      lastError = error;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _reportSubscription?.cancel();
    _alertSubscription?.cancel();
    _errorSubscription?.cancel();
    monitor.dispose();
    super.dispose();
  }
}
