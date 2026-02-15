import '../models/forex_candle.dart';

class ForexDataSourceException implements Exception {
  final String message;

  const ForexDataSourceException(this.message);

  @override
  String toString() => 'ForexDataSourceException: $message';
}

abstract class ForexMarketDataSource {
  Future<List<ForexCandle>> fetchCandles({
    required String symbol,
    required String timeframe,
    int limit = 200,
  });
}
