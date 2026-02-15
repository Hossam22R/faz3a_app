enum ForexSignal { buy, sell, neutral }

class IndicatorSnapshot {
  final double? sma20;
  final double? sma50;
  final double? ema20;
  final double? rsi14;
  final double? macdLine;
  final double? macdSignal;
  final double? macdHistogram;
  final double? atr14;

  const IndicatorSnapshot({
    this.sma20,
    this.sma50,
    this.ema20,
    this.rsi14,
    this.macdLine,
    this.macdSignal,
    this.macdHistogram,
    this.atr14,
  });

  Map<String, dynamic> toJson() {
    return {
      'sma20': sma20,
      'sma50': sma50,
      'ema20': ema20,
      'rsi14': rsi14,
      'macdLine': macdLine,
      'macdSignal': macdSignal,
      'macdHistogram': macdHistogram,
      'atr14': atr14,
    };
  }
}

class ForexAnalysisReport {
  final String symbol;
  final String timeframe;
  final ForexSignal signal;
  final double confidence;
  final List<String> reasons;
  final double? support;
  final double? resistance;
  final String riskNote;
  final IndicatorSnapshot indicators;
  final DateTime generatedAt;

  const ForexAnalysisReport({
    required this.symbol,
    required this.timeframe,
    required this.signal,
    required this.confidence,
    required this.reasons,
    required this.support,
    required this.resistance,
    required this.riskNote,
    required this.indicators,
    required this.generatedAt,
  });

  String get signalLabel {
    switch (signal) {
      case ForexSignal.buy:
        return 'BUY';
      case ForexSignal.sell:
        return 'SELL';
      case ForexSignal.neutral:
        return 'NEUTRAL';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'timeframe': timeframe,
      'signal': signalLabel,
      'confidence': confidence,
      'reasons': reasons,
      'support': support,
      'resistance': resistance,
      'riskNote': riskNote,
      'indicators': indicators.toJson(),
      'generatedAt': generatedAt.toIso8601String(),
    };
  }
}
