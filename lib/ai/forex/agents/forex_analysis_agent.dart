import 'dart:math';

import '../models/forex_analysis_report.dart';
import '../models/forex_candle.dart';
import '../services/technical_indicators.dart';

class ForexAgentConfig {
  final int minimumCandles;
  final int supportResistanceLookback;
  final int momentumWindow;

  const ForexAgentConfig({
    this.minimumCandles = 60,
    this.supportResistanceLookback = 20,
    this.momentumWindow = 5,
  });
}

class ForexAnalysisAgent {
  final ForexAgentConfig config;

  const ForexAnalysisAgent({
    this.config = const ForexAgentConfig(),
  });

  ForexAnalysisReport analyzeFromJson({
    required String symbol,
    required String timeframe,
    required List<Map<String, dynamic>> candlesJson,
  }) {
    final List<ForexCandle> candles = candlesJson
        .map((Map<String, dynamic> json) => ForexCandle.fromJson(json))
        .toList(growable: false);

    return analyze(
      symbol: symbol,
      timeframe: timeframe,
      candles: candles,
    );
  }

  ForexAnalysisReport analyze({
    required String symbol,
    required String timeframe,
    required List<ForexCandle> candles,
  }) {
    if (candles.length < config.minimumCandles) {
      throw ArgumentError(
        'Not enough candles. Required at least ${config.minimumCandles}, '
        'received ${candles.length}.',
      );
    }

    final List<double> closes =
        candles.map((ForexCandle candle) => candle.close).toList(growable: false);

    final double latestClose = closes.last;
    final double? sma20 = TechnicalIndicators.sma(closes, 20);
    final double? sma50 = TechnicalIndicators.sma(closes, 50);
    final double? ema20 = TechnicalIndicators.ema(closes, 20);
    final double? rsi14 = TechnicalIndicators.rsi(closes, period: 14);
    final MacdResult? macd = TechnicalIndicators.macd(closes);
    final double? atr14 = TechnicalIndicators.atr(candles, period: 14);
    final double? support = TechnicalIndicators.support(
      candles,
      lookback: config.supportResistanceLookback,
    );
    final double? resistance = TechnicalIndicators.resistance(
      candles,
      lookback: config.supportResistanceLookback,
    );

    int score = 0;
    final List<String> reasons = <String>[];

    if (sma20 != null && sma50 != null) {
      if (sma20 > sma50) {
        score += 2;
        reasons.add('Short-term trend is bullish (SMA20 above SMA50).');
      } else if (sma20 < sma50) {
        score -= 2;
        reasons.add('Short-term trend is bearish (SMA20 below SMA50).');
      }
    }

    if (ema20 != null) {
      if (latestClose > ema20) {
        score += 1;
        reasons.add('Price is trading above EMA20.');
      } else if (latestClose < ema20) {
        score -= 1;
        reasons.add('Price is trading below EMA20.');
      }
    }

    if (rsi14 != null) {
      if (rsi14 <= 30) {
        score += 1;
        reasons.add('RSI indicates oversold conditions.');
      } else if (rsi14 >= 70) {
        score -= 1;
        reasons.add('RSI indicates overbought conditions.');
      } else if (rsi14 > 50) {
        score += 1;
        reasons.add('RSI is above 50, momentum favors buyers.');
      } else {
        score -= 1;
        reasons.add('RSI is below 50, momentum favors sellers.');
      }
    }

    if (macd != null) {
      if (macd.line > macd.signal) {
        score += 1;
        reasons.add('MACD line is above signal line.');
      } else if (macd.line < macd.signal) {
        score -= 1;
        reasons.add('MACD line is below signal line.');
      }
    }

    final double momentum = _priceMomentum(closes, config.momentumWindow);
    if (momentum > 0) {
      score += 1;
      reasons.add('Recent candles show positive momentum.');
    } else if (momentum < 0) {
      score -= 1;
      reasons.add('Recent candles show negative momentum.');
    }

    final ForexSignal signal = _resolveSignal(score);
    final double confidence = _confidenceFromScore(
      score: score,
      latestPrice: latestClose,
      atr14: atr14,
      rsi14: rsi14,
    );

    final String riskNote = _buildRiskNote(
      signal: signal,
      latestPrice: latestClose,
      support: support,
      resistance: resistance,
      atr14: atr14,
    );

    return ForexAnalysisReport(
      symbol: symbol,
      timeframe: timeframe,
      signal: signal,
      confidence: confidence,
      reasons: reasons,
      support: support,
      resistance: resistance,
      riskNote: riskNote,
      indicators: IndicatorSnapshot(
        sma20: sma20,
        sma50: sma50,
        ema20: ema20,
        rsi14: rsi14,
        macdLine: macd?.line,
        macdSignal: macd?.signal,
        macdHistogram: macd?.histogram,
        atr14: atr14,
      ),
      generatedAt: DateTime.now(),
    );
  }

  ForexSignal _resolveSignal(int score) {
    if (score >= 3) {
      return ForexSignal.buy;
    }
    if (score <= -3) {
      return ForexSignal.sell;
    }
    return ForexSignal.neutral;
  }

  double _confidenceFromScore({
    required int score,
    required double latestPrice,
    required double? atr14,
    required double? rsi14,
  }) {
    double confidence = 35.0 + (score.abs() * 9.0);

    if (rsi14 != null && (rsi14 <= 25 || rsi14 >= 75)) {
      confidence += 4.0;
    }

    // Higher ATR/price ratio means more volatility and lower confidence.
    if (atr14 != null && latestPrice > 0) {
      final double atrRatio = atr14 / latestPrice;
      if (atrRatio > 0.015) {
        confidence -= 6.0;
      } else if (atrRatio < 0.005) {
        confidence += 2.0;
      }
    }

    return confidence.clamp(20.0, 95.0).toDouble();
  }

  double _priceMomentum(List<double> closes, int window) {
    if (window <= 0 || closes.length <= window) {
      return 0.0;
    }

    final double past = closes[closes.length - window - 1];
    final double latest = closes.last;
    if (past == 0) {
      return 0.0;
    }

    return ((latest - past) / past) * 100.0;
  }

  String _buildRiskNote({
    required ForexSignal signal,
    required double latestPrice,
    required double? support,
    required double? resistance,
    required double? atr14,
  }) {
    final double suggestedBuffer = atr14 != null ? atr14 * 1.5 : latestPrice * 0.003;

    if (signal == ForexSignal.buy && support != null) {
      final double stopLoss = max(0.0, support - suggestedBuffer);
      return 'Consider stop-loss below support near ${stopLoss.toStringAsFixed(5)}.';
    }

    if (signal == ForexSignal.sell && resistance != null) {
      final double stopLoss = resistance + suggestedBuffer;
      return 'Consider stop-loss above resistance near ${stopLoss.toStringAsFixed(5)}.';
    }

    return 'Signal is neutral; wait for clearer confirmation before entering a trade.';
  }
}
