import 'dart:math';

import '../models/forex_candle.dart';

class MacdResult {
  final double line;
  final double signal;
  final double histogram;

  const MacdResult({
    required this.line,
    required this.signal,
    required this.histogram,
  });
}

class TechnicalIndicators {
  const TechnicalIndicators._();

  static double? sma(List<double> values, int period) {
    if (period <= 0 || values.length < period) {
      return null;
    }

    final double sum =
        values.sublist(values.length - period).reduce((a, b) => a + b);
    return sum / period;
  }

  static double? ema(List<double> values, int period) {
    if (period <= 0 || values.length < period) {
      return null;
    }

    final double multiplier = 2.0 / (period + 1);
    double currentEma = _average(values.sublist(0, period));

    for (int i = period; i < values.length; i++) {
      currentEma = ((values[i] - currentEma) * multiplier) + currentEma;
    }

    return currentEma;
  }

  static double? rsi(List<double> closes, {int period = 14}) {
    if (period <= 0 || closes.length < period + 1) {
      return null;
    }

    double gains = 0.0;
    double losses = 0.0;

    for (int i = 1; i <= period; i++) {
      final double change = closes[i] - closes[i - 1];
      if (change >= 0) {
        gains += change;
      } else {
        losses += change.abs();
      }
    }

    double averageGain = gains / period;
    double averageLoss = losses / period;

    for (int i = period + 1; i < closes.length; i++) {
      final double change = closes[i] - closes[i - 1];
      final double gain = max(change, 0);
      final double loss = max(-change, 0);

      averageGain = ((averageGain * (period - 1)) + gain) / period;
      averageLoss = ((averageLoss * (period - 1)) + loss) / period;
    }

    if (averageLoss == 0) {
      return 100.0;
    }

    final double rs = averageGain / averageLoss;
    return 100.0 - (100.0 / (1 + rs));
  }

  static MacdResult? macd(
    List<double> closes, {
    int fastPeriod = 12,
    int slowPeriod = 26,
    int signalPeriod = 9,
  }) {
    if (fastPeriod <= 0 ||
        slowPeriod <= 0 ||
        signalPeriod <= 0 ||
        fastPeriod >= slowPeriod ||
        closes.length < slowPeriod + signalPeriod) {
      return null;
    }

    final List<double?> fastSeries = _emaSeries(closes, fastPeriod);
    final List<double?> slowSeries = _emaSeries(closes, slowPeriod);

    final List<double> macdSeries = <double>[];
    for (int i = 0; i < closes.length; i++) {
      final double? fast = fastSeries[i];
      final double? slow = slowSeries[i];

      if (fast != null && slow != null) {
        macdSeries.add(fast - slow);
      }
    }

    if (macdSeries.length < signalPeriod) {
      return null;
    }

    final double macdLine = macdSeries.last;
    final double signalLine = ema(macdSeries, signalPeriod)!;

    return MacdResult(
      line: macdLine,
      signal: signalLine,
      histogram: macdLine - signalLine,
    );
  }

  static double? atr(List<ForexCandle> candles, {int period = 14}) {
    if (period <= 0 || candles.length < period + 1) {
      return null;
    }

    final List<double> trueRanges = <double>[];
    for (int i = 1; i < candles.length; i++) {
      final ForexCandle current = candles[i];
      final ForexCandle previous = candles[i - 1];

      final double highLow = current.high - current.low;
      final double highClose = (current.high - previous.close).abs();
      final double lowClose = (current.low - previous.close).abs();

      trueRanges.add(max(highLow, max(highClose, lowClose)));
    }

    if (trueRanges.length < period) {
      return null;
    }

    double currentAtr = _average(trueRanges.sublist(0, period));
    for (int i = period; i < trueRanges.length; i++) {
      currentAtr = ((currentAtr * (period - 1)) + trueRanges[i]) / period;
    }

    return currentAtr;
  }

  static double? support(List<ForexCandle> candles, {int lookback = 20}) {
    if (candles.isEmpty) {
      return null;
    }

    final List<ForexCandle> slice = _tailSlice(candles, lookback);
    double support = slice.first.low;

    for (final ForexCandle candle in slice) {
      support = min(support, candle.low);
    }

    return support;
  }

  static double? resistance(List<ForexCandle> candles, {int lookback = 20}) {
    if (candles.isEmpty) {
      return null;
    }

    final List<ForexCandle> slice = _tailSlice(candles, lookback);
    double resistance = slice.first.high;

    for (final ForexCandle candle in slice) {
      resistance = max(resistance, candle.high);
    }

    return resistance;
  }

  static List<double?> _emaSeries(List<double> values, int period) {
    final List<double?> result = List<double?>.filled(values.length, null);
    if (period <= 0 || values.length < period) {
      return result;
    }

    final double multiplier = 2.0 / (period + 1);
    double currentEma = _average(values.sublist(0, period));
    result[period - 1] = currentEma;

    for (int i = period; i < values.length; i++) {
      currentEma = ((values[i] - currentEma) * multiplier) + currentEma;
      result[i] = currentEma;
    }

    return result;
  }

  static double _average(List<double> values) {
    if (values.isEmpty) {
      return 0.0;
    }

    return values.reduce((a, b) => a + b) / values.length;
  }

  static List<ForexCandle> _tailSlice(List<ForexCandle> candles, int lookback) {
    if (lookback <= 0 || candles.length <= lookback) {
      return candles;
    }

    return candles.sublist(candles.length - lookback);
  }
}
