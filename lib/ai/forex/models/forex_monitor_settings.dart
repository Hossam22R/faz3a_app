class ForexMonitorSettings {
  final String apiKey;
  final String symbol;
  final String timeframe;
  final int pollIntervalMinutes;
  final int candlesLimit;
  final double strongSignalConfidence;
  final int maxPersistedAlerts;
  final bool enableLocalNotifications;
  final bool autoStart;

  const ForexMonitorSettings({
    required this.apiKey,
    required this.symbol,
    required this.timeframe,
    required this.pollIntervalMinutes,
    required this.candlesLimit,
    required this.strongSignalConfidence,
    required this.maxPersistedAlerts,
    required this.enableLocalNotifications,
    required this.autoStart,
  });

  const ForexMonitorSettings.defaults()
      : apiKey = '',
        symbol = 'EURUSD',
        timeframe = 'M15',
        pollIntervalMinutes = 5,
        candlesLimit = 180,
        strongSignalConfidence = 72.0,
        maxPersistedAlerts = 300,
        enableLocalNotifications = true,
        autoStart = true;

  Duration get pollInterval => Duration(minutes: pollIntervalMinutes);

  ForexMonitorSettings copyWith({
    String? apiKey,
    String? symbol,
    String? timeframe,
    int? pollIntervalMinutes,
    int? candlesLimit,
    double? strongSignalConfidence,
    int? maxPersistedAlerts,
    bool? enableLocalNotifications,
    bool? autoStart,
  }) {
    return ForexMonitorSettings(
      apiKey: apiKey ?? this.apiKey,
      symbol: symbol ?? this.symbol,
      timeframe: timeframe ?? this.timeframe,
      pollIntervalMinutes: pollIntervalMinutes ?? this.pollIntervalMinutes,
      candlesLimit: candlesLimit ?? this.candlesLimit,
      strongSignalConfidence:
          strongSignalConfidence ?? this.strongSignalConfidence,
      maxPersistedAlerts: maxPersistedAlerts ?? this.maxPersistedAlerts,
      enableLocalNotifications:
          enableLocalNotifications ?? this.enableLocalNotifications,
      autoStart: autoStart ?? this.autoStart,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'apiKey': apiKey,
      'symbol': symbol,
      'timeframe': timeframe,
      'pollIntervalMinutes': pollIntervalMinutes,
      'candlesLimit': candlesLimit,
      'strongSignalConfidence': strongSignalConfidence,
      'maxPersistedAlerts': maxPersistedAlerts,
      'enableLocalNotifications': enableLocalNotifications,
      'autoStart': autoStart,
    };
  }

  factory ForexMonitorSettings.fromJson(Map<String, dynamic> json) {
    return ForexMonitorSettings(
      apiKey: json['apiKey']?.toString() ?? '',
      symbol: json['symbol']?.toString() ?? 'EURUSD',
      timeframe: json['timeframe']?.toString() ?? 'M15',
      pollIntervalMinutes: _toInt(json['pollIntervalMinutes'], fallback: 5),
      candlesLimit: _toInt(json['candlesLimit'], fallback: 180),
      strongSignalConfidence:
          _toDouble(json['strongSignalConfidence'], fallback: 72.0),
      maxPersistedAlerts: _toInt(json['maxPersistedAlerts'], fallback: 300),
      enableLocalNotifications:
          _toBool(json['enableLocalNotifications'], fallback: true),
      autoStart: _toBool(json['autoStart'], fallback: true),
    );
  }

  static int _toInt(dynamic value, {required int fallback}) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }

    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static double _toDouble(dynamic value, {required double fallback}) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static bool _toBool(dynamic value, {required bool fallback}) {
    if (value is bool) {
      return value;
    }

    final String raw = value?.toString().toLowerCase() ?? '';
    if (raw == 'true') {
      return true;
    }
    if (raw == 'false') {
      return false;
    }
    return fallback;
  }
}
