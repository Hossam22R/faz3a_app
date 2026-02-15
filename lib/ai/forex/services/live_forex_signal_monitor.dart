import 'dart:async';

import '../models/forex_analysis_report.dart';
import '../models/forex_signal_alert.dart';
import 'live_forex_analysis_service.dart';

class LiveForexMonitorConfig {
  final Duration pollInterval;
  final int candlesLimit;
  final double strongSignalConfidence;
  final bool alertOnNeutralSignalChange;
  final bool emitInitialStrongSignalAlert;

  const LiveForexMonitorConfig({
    this.pollInterval = const Duration(minutes: 5),
    this.candlesLimit = 200,
    this.strongSignalConfidence = 70.0,
    this.alertOnNeutralSignalChange = false,
    this.emitInitialStrongSignalAlert = false,
  });
}

class LiveForexSignalMonitor {
  final LiveForexAnalysisService analysisService;
  final String symbol;
  final String timeframe;
  final LiveForexMonitorConfig config;

  final StreamController<ForexAnalysisReport> _reportController =
      StreamController<ForexAnalysisReport>.broadcast();
  final StreamController<ForexSignalAlert> _alertController =
      StreamController<ForexSignalAlert>.broadcast();
  final StreamController<Object> _errorController =
      StreamController<Object>.broadcast();

  Timer? _timer;
  bool _isPolling = false;
  bool _isDisposed = false;
  ForexAnalysisReport? _lastReport;

  LiveForexSignalMonitor({
    required this.analysisService,
    required this.symbol,
    required this.timeframe,
    this.config = const LiveForexMonitorConfig(),
  });

  Stream<ForexAnalysisReport> get reports => _reportController.stream;
  Stream<ForexSignalAlert> get alerts => _alertController.stream;
  Stream<Object> get errors => _errorController.stream;

  bool get isRunning => _timer != null;
  ForexAnalysisReport? get lastReport => _lastReport;

  void start({bool runImmediately = true}) {
    if (_isDisposed || isRunning) {
      return;
    }

    if (runImmediately) {
      _poll();
    }

    _timer = Timer.periodic(config.pollInterval, (_) {
      _poll();
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> refreshNow() {
    return _poll(force: true);
  }

  Future<void> _poll({bool force = false}) async {
    if (_isDisposed) {
      return;
    }

    if (_isPolling && !force) {
      return;
    }

    _isPolling = true;
    try {
      final ForexAnalysisReport report = await analysisService.analyzeLive(
        symbol: symbol,
        timeframe: timeframe,
        candlesLimit: config.candlesLimit,
      );

      _emitReport(report);
      _emitAlertIfNeeded(report);
      _lastReport = report;
    } catch (error) {
      if (!_errorController.isClosed) {
        _errorController.add(error);
      }
    } finally {
      _isPolling = false;
    }
  }

  void _emitReport(ForexAnalysisReport report) {
    if (!_reportController.isClosed) {
      _reportController.add(report);
    }
  }

  void _emitAlertIfNeeded(ForexAnalysisReport report) {
    final ForexAnalysisReport? previous = _lastReport;

    if (previous != null && previous.signal != report.signal) {
      if (!config.alertOnNeutralSignalChange &&
          report.signal == ForexSignal.neutral) {
        return;
      }

      _emitAlert(
        ForexSignalAlert(
          symbol: report.symbol,
          timeframe: report.timeframe,
          signal: report.signal,
          previousSignal: previous.signal,
          type: ForexAlertType.signalChanged,
          confidence: report.confidence,
          message:
              'Signal changed from ${previous.signalLabel} to ${report.signalLabel}.',
          reasons: report.reasons,
          createdAt: DateTime.now(),
        ),
      );
      return;
    }

    final bool isStrongSignal = report.signal != ForexSignal.neutral &&
        report.confidence >= config.strongSignalConfidence;

    if (!isStrongSignal) {
      return;
    }

    final bool shouldEmitStrongAlert = previous == null
        ? config.emitInitialStrongSignalAlert
        : previous.signal != report.signal ||
            previous.confidence < config.strongSignalConfidence;

    if (shouldEmitStrongAlert) {
      _emitAlert(
        ForexSignalAlert(
          symbol: report.symbol,
          timeframe: report.timeframe,
          signal: report.signal,
          previousSignal: previous?.signal,
          type: ForexAlertType.strongSignal,
          confidence: report.confidence,
          message:
              'Strong ${report.signalLabel} signal detected (${report.confidence.toStringAsFixed(1)}%).',
          reasons: report.reasons,
          createdAt: DateTime.now(),
        ),
      );
    }
  }

  void _emitAlert(ForexSignalAlert alert) {
    if (!_alertController.isClosed) {
      _alertController.add(alert);
    }
  }

  void dispose() {
    if (_isDisposed) {
      return;
    }

    stop();
    _isDisposed = true;
    _reportController.close();
    _alertController.close();
    _errorController.close();
  }
}
