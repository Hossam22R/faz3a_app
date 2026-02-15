import 'dart:async';

import 'package:flutter/material.dart';

import '../controllers/forex_monitor_settings_controller.dart';
import '../controllers/forex_watchlist_controller.dart';
import '../models/forex_analysis_report.dart';
import '../models/forex_monitor_settings.dart';
import '../models/forex_watchlist_item.dart';
import '../services/forex_alert_notification_bridge.dart';
import '../services/forex_local_notifications_service.dart';
import '../services/live_forex_analysis_service.dart';
import '../services/multi_pair_forex_signal_monitor.dart';
import '../services/twelve_data_forex_data_source.dart';
import 'forex_live_monitor_route_page.dart';
import 'forex_monitor_settings_page.dart';
import 'forex_watchlist_page.dart';

class ForexMonitorWorkspacePage extends StatefulWidget {
  final ForexMonitorSettingsController? settingsController;
  final ForexWatchlistController? watchlistController;
  final bool disposeController;
  final int initialTabIndex;
  final String monitorTitle;
  final String settingsTitle;
  final String watchlistTitle;
  final String fallbackApiKey;

  const ForexMonitorWorkspacePage({
    Key? key,
    this.settingsController,
    this.watchlistController,
    this.disposeController = true,
    this.initialTabIndex = 0,
    this.monitorTitle = 'Forex Live Monitor',
    this.settingsTitle = 'Forex Monitor Settings',
    this.watchlistTitle = 'Forex Watchlist',
    this.fallbackApiKey = const String.fromEnvironment('TWELVE_DATA_API_KEY'),
  }) : super(key: key);

  @override
  State<ForexMonitorWorkspacePage> createState() =>
      _ForexMonitorWorkspacePageState();
}

class _ForexMonitorWorkspacePageState extends State<ForexMonitorWorkspacePage> {
  late final ForexMonitorSettingsController _settingsController;
  late final ForexWatchlistController _watchlistController;
  late final bool _ownsSettingsController;
  late final bool _ownsWatchlistController;

  int _selectedTab = 0;
  int _monitorRevision = 0;
  bool _loaded = false;
  int _scannerRestartToken = 0;

  TwelveDataForexDataSource? _scannerDataSource;
  MultiPairForexSignalMonitor? _scannerMonitor;
  ForexAlertNotificationBridge? _scannerNotificationBridge;
  StreamSubscription<ForexWatchlistReportEvent>? _scannerReportsSubscription;
  StreamSubscription<ForexWatchlistErrorEvent>? _scannerErrorsSubscription;

  final Map<String, ForexAnalysisReport> _latestReportsByWatchlistItemId =
      <String, ForexAnalysisReport>{};
  bool _scannerRunning = false;
  String? _scannerStatusMessage;

  @override
  void initState() {
    super.initState();
    _settingsController = widget.settingsController ?? ForexMonitorSettingsController();
    _watchlistController = widget.watchlistController ?? ForexWatchlistController();
    _ownsSettingsController = widget.settingsController == null;
    _ownsWatchlistController = widget.watchlistController == null;
    _selectedTab = widget.initialTabIndex.clamp(0, 2).toInt();
    _settingsController.addListener(_onSettingsControllerChanged);
    _watchlistController.addListener(_onWatchlistControllerChanged);
    _initializeWorkspace();
  }

  @override
  void dispose() {
    _disposeScannerResources();
    _settingsController.removeListener(_onSettingsControllerChanged);
    _watchlistController.removeListener(_onWatchlistControllerChanged);
    if (_ownsSettingsController && widget.disposeController) {
      _settingsController.dispose();
    }
    if (_ownsWatchlistController && widget.disposeController) {
      _watchlistController.dispose();
    }
    super.dispose();
  }

  Future<void> _initializeWorkspace() async {
    await _settingsController.load();
    await _watchlistController.load();
    if (!mounted) {
      return;
    }

    final ForexMonitorSettings current = _settingsController.settings;
    final String fallbackKey = widget.fallbackApiKey.trim();
    if (current.apiKey.trim().isEmpty && fallbackKey.isNotEmpty) {
      final ForexMonitorSettings patched = current.copyWith(apiKey: fallbackKey);
      _settingsController.update(patched);
      await _settingsController.save();
    }

    await _seedWatchlistIfNeeded();
    await _restartWatchlistScanner();

    if (!mounted) {
      return;
    }

    setState(() {
      _loaded = true;
    });
  }

  Future<void> _seedWatchlistIfNeeded() async {
    if (_watchlistController.items.isNotEmpty) {
      return;
    }

    final ForexMonitorSettings settings = _settingsController.settings;
    final ForexWatchlistItem seed = ForexWatchlistItem.create(
      symbol: settings.symbol,
      timeframe: settings.timeframe,
      label: 'Default Pair',
      isEnabled: true,
      isPrimary: true,
    );

    await _watchlistController.add(seed);
  }

  Future<void> _restartWatchlistScanner() async {
    final int token = ++_scannerRestartToken;
    _disposeScannerResources();
    _latestReportsByWatchlistItemId.clear();

    final ForexMonitorSettings settings = _settingsController.settings;
    final List<ForexWatchlistItem> enabledItems = _watchlistController.items
        .where((ForexWatchlistItem item) => item.isEnabled)
        .toList(growable: false);

    if (!mounted || token != _scannerRestartToken) {
      return;
    }

    if (settings.apiKey.trim().isEmpty) {
      setState(() {
        _scannerRunning = false;
        _scannerStatusMessage = 'Scanner paused: API key is missing.';
      });
      return;
    }

    if (enabledItems.isEmpty) {
      setState(() {
        _scannerRunning = false;
        _scannerStatusMessage =
            'Scanner paused: no enabled pairs in watchlist.';
      });
      return;
    }

    if (!settings.autoStart) {
      setState(() {
        _scannerRunning = false;
        _scannerStatusMessage =
            'Scanner paused: auto-start is disabled in settings.';
      });
      return;
    }

    try {
      final TwelveDataForexDataSource dataSource =
          TwelveDataForexDataSource(apiKey: settings.apiKey.trim());
      final LiveForexAnalysisService analysisService =
          LiveForexAnalysisService(marketDataSource: dataSource);
      final MultiPairForexSignalMonitor scanner = MultiPairForexSignalMonitor(
        analysisService: analysisService,
        watchlistProvider: () => _watchlistController.items,
        config: MultiPairForexMonitorConfig(
          pollInterval: settings.pollInterval,
          candlesLimit: settings.candlesLimit,
          strongSignalConfidence: settings.strongSignalConfidence,
        ),
      );

      _scannerDataSource = dataSource;
      _scannerMonitor = scanner;

      _scannerReportsSubscription =
          scanner.reports.listen((ForexWatchlistReportEvent event) {
        _latestReportsByWatchlistItemId[event.item.id] = event.report;
        if (!mounted) {
          return;
        }
        setState(() {});
      });

      _scannerErrorsSubscription =
          scanner.errors.listen((ForexWatchlistErrorEvent event) {
        if (!mounted) {
          return;
        }
        setState(() {
          _scannerStatusMessage =
              'Scanner error on ${event.item.symbol} ${event.item.timeframe}.';
        });
      });

      if (settings.enableLocalNotifications) {
        final ForexAlertNotificationBridge bridge =
            ForexAlertNotificationBridge.fromStream(
          alertsStream: scanner.alerts,
          notificationsService: ForexLocalNotificationsService(),
          onNotificationError: (Object error) {
            if (!mounted) {
              return;
            }
            setState(() {
              _scannerStatusMessage = 'Notification error: $error';
            });
          },
        );
        await bridge.start();
        _scannerNotificationBridge = bridge;
      }

      if (!mounted || token != _scannerRestartToken) {
        _disposeScannerResources();
        return;
      }

      scanner.start(runImmediately: true);
      setState(() {
        _scannerRunning = true;
        _scannerStatusMessage =
            'Scanner running for ${enabledItems.length} enabled pair(s).';
        _monitorRevision++;
      });
    } catch (error) {
      _disposeScannerResources();
      if (!mounted || token != _scannerRestartToken) {
        return;
      }
      setState(() {
        _scannerStatusMessage = 'Scanner failed to start: $error';
      });
    }
  }

  void _disposeScannerResources() {
    _scannerReportsSubscription?.cancel();
    _scannerReportsSubscription = null;

    _scannerErrorsSubscription?.cancel();
    _scannerErrorsSubscription = null;

    _scannerNotificationBridge?.dispose();
    _scannerNotificationBridge = null;

    _scannerMonitor?.dispose();
    _scannerMonitor = null;

    _scannerDataSource?.dispose();
    _scannerDataSource = null;

    _scannerRunning = false;
  }

  void _onSettingsControllerChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  void _onWatchlistControllerChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  void _handleSettingsSaved(ForexMonitorSettings settings) {
    _settingsController.update(settings);
    setState(() {
      _monitorRevision++;
      _selectedTab = 0;
    });
    _restartWatchlistScanner();
  }

  void _handleWatchlistChanged(List<ForexWatchlistItem> _) {
    setState(() {
      _monitorRevision++;
    });
    _restartWatchlistScanner();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _settingsController.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final Object? error = _settingsController.lastError;
    if (error != null && _settingsController.settings.apiKey.trim().isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.monitorTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(Icons.error_outline, color: Colors.red, size: 40),
                const SizedBox(height: 8),
                Text(error.toString(), textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _initializeWorkspace,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: IndexedStack(
        index: _selectedTab,
        children: <Widget>[
          _buildMonitorTab(),
          ForexMonitorSettingsPage(
            controller: _settingsController,
            disposeController: false,
            allowOpenMonitor: false,
            title: widget.settingsTitle,
            monitorTitle: widget.monitorTitle,
            onSettingsSaved: _handleSettingsSaved,
          ),
          ForexWatchlistPage(
            controller: _watchlistController,
            disposeController: false,
            title: widget.watchlistTitle,
            autoLoad: false,
            latestReportsByItemId: _latestReportsByWatchlistItemId,
            scannerRunning: _scannerRunning,
            scannerStatusMessage: _scannerStatusMessage,
            onWatchlistChanged: _handleWatchlistChanged,
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTab,
        onTap: (int index) {
          setState(() {
            _selectedTab = index;
          });
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Monitor',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.format_list_bulleted),
            label: 'Watchlist',
          ),
        ],
      ),
    );
  }

  Widget _buildMonitorTab() {
    final ForexMonitorSettings baseSettings = _settingsController.settings;
    if (baseSettings.apiKey.trim().isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.monitorTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(Icons.vpn_key_outlined, size: 42),
                const SizedBox(height: 12),
                const Text(
                  'API key is missing. Open Settings tab and save your key.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _selectedTab = 1;
                    });
                  },
                  icon: const Icon(Icons.settings),
                  label: const Text('Go to settings'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final ForexWatchlistItem? pair =
        _watchlistController.primaryEnabledItem ?? _watchlistController.firstEnabledItem;

    final ForexMonitorSettings selectedSettings = pair == null
        ? baseSettings
        : baseSettings.copyWith(
            symbol: pair.symbol,
            timeframe: pair.timeframe,
          );
    final bool enableInlineNotifications =
        selectedSettings.enableLocalNotifications && !_scannerRunning;
    final ForexMonitorSettings settings = selectedSettings.copyWith(
      enableLocalNotifications: enableInlineNotifications,
    );

    final String monitorKey = <Object>[
      _monitorRevision,
      settings.apiKey,
      settings.symbol,
      settings.timeframe,
      settings.pollIntervalMinutes,
      settings.candlesLimit,
      settings.strongSignalConfidence,
      settings.maxPersistedAlerts,
      settings.enableLocalNotifications,
      settings.autoStart,
      pair?.id ?? 'settings_pair',
    ].join('|');

    return ForexLiveMonitorRoutePage.fromSettings(
      key: ValueKey<String>(monitorKey),
      settings: settings,
      title: widget.monitorTitle,
    );
  }
}
