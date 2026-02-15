class ForexCandle {
  final DateTime time;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;

  const ForexCandle({
    required this.time,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    this.volume = 0.0,
  })  : assert(high >= low),
        assert(high >= open && high >= close),
        assert(low <= open && low <= close);

  bool get isBullish => close > open;
  bool get isBearish => close < open;
  double get bodySize => (close - open).abs();
  double get fullRange => high - low;
  double get typicalPrice => (high + low + close) / 3.0;

  factory ForexCandle.fromJson(Map<String, dynamic> json) {
    return ForexCandle(
      time: DateTime.parse(json['time'].toString()),
      open: _toDouble(json['open']),
      high: _toDouble(json['high']),
      low: _toDouble(json['low']),
      close: _toDouble(json['close']),
      volume: json.containsKey('volume') ? _toDouble(json['volume']) : 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time': time.toIso8601String(),
      'open': open,
      'high': high,
      'low': low,
      'close': close,
      'volume': volume,
    };
  }

  static double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.parse(value.toString());
  }
}
