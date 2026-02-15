import 'forex_analysis_report.dart';

enum ForexAlertType { signalChanged, strongSignal }

class ForexSignalAlert {
  final String symbol;
  final String timeframe;
  final ForexSignal signal;
  final ForexSignal? previousSignal;
  final ForexAlertType type;
  final double confidence;
  final String message;
  final List<String> reasons;
  final DateTime createdAt;

  const ForexSignalAlert({
    required this.symbol,
    required this.timeframe,
    required this.signal,
    required this.previousSignal,
    required this.type,
    required this.confidence,
    required this.message,
    required this.reasons,
    required this.createdAt,
  });

  factory ForexSignalAlert.fromJson(Map<String, dynamic> json) {
    final String signalRaw = json['signal']?.toString() ?? 'NEUTRAL';
    final String? previousSignalRaw = json['previousSignal']?.toString();
    final String typeRaw = json['type']?.toString() ?? 'signalChanged';

    return ForexSignalAlert(
      symbol: json['symbol']?.toString() ?? '',
      timeframe: json['timeframe']?.toString() ?? '',
      signal: _parseSignal(signalRaw),
      previousSignal:
          previousSignalRaw == null ? null : _parseSignal(previousSignalRaw),
      type: _parseType(typeRaw),
      confidence: _toDouble(json['confidence']),
      message: json['message']?.toString() ?? '',
      reasons: _toStringList(json['reasons']),
      createdAt: _parseDateTime(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'timeframe': timeframe,
      'signal': _signalLabel(signal),
      'previousSignal': previousSignal != null ? _signalLabel(previousSignal!) : null,
      'type': _typeLabel(type),
      'confidence': confidence,
      'message': message,
      'reasons': reasons,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String _signalLabel(ForexSignal value) {
    switch (value) {
      case ForexSignal.buy:
        return 'BUY';
      case ForexSignal.sell:
        return 'SELL';
      case ForexSignal.neutral:
        return 'NEUTRAL';
    }
  }

  String _typeLabel(ForexAlertType value) {
    switch (value) {
      case ForexAlertType.signalChanged:
        return 'signalChanged';
      case ForexAlertType.strongSignal:
        return 'strongSignal';
    }
  }

  static ForexSignal _parseSignal(String raw) {
    final String normalized = raw.trim().toUpperCase();
    switch (normalized) {
      case 'BUY':
        return ForexSignal.buy;
      case 'SELL':
        return ForexSignal.sell;
      case 'NEUTRAL':
      default:
        return ForexSignal.neutral;
    }
  }

  static ForexAlertType _parseType(String raw) {
    final String normalized = raw.trim();
    if (normalized == 'strongSignal') {
      return ForexAlertType.strongSignal;
    }

    return ForexAlertType.signalChanged;
  }

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  static DateTime _parseDateTime(dynamic value) {
    final String raw = value?.toString() ?? '';
    final DateTime? parsed = DateTime.tryParse(raw);
    return parsed ?? DateTime.now().toUtc();
  }

  static List<String> _toStringList(dynamic value) {
    if (value is List) {
      return value.map((dynamic item) => item.toString()).toList(growable: false);
    }
    return const <String>[];
  }
}
