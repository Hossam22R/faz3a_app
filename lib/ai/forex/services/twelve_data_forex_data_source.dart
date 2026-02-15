import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/forex_candle.dart';
import 'forex_market_data_source.dart';

class TwelveDataForexDataSource implements ForexMarketDataSource {
  final String apiKey;
  final String baseUrl;
  final http.Client _client;

  TwelveDataForexDataSource({
    required this.apiKey,
    http.Client? client,
    this.baseUrl = 'https://api.twelvedata.com',
  }) : _client = client ?? http.Client();

  factory TwelveDataForexDataSource.fromEnvironment({
    http.Client? client,
    String baseUrl = 'https://api.twelvedata.com',
  }) {
    const String keyName = 'TWELVE_DATA_API_KEY';
    const String key = String.fromEnvironment(keyName);
    if (key.isEmpty) {
      throw ArgumentError(
        'Missing API key in --dart-define=$keyName=YOUR_API_KEY',
      );
    }

    return TwelveDataForexDataSource(
      apiKey: key,
      client: client,
      baseUrl: baseUrl,
    );
  }

  @override
  Future<List<ForexCandle>> fetchCandles({
    required String symbol,
    required String timeframe,
    int limit = 200,
  }) async {
    if (limit <= 0) {
      throw ArgumentError('limit must be greater than zero.');
    }

    final String normalizedSymbol = _normalizeSymbol(symbol);
    final String interval = _normalizeInterval(timeframe);

    final Uri uri = Uri.parse('$baseUrl/time_series').replace(
      queryParameters: <String, String>{
        'symbol': normalizedSymbol,
        'interval': interval,
        'outputsize': '$limit',
        'timezone': 'UTC',
        'apikey': apiKey,
      },
    );

    final http.Response response = await _client.get(uri);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ForexDataSourceException(
        'HTTP ${response.statusCode} while fetching forex candles.',
      );
    }

    final Map<String, dynamic> data =
        jsonDecode(response.body) as Map<String, dynamic>;

    final String status = data['status']?.toString().toLowerCase() ?? '';
    if (status == 'error') {
      final String message = data['message']?.toString() ??
          'Unknown error from Twelve Data API.';
      throw ForexDataSourceException(message);
    }

    final dynamic rawValues = data['values'];
    if (rawValues is! List) {
      throw const ForexDataSourceException(
        'Twelve Data response does not contain candles list.',
      );
    }

    final List<ForexCandle> candles = <ForexCandle>[];
    for (final dynamic item in rawValues) {
      if (item is! Map<String, dynamic>) {
        continue;
      }

      candles.add(
        ForexCandle(
          time: _parseDateTime(item['datetime']),
          open: _toDouble(item['open']),
          high: _toDouble(item['high']),
          low: _toDouble(item['low']),
          close: _toDouble(item['close']),
          volume: item.containsKey('volume') ? _toDouble(item['volume']) : 0.0,
        ),
      );
    }

    if (candles.isEmpty) {
      throw const ForexDataSourceException(
        'No candle data returned from Twelve Data API.',
      );
    }

    candles.sort((ForexCandle a, ForexCandle b) => a.time.compareTo(b.time));
    return candles;
  }

  void dispose() {
    _client.close();
  }

  String _normalizeSymbol(String symbol) {
    final String cleaned = symbol.replaceAll(' ', '').toUpperCase();
    if (cleaned.isEmpty) {
      throw ArgumentError('symbol must not be empty.');
    }

    if (cleaned.contains('/')) {
      return cleaned;
    }

    if (cleaned.length == 6) {
      return '${cleaned.substring(0, 3)}/${cleaned.substring(3)}';
    }

    throw ArgumentError(
      'symbol must be like EURUSD or EUR/USD.',
    );
  }

  String _normalizeInterval(String timeframe) {
    final String key = timeframe.trim().toUpperCase();
    const Map<String, String> intervalMap = <String, String>{
      'M1': '1min',
      'M5': '5min',
      'M15': '15min',
      'M30': '30min',
      'M45': '45min',
      'H1': '1h',
      'H2': '2h',
      'H4': '4h',
      'H8': '8h',
      'H12': '12h',
      'D1': '1day',
      'W1': '1week',
      'MN1': '1month',
    };

    return intervalMap[key] ?? timeframe;
  }

  DateTime _parseDateTime(dynamic value) {
    final String raw = value.toString().trim();
    if (raw.isEmpty) {
      throw const ForexDataSourceException('Invalid candle datetime.');
    }

    DateTime? parsed;
    final bool hasOffset = raw.contains('Z') || raw.contains('+');

    if (hasOffset) {
      parsed = DateTime.tryParse(raw);
    }

    if (parsed == null) {
      final String normalized = raw.replaceFirst(' ', 'T');
      if (normalized.length == 10) {
        parsed = DateTime.tryParse('${normalized}T00:00:00Z');
      } else {
        parsed = DateTime.tryParse('${normalized}Z') ??
            DateTime.tryParse(normalized);
      }
    }

    if (parsed == null) {
      throw ForexDataSourceException('Invalid candle datetime: $raw');
    }

    return parsed.isUtc ? parsed : parsed.toUtc();
  }

  double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.parse(value.toString());
  }
}
