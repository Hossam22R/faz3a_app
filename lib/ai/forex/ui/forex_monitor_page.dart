import 'package:flutter/material.dart';

import '../controllers/live_forex_monitor_controller.dart';
import '../models/forex_analysis_report.dart';
import '../models/forex_signal_alert.dart';

class ForexMonitorPage extends StatefulWidget {
  final LiveForexMonitorController controller;
  final String title;
  final bool autoStart;
  final bool disposeController;

  const ForexMonitorPage({
    Key? key,
    required this.controller,
    this.title = 'Forex Live Monitor',
    this.autoStart = true,
    this.disposeController = false,
  }) : super(key: key);

  @override
  State<ForexMonitorPage> createState() => _ForexMonitorPageState();
}

class _ForexMonitorPageState extends State<ForexMonitorPage> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
    widget.controller.reloadHistory();
    if (widget.autoStart) {
      widget.controller.start(runImmediately: true);
    }
  }

  @override
  void didUpdateWidget(covariant ForexMonitorPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
      widget.controller.reloadHistory();
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    if (widget.disposeController) {
      widget.controller.dispose();
    }
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final ForexAnalysisReport? report = widget.controller.latestReport;
    final Object? error = widget.controller.lastError;
    final List<ForexSignalAlert> history = widget.controller.alertHistory;
    final String symbol = widget.controller.monitor.symbol;
    final String timeframe = widget.controller.monitor.timeframe;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            tooltip: 'Refresh now',
            icon: const Icon(Icons.refresh),
            onPressed: _refreshNow,
          ),
          IconButton(
            tooltip: 'Clear alert history',
            icon: const Icon(Icons.delete_outline),
            onPressed: _clearHistory,
          ),
          IconButton(
            tooltip: widget.controller.isRunning ? 'Stop monitor' : 'Start monitor',
            icon: Icon(
              widget.controller.isRunning ? Icons.pause_circle : Icons.play_circle,
            ),
            onPressed: _toggleMonitor,
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(12),
            child: _buildStatusCard(
              symbol: symbol,
              timeframe: timeframe,
              report: report,
            ),
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Material(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                child: ListTile(
                  leading: const Icon(Icons.error_outline, color: Colors.red),
                  title: const Text('Latest error'),
                  subtitle: Text(error.toString()),
                  trailing: TextButton(
                    onPressed: widget.controller.clearLastError,
                    child: const Text('Dismiss'),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 8),
          const Divider(height: 1),
          Expanded(
            child: history.isEmpty
                ? const Center(
                    child: Text('No alerts yet. Waiting for signal changes...'),
                  )
                : ListView.separated(
                    itemCount: history.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, int index) {
                      final ForexSignalAlert alert = history[index];
                      return ListTile(
                        leading: Icon(
                          _iconForSignal(alert.signal),
                          color: _colorForSignal(alert.signal),
                        ),
                        title: Text(alert.message),
                        subtitle: Text(
                          '${alert.symbol} ${alert.timeframe} • ${_formatDateTime(alert.createdAt)}',
                        ),
                        trailing: Text(
                          '${alert.confidence.toStringAsFixed(1)}%',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard({
    required String symbol,
    required String timeframe,
    required ForexAnalysisReport? report,
  }) {
    if (report == null) {
      return Material(
        elevation: 1,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: <Widget>[
              const CircularProgressIndicator(strokeWidth: 2),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Monitoring $symbol $timeframe and waiting for first analysis...',
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Material(
      elevation: 1,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Icon(
                  _iconForSignal(report.signal),
                  color: _colorForSignal(report.signal),
                ),
                const SizedBox(width: 8),
                Text(
                  '${report.symbol} ${report.timeframe} • ${report.signalLabel}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Text(
                  '${report.confidence.toStringAsFixed(1)}%',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Updated: ${_formatDateTime(report.generatedAt)}'),
            const SizedBox(height: 4),
            Text('Risk note: ${report.riskNote}'),
            if (report.support != null || report.resistance != null) ...<Widget>[
              const SizedBox(height: 6),
              Text(
                'Support: ${report.support?.toStringAsFixed(5) ?? '-'} | '
                'Resistance: ${report.resistance?.toStringAsFixed(5) ?? '-'}',
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _refreshNow() async {
    await widget.controller.refreshNow();
  }

  Future<void> _clearHistory() async {
    await widget.controller.clearAlertHistory();
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Alert history cleared')),
    );
  }

  void _toggleMonitor() {
    if (widget.controller.isRunning) {
      widget.controller.stop();
    } else {
      widget.controller.start(runImmediately: true);
    }
  }

  IconData _iconForSignal(ForexSignal signal) {
    switch (signal) {
      case ForexSignal.buy:
        return Icons.trending_up;
      case ForexSignal.sell:
        return Icons.trending_down;
      case ForexSignal.neutral:
        return Icons.remove;
    }
  }

  Color _colorForSignal(ForexSignal signal) {
    switch (signal) {
      case ForexSignal.buy:
        return Colors.green;
      case ForexSignal.sell:
        return Colors.red;
      case ForexSignal.neutral:
        return Colors.blueGrey;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final DateTime local = dateTime.toLocal();
    final String mm = local.month.toString().padLeft(2, '0');
    final String dd = local.day.toString().padLeft(2, '0');
    final String hh = local.hour.toString().padLeft(2, '0');
    final String min = local.minute.toString().padLeft(2, '0');
    return '${local.year}-$mm-$dd $hh:$min';
  }
}
