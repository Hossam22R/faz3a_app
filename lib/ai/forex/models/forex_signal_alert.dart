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
}
