import 'package:flutter/material.dart';

import '../controllers/forex_watchlist_controller.dart';
import '../models/forex_analysis_report.dart';
import '../models/forex_watchlist_item.dart';

class ForexWatchlistPage extends StatefulWidget {
  final ForexWatchlistController? controller;
  final bool disposeController;
  final String title;
  final ValueChanged<List<ForexWatchlistItem>>? onWatchlistChanged;
  final bool autoLoad;
  final bool emitInitialChange;
  final Map<String, ForexAnalysisReport> latestReportsByItemId;
  final bool scannerRunning;
  final String? scannerStatusMessage;

  const ForexWatchlistPage({
    Key? key,
    this.controller,
    this.disposeController = true,
    this.title = 'Forex Watchlist',
    this.onWatchlistChanged,
    this.autoLoad = true,
    this.emitInitialChange = false,
    this.latestReportsByItemId = const <String, ForexAnalysisReport>{},
    this.scannerRunning = false,
    this.scannerStatusMessage,
  }) : super(key: key);

  @override
  State<ForexWatchlistPage> createState() => _ForexWatchlistPageState();
}

class _ForexWatchlistPageState extends State<ForexWatchlistPage> {
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

  late final ForexWatchlistController _controller;
  late final bool _ownsController;
  bool _initialLoadDone = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? ForexWatchlistController();
    _ownsController = widget.controller == null;
    _controller.addListener(_onControllerChanged);
    if (widget.autoLoad) {
      _load();
    } else {
      _initialLoadDone = true;
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    if (_ownsController && widget.disposeController) {
      _controller.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    await _controller.load();
    if (!mounted) {
      return;
    }
    setState(() {
      _initialLoadDone = true;
    });
    if (widget.emitInitialChange) {
      _emitChanged();
    }
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final Object? error = _controller.lastError;
    final bool busy = _controller.isBusy;
    final List<ForexWatchlistItem> items = _controller.items;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            tooltip: 'Add pair',
            icon: const Icon(Icons.add),
            onPressed: busy ? null : _addPair,
          ),
        ],
      ),
      body: !_initialLoadDone
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: <Widget>[
                if (widget.scannerStatusMessage != null)
                  _ScannerStatusBanner(
                    isRunning: widget.scannerRunning,
                    message: widget.scannerStatusMessage!,
                  ),
                if (error != null)
                  _InlineErrorBanner(
                    error: error.toString(),
                    onDismiss: _controller.clearError,
                  ),
                Expanded(
                  child: items.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                          itemCount: items.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (_, int index) {
                            final ForexWatchlistItem item = items[index];
                            final ForexAnalysisReport? latestReport =
                                widget.latestReportsByItemId[item.id];
                            final String signalText = latestReport == null
                                ? 'no recent scan'
                                : '${latestReport.signalLabel} '
                                    '${latestReport.confidence.toStringAsFixed(1)}%';
                            return ListTile(
                              leading: Icon(
                                item.isPrimary ? Icons.star : Icons.star_border,
                                color: item.isPrimary ? Colors.amber : Colors.grey,
                              ),
                              title: Text(item.displayName),
                              subtitle: Text(
                                '${item.symbol} • ${item.timeframe}'
                                '${item.isEnabled ? '' : ' • disabled'}'
                                ' • $signalText',
                              ),
                              onTap: () => _editPair(item),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  IconButton(
                                    tooltip: 'Set as primary',
                                    icon: Icon(
                                      item.isPrimary
                                          ? Icons.star
                                          : Icons.star_outline,
                                    ),
                                    onPressed: busy
                                        ? null
                                        : () => _setPrimary(item.id),
                                  ),
                                  IconButton(
                                    tooltip: item.isEnabled ? 'Disable' : 'Enable',
                                    icon: Icon(
                                      item.isEnabled
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: busy
                                        ? null
                                        : () => _setEnabled(item.id, !item.isEnabled),
                                  ),
                                  IconButton(
                                    tooltip: 'Delete',
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: busy
                                        ? null
                                        : () => _confirmDelete(item),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: busy ? null : _addPair,
        icon: const Icon(Icons.add),
        label: const Text('Add pair'),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(Icons.playlist_add_check_circle_outlined, size: 48),
            const SizedBox(height: 12),
            const Text(
              'Watchlist is empty. Add your forex pairs to monitor multiple symbols.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _addPair,
              icon: const Icon(Icons.add),
              label: const Text('Add first pair'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addPair() async {
    final ForexWatchlistItem? result = await _showPairEditorDialog();
    if (result == null) {
      return;
    }
    await _controller.add(result);
    _emitChanged();
  }

  Future<void> _editPair(ForexWatchlistItem current) async {
    final ForexWatchlistItem? result = await _showPairEditorDialog(existing: current);
    if (result == null) {
      return;
    }
    await _controller.upsert(result);
    _emitChanged();
  }

  Future<void> _setPrimary(String id) async {
    await _controller.setPrimary(id);
    _emitChanged();
  }

  Future<void> _setEnabled(String id, bool enabled) async {
    await _controller.setEnabled(id, enabled);
    _emitChanged();
  }

  Future<void> _confirmDelete(ForexWatchlistItem item) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete pair'),
          content: Text('Remove ${item.symbol} ${item.timeframe} from watchlist?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) {
      return;
    }

    await _controller.removeById(item.id);
    _emitChanged();
  }

  Future<ForexWatchlistItem?> _showPairEditorDialog({
    ForexWatchlistItem? existing,
  }) async {
    final TextEditingController symbolController = TextEditingController(
      text: existing?.symbol ?? '',
    );
    final TextEditingController labelController = TextEditingController(
      text: existing?.label ?? '',
    );

    String timeframe = existing?.timeframe ?? 'M15';
    bool isEnabled = existing?.isEnabled ?? true;
    bool isPrimary = existing?.isPrimary ?? false;
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    final ForexWatchlistItem? result = await showDialog<ForexWatchlistItem>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: Text(existing == null ? 'Add watchlist pair' : 'Edit pair'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextFormField(
                        controller: symbolController,
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(
                          labelText: 'Symbol',
                          hintText: 'EURUSD or EUR/USD',
                        ),
                        validator: _validateSymbol,
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: _timeframes.contains(timeframe) ? timeframe : 'M15',
                        decoration: const InputDecoration(
                          labelText: 'Timeframe',
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
                          setDialogState(() {
                            timeframe = value;
                          });
                        },
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: labelController,
                        decoration: const InputDecoration(
                          labelText: 'Label (optional)',
                          hintText: 'e.g. London Session Pair',
                        ),
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: isEnabled,
                        title: const Text('Enabled'),
                        onChanged: (bool value) {
                          setDialogState(() {
                            isEnabled = value;
                          });
                        },
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        value: isPrimary,
                        title: const Text('Primary pair'),
                        onChanged: (bool value) {
                          setDialogState(() {
                            isPrimary = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final FormState? state = formKey.currentState;
                    if (state == null || !state.validate()) {
                      return;
                    }

                    final String symbol = symbolController.text.trim().toUpperCase();
                    final ForexWatchlistItem item = existing == null
                        ? ForexWatchlistItem.create(
                            symbol: symbol,
                            timeframe: timeframe,
                            label: labelController.text.trim(),
                            isEnabled: isEnabled,
                            isPrimary: isPrimary,
                          )
                        : existing.copyWith(
                            symbol: symbol,
                            timeframe: timeframe,
                            label: labelController.text.trim(),
                            isEnabled: isEnabled,
                            isPrimary: isPrimary,
                          );
                    Navigator.of(context).pop(item);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );

    symbolController.dispose();
    labelController.dispose();
    return result;
  }

  void _emitChanged() {
    widget.onWatchlistChanged?.call(_controller.items);
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

class _InlineErrorBanner extends StatelessWidget {
  final String error;
  final VoidCallback onDismiss;

  const _InlineErrorBanner({
    Key? key,
    required this.error,
    required this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.red.shade50,
      child: ListTile(
        leading: const Icon(Icons.error_outline, color: Colors.red),
        title: const Text('Watchlist error'),
        subtitle: Text(error),
        trailing: TextButton(
          onPressed: onDismiss,
          child: const Text('Dismiss'),
        ),
      ),
    );
  }
}

class _ScannerStatusBanner extends StatelessWidget {
  final bool isRunning;
  final String message;

  const _ScannerStatusBanner({
    Key? key,
    required this.isRunning,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color color = isRunning ? Colors.blue.shade50 : Colors.orange.shade50;
    final IconData icon = isRunning ? Icons.sync : Icons.pause_circle_outline;

    return Material(
      color: color,
      child: ListTile(
        leading: Icon(icon),
        title: Text(message),
      ),
    );
  }
}
