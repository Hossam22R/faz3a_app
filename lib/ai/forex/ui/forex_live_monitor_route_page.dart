import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/live_forex_monitor_controller.dart';
import '../models/forex_monitor_settings.dart';
import '../services/forex_alert_history_store.dart';
import '../services/forex_alert_notification_bridge.dart';
import '../services/forex_local_notifications_service.dart';
import '../services/live_forex_analysis_service.dart';
import '../services/live_forex_signal_monitor.dart';
import '../services/twelve_data_forex_data_source.dart';
import 'forex_monitor_page.dart';

class ForexLiveMonitorRoutePage extends StatefulWidget {
  final String apiKey;
  final String symbol;
  final String timeframe;
  final String title;
  final Duration pollInterval;
  final int candlesLimit;
  final double strongSignalConfidence;
  final int maxPersistedAlerts;
  final bool enableLocalNotifications;
  final bool autoStart;

  const ForexLiveMonitorRoutePage({
    Key? key,
    required this.apiKey,
    this.symbol = 'EURUSD',
    this.timeframe = 'M15',
    this.title = 'Forex Live Monitor',
    this.pollInterval = const Duration(minutes: 5),
    this.candlesLimit = 180,
    this.strongSignalConfidence = 72,
    this.maxPersistedAlerts = 300,
    this.enableLocalNotifications = true,
    this.autoStart = true,
  }) : super(key: key);

  factory ForexLiveMonitorRoutePage.fromSettings({
    Key? key,
    required ForexMonitorSettings settings,
    String title = 'Forex Live Monitor',
  }) {
    return ForexLiveMonitorRoutePage(
      key: key,
      apiKey: settings.apiKey,
      symbol: settings.symbol,
      timeframe: settings.timeframe,
      title: title,
      pollInterval: settings.pollInterval,
      candlesLimit: settings.candlesLimit,
      strongSignalConfidence: settings.strongSignalConfidence,
      maxPersistedAlerts: settings.maxPersistedAlerts,
      enableLocalNotifications: settings.enableLocalNotifications,
      autoStart: settings.autoStart,
    );
  }

  @override
  State<ForexLiveMonitorRoutePage> createState() =>
      _ForexLiveMonitorRoutePageState();
}

class _ForexLiveMonitorRoutePageState extends State<ForexLiveMonitorRoutePage> {
  TwelveDataForexDataSource? _dataSource;
  LiveForexMonitorController? _controller;
  ForexAlertNotificationBridge? _notificationBridge;
  Object? _setupError;
  bool _isReady = false;

  @override
  void initState() {
    super.initState();
    _setup();
  }

  @override
  void didUpdateWidget(covariant ForexLiveMonitorRoutePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    final bool mustRecreate = oldWidget.apiKey != widget.apiKey ||
        oldWidget.symbol != widget.symbol ||
        oldWidget.timeframe != widget.timeframe ||
        oldWidget.pollInterval != widget.pollInterval ||
        oldWidget.candlesLimit != widget.candlesLimit ||
        oldWidget.strongSignalConfidence != widget.strongSignalConfidence ||
        oldWidget.maxPersistedAlerts != widget.maxPersistedAlerts ||
        oldWidget.enableLocalNotifications != widget.enableLocalNotifications ||
        oldWidget.autoStart != widget.autoStart;

    if (mustRecreate) {
      _setup();
    }
  }

  @override
  void dispose() {
    _disposeResources();
    super.dispose();
  }

  Future<void> _setup() async {
    _disposeResources();

    setState(() {
      _isReady = false;
      _setupError = null;
    });

    TwelveDataForexDataSource? dataSource;
    LiveForexMonitorController? controller;
    ForexAlertNotificationBridge? bridge;

    try {
      if (widget.apiKey.trim().isEmpty) {
        throw ArgumentError(
          'Missing Twelve Data API key. '
          'Provide apiKey or pass it from --dart-define.',
        );
      }

      dataSource = TwelveDataForexDataSource(apiKey: widget.apiKey.trim());
      final LiveForexAnalysisService analysisService =
          LiveForexAnalysisService(marketDataSource: dataSource);
      final LiveForexSignalMonitor monitor = LiveForexSignalMonitor(
        analysisService: analysisService,
        symbol: widget.symbol,
        timeframe: widget.timeframe,
        config: LiveForexMonitorConfig(
          pollInterval: widget.pollInterval,
          candlesLimit: widget.candlesLimit,
          strongSignalConfidence: widget.strongSignalConfidence,
        ),
      );

      controller = LiveForexMonitorController(
        monitor: monitor,
        alertHistoryStore: ForexAlertHistoryStore(),
        maxPersistedAlerts: widget.maxPersistedAlerts,
      );

      if (widget.enableLocalNotifications) {
        bridge = ForexAlertNotificationBridge(
          monitor: monitor,
          notificationsService: ForexLocalNotificationsService(),
        );
        await bridge.start();
      }

      if (!mounted) {
        bridge?.dispose();
        controller.dispose();
        dataSource.dispose();
        return;
      }

      _dataSource = dataSource;
      _controller = controller;
      _notificationBridge = bridge;

      if (widget.autoStart) {
        _controller?.start(runImmediately: true);
      } else {
        _controller?.reloadHistory();
      }

      setState(() {
        _isReady = true;
      });
    } catch (error) {
      bridge?.dispose();
      controller?.dispose();
      dataSource?.dispose();

      if (!mounted) {
        return;
      }
      setState(() {
        _setupError = error;
      });
    }
  }

  void _disposeResources() {
    _notificationBridge?.dispose();
    _notificationBridge = null;

    _controller?.dispose();
    _controller = null;

    _dataSource?.dispose();
    _dataSource = null;
  }

  @override
  Widget build(BuildContext context) {
    if (_setupError != null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(Icons.error_outline, color: Colors.red, size: 40),
                const SizedBox(height: 12),
                const Text(
                  'Unable to initialize forex monitor.',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _setupError.toString(),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _setup,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (!_isReady || _controller == null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.title)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return ChangeNotifierProvider<LiveForexMonitorController>.value(
      value: _controller!,
      child: Consumer<LiveForexMonitorController>(
        builder: (BuildContext context, LiveForexMonitorController controller, _) {
          return ForexMonitorPage(
            controller: controller,
            title: widget.title,
            autoStart: false,
            disposeController: false,
          );
        },
      ),
    );
  }
}
