import 'package:flutter/material.dart';

import '../controllers/forex_monitor_settings_controller.dart';
import '../models/forex_monitor_settings.dart';
import 'forex_live_monitor_route_page.dart';

class ForexMonitorSettingsPage extends StatefulWidget {
  final ForexMonitorSettingsController? controller;
  final bool disposeController;
  final bool allowOpenMonitor;
  final String title;
  final String monitorTitle;

  const ForexMonitorSettingsPage({
    Key? key,
    this.controller,
    this.disposeController = true,
    this.allowOpenMonitor = true,
    this.title = 'Forex Monitor Settings',
    this.monitorTitle = 'Forex Live Monitor',
  }) : super(key: key);

  @override
  State<ForexMonitorSettingsPage> createState() => _ForexMonitorSettingsPageState();
}

class _ForexMonitorSettingsPageState extends State<ForexMonitorSettingsPage> {
  static const List<String> _timeframes = <String>[
    'M1',
    'M5',
    'M15',
    'M30',
    'M45',
    'H1',
    'H2',
    'H4',
    'H8',
    'H12',
    'D1',
    'W1',
    'MN1',
  ];

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _symbolController = TextEditingController();
  final TextEditingController _pollIntervalController = TextEditingController();
  final TextEditingController _candlesLimitController = TextEditingController();
  final TextEditingController _strongConfidenceController =
      TextEditingController();
  final TextEditingController _maxAlertsController = TextEditingController();

  late final ForexMonitorSettingsController _controller;
  late final bool _ownsController;
  bool _initialLoadDone = false;

  String _timeframe = 'M15';
  bool _enableLocalNotifications = true;
  bool _autoStart = true;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? ForexMonitorSettingsController();
    _ownsController = widget.controller == null;
    _controller.addListener(_onControllerChanged);
    _loadSettings();
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    if (_ownsController && widget.disposeController) {
      _controller.dispose();
    }

    _apiKeyController.dispose();
    _symbolController.dispose();
    _pollIntervalController.dispose();
    _candlesLimitController.dispose();
    _strongConfidenceController.dispose();
    _maxAlertsController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    await _controller.load();
    if (!mounted) {
      return;
    }

    _applySettingsToForm(_controller.settings);
    setState(() {
      _initialLoadDone = true;
    });
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool busy = _controller.isLoading || _controller.isSaving;
    final Object? error = _controller.lastError;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            tooltip: 'Save settings',
            icon: const Icon(Icons.save_outlined),
            onPressed: busy ? null : _saveSettings,
          ),
        ],
      ),
      body: _initialLoadDone
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  if (error != null)
                    _ErrorBanner(
                      error: error.toString(),
                      onDismiss: _controller.clearError,
                    ),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        TextFormField(
                          controller: _apiKeyController,
                          decoration: const InputDecoration(
                            labelText: 'Twelve Data API Key',
                            hintText: 'Enter API key',
                            border: OutlineInputBorder(),
                          ),
                          validator: (String? value) {
                            if ((value ?? '').trim().isEmpty) {
                              return 'API key is required.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _symbolController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: const InputDecoration(
                            labelText: 'Symbol',
                            hintText: 'EURUSD or EUR/USD',
                            border: OutlineInputBorder(),
                          ),
                          validator: _validateSymbol,
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _timeframe,
                          decoration: const InputDecoration(
                            labelText: 'Timeframe',
                            border: OutlineInputBorder(),
                          ),
                          items: _timeframes
                              .map(
                                (String tf) => DropdownMenuItem<String>(
                                  value: tf,
                                  child: Text(tf),
                                ),
                              )
                              .toList(),
                          onChanged: (String? value) {
                            if (value == null) {
                              return;
                            }
                            setState(() {
                              _timeframe = value;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _pollIntervalController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Poll interval (minutes)',
                            border: OutlineInputBorder(),
                          ),
                          validator: (String? value) {
                            final int? parsed = int.tryParse((value ?? '').trim());
                            if (parsed == null || parsed < 1 || parsed > 1440) {
                              return 'Enter a value between 1 and 1440.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _candlesLimitController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Candles limit',
                            border: OutlineInputBorder(),
                          ),
                          validator: (String? value) {
                            final int? parsed = int.tryParse((value ?? '').trim());
                            if (parsed == null || parsed < 60 || parsed > 5000) {
                              return 'Enter a value between 60 and 5000.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _strongConfidenceController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: const InputDecoration(
                            labelText: 'Strong signal confidence %',
                            border: OutlineInputBorder(),
                          ),
                          validator: (String? value) {
                            final double? parsed =
                                double.tryParse((value ?? '').trim());
                            if (parsed == null || parsed < 50 || parsed > 100) {
                              return 'Enter a value between 50 and 100.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _maxAlertsController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Max persisted alerts',
                            border: OutlineInputBorder(),
                          ),
                          validator: (String? value) {
                            final int? parsed = int.tryParse((value ?? '').trim());
                            if (parsed == null || parsed < 20 || parsed > 5000) {
                              return 'Enter a value between 20 and 5000.';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          value: _enableLocalNotifications,
                          title: const Text('Enable local notifications'),
                          onChanged: (bool value) {
                            setState(() {
                              _enableLocalNotifications = value;
                            });
                          },
                        ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          value: _autoStart,
                          title: const Text('Auto start monitor on open'),
                          onChanged: (bool value) {
                            setState(() {
                              _autoStart = value;
                            });
                          },
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: busy ? null : _resetToDefaults,
                                icon: const Icon(Icons.restart_alt),
                                label: const Text('Reset defaults'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: busy ? null : _saveSettings,
                                icon: busy
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.save),
                                label: const Text('Save'),
                              ),
                            ),
                          ],
                        ),
                        if (widget.allowOpenMonitor) ...<Widget>[
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: busy ? null : _openMonitor,
                              icon: const Icon(Icons.monitor),
                              label: const Text('Open live monitor'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Future<void> _saveSettings() async {
    if (!_isFormValid()) {
      return;
    }

    final ForexMonitorSettings settings = _buildSettingsFromForm();
    await _controller.saveSettings(settings);
    if (!mounted || _controller.lastError != null) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved')),
    );
  }

  Future<void> _openMonitor() async {
    if (!_isFormValid()) {
      return;
    }

    final ForexMonitorSettings settings = _buildSettingsFromForm();
    await _controller.saveSettings(settings);
    if (!mounted || _controller.lastError != null) {
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ForexLiveMonitorRoutePage.fromSettings(
          settings: settings,
          title: widget.monitorTitle,
        ),
      ),
    );
  }

  Future<void> _resetToDefaults() async {
    await _controller.resetToDefaults(persist: true);
    setState(() {
      _applySettingsToForm(_controller.settings);
    });
    if (!mounted || _controller.lastError != null) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Defaults restored')),
    );
  }

  bool _isFormValid() {
    final FormState? state = _formKey.currentState;
    if (state == null) {
      return false;
    }
    return state.validate();
  }

  ForexMonitorSettings _buildSettingsFromForm() {
    return ForexMonitorSettings(
      apiKey: _apiKeyController.text.trim(),
      symbol: _symbolController.text.trim().toUpperCase(),
      timeframe: _timeframe,
      pollIntervalMinutes: int.parse(_pollIntervalController.text.trim()),
      candlesLimit: int.parse(_candlesLimitController.text.trim()),
      strongSignalConfidence:
          double.parse(_strongConfidenceController.text.trim()),
      maxPersistedAlerts: int.parse(_maxAlertsController.text.trim()),
      enableLocalNotifications: _enableLocalNotifications,
      autoStart: _autoStart,
    );
  }

  void _applySettingsToForm(ForexMonitorSettings settings) {
    _apiKeyController.text = settings.apiKey;
    _symbolController.text = settings.symbol;
    _pollIntervalController.text = settings.pollIntervalMinutes.toString();
    _candlesLimitController.text = settings.candlesLimit.toString();
    _strongConfidenceController.text =
        settings.strongSignalConfidence.toStringAsFixed(0);
    _maxAlertsController.text = settings.maxPersistedAlerts.toString();
    _timeframe = _timeframes.contains(settings.timeframe)
        ? settings.timeframe
        : 'M15';
    _enableLocalNotifications = settings.enableLocalNotifications;
    _autoStart = settings.autoStart;
  }

  String? _validateSymbol(String? value) {
    final String raw = (value ?? '').trim().toUpperCase();
    if (raw.isEmpty) {
      return 'Symbol is required.';
    }

    final RegExp withSlash = RegExp(r'^[A-Z]{3}/[A-Z]{3}$');
    final RegExp compact = RegExp(r'^[A-Z]{6}$');
    if (!withSlash.hasMatch(raw) && !compact.hasMatch(raw)) {
      return 'Use format EURUSD or EUR/USD.';
    }

    return null;
  }
}

class _ErrorBanner extends StatelessWidget {
  final String error;
  final VoidCallback onDismiss;

  const _ErrorBanner({
    Key? key,
    required this.error,
    required this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Last operation error',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(error),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: onDismiss,
              child: const Text('Dismiss'),
            ),
          ),
        ],
      ),
    );
  }
}
