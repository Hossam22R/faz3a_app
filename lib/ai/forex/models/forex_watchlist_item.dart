class ForexWatchlistItem {
  final String id;
  final String symbol;
  final String timeframe;
  final String label;
  final bool isEnabled;
  final bool isPrimary;

  const ForexWatchlistItem({
    required this.id,
    required this.symbol,
    required this.timeframe,
    this.label = '',
    this.isEnabled = true,
    this.isPrimary = false,
  });

  String get displayName {
    if (label.trim().isNotEmpty) {
      return label.trim();
    }
    return '$symbol $timeframe';
  }

  ForexWatchlistItem copyWith({
    String? id,
    String? symbol,
    String? timeframe,
    String? label,
    bool? isEnabled,
    bool? isPrimary,
  }) {
    return ForexWatchlistItem(
      id: id ?? this.id,
      symbol: symbol ?? this.symbol,
      timeframe: timeframe ?? this.timeframe,
      label: label ?? this.label,
      isEnabled: isEnabled ?? this.isEnabled,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'symbol': symbol,
      'timeframe': timeframe,
      'label': label,
      'isEnabled': isEnabled,
      'isPrimary': isPrimary,
    };
  }

  factory ForexWatchlistItem.fromJson(Map<String, dynamic> json) {
    return ForexWatchlistItem(
      id: json['id']?.toString() ?? '',
      symbol: json['symbol']?.toString() ?? 'EURUSD',
      timeframe: json['timeframe']?.toString() ?? 'M15',
      label: json['label']?.toString() ?? '',
      isEnabled: _toBool(json['isEnabled'], fallback: true),
      isPrimary: _toBool(json['isPrimary'], fallback: false),
    );
  }

  static ForexWatchlistItem create({
    required String symbol,
    required String timeframe,
    String label = '',
    bool isEnabled = true,
    bool isPrimary = false,
  }) {
    final String id = DateTime.now().microsecondsSinceEpoch.toString();
    return ForexWatchlistItem(
      id: id,
      symbol: symbol,
      timeframe: timeframe,
      label: label,
      isEnabled: isEnabled,
      isPrimary: isPrimary,
    );
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
