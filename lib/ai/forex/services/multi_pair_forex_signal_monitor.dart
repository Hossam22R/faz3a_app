import 'dart:async';

import '../models/forex_analysis_report.dart';
import '../models/forex_signal_alert.dart';
import '../models/forex_watchlist_item.dart';
import 'live_forex_analysis_service.dart';

typedef WatchlistItemsProvider = List<ForexWatchlistItem> Function();

class MultiPairForexMonitorConfig {
  final Duration pollInterval;
  final int candlesLimit;
  final double strongSignalConfidence;
  final bool alertOnNeutralSignalChange;
  final bool emitInitialStrongSignalAlert;

  const MultiPairForexMonitorConfig({
    this.pollInterval = const Duration(minutes: 5),
    this.candlesLimit = 180,
    this.strongSignalConfidence = 70.0,
    this.alertOnNeutralSignalChange = false,
    this.emitInitialStrongSignalAlert = false,
  });
}

class ForexWatchlistReportEvent {
  final ForexWatchlistItem item;
  final ForexAnalysisReport report;
  final DateTime scannedAt;

  const ForexWatchlistReportEvent({
    required this.item,
    required this.report,
    required this.scannedAt,
  });
}

class ForexWatchlistErrorEvent {
  final ForexWatchlistItem item;
  final Object error;
  final DateTime occurredAt;

  const ForexWatchlistErrorEvent({
    required this.item,
    required this.error,
    required this.occurredAt,
  });
}

class MultiPairForexSignalMonitor {
  final LiveForexAnalysisService analysisService;
  final WatchlistItemsProvider watchlistProvider;
  final MultiPairForexMonitorConfig config;

  final StreamController<ForexWatchlistReportEvent> _reportController =
      StreamController<ForexWatchlistReportEvent>.broadcast();
  final StreamController<ForexSignalAlert> _alertController =
      StreamController<ForexSignalAlert>.broadcast();
  final StreamController<ForexWatchlistErrorEvent> _errorController =
      StreamController<ForexWatchlistErrorEvent>.broadcast();

  final Map<String, ForexAnalysisReport> _lastReportsByItemId =
      <String, ForexAnalysisReport>{};

  Timer? _timer;
  bool _isPolling = false;
  bool _isDisposed = false;

  MultiPairForexSignalMonitor({
    required this.analysisService,
    required this.watchlistProvider,
    this.config = const MultiPairForexMonitorConfig(),
  });

  Stream<ForexWatchlistReportEvent> get reports => _reportController.stream;
  Stream<ForexSignalAlert> get alerts => _alertController.stream;
  Stream<ForexWatchlistErrorEvent> get errors => _errorController.stream;

  bool get isRunning => _timer != null;

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
      final List<ForexWatchlistItem> items = watchlistProvider()
          .where((ForexWatchlistItem item) => item.isEnabled)
          .toList(growable: false);

      final Set<String> activeIds = <String>{};
      for (final ForexWatchlistItem item in items) {
        activeIds.add(item.id);
        await _scanSingleItem(item);
      }

      _lastReportsByItemId.removeWhere(
        (String itemId, ForexAnalysisReport _) => !activeIds.contains(itemId),
      );
    } finally {
      _isPolling = false;
    }
  }

  Future<void> _scanSingleItem(ForexWatchlistItem item) async {
    try {
      final ForexAnalysisReport report = await analysisService.analyzeLive(
        symbol: item.symbol,
        timeframe: item.timeframe,
        candlesLimit: config.candlesLimit,
      );

      _emitReport(
        ForexWatchlistReportEvent(
          item: item,
          report: report,
          scannedAt: DateTime.now(),
        ),
      );

      final ForexAnalysisReport? previous = _lastReportsByItemId[item.id];
      _emitAlertIfNeeded(item: item, report: report, previous: previous);
      _lastReportsByItemId[item.id] = report;
    } catch (error) {
      _emitError(
        ForexWatchlistErrorEvent(
          item: item,
          error: error,
          occurredAt: DateTime.now(),
        ),
      );
    }
  }

  void _emitReport(ForexWatchlistReportEvent event) {
    if (!_reportController.isClosed) {
      _reportController.add(event);
    }
  }

  void _emitError(ForexWatchlistErrorEvent event) {
    if (!_errorController.isClosed) {
      _errorController.add(event);
    }
  }

  void _emitAlert(ForexSignalAlert alert) {
    if (!_alertController.isClosed) {
      _alertController.add(alert);
    }
  }

  void _emitAlertIfNeeded({
    required ForexWatchlistItem item,
    required ForexAnalysisReport report,
    required ForexAnalysisReport? previous,
  }) {
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
              '${item.displayName}: signal changed from ${previous.signalLabel} to ${report.signalLabel}.',
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

    if (!shouldEmitStrongAlert) {
      return;
    }

    _emitAlert(
      ForexSignalAlert(
        symbol: report.symbol,
        timeframe: report.timeframe,
        signal: report.signal,
        previousSignal: previous?.signal,
        type: ForexAlertType.strongSignal,
        confidence: report.confidence,
        message:
            '${item.displayName}: strong ${report.signalLabel} signal (${report.confidence.toStringAsFixed(1)}%).',
        reasons: report.reasons,
        createdAt: DateTime.now(),
      ),
    );
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
