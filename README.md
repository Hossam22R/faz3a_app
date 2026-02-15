# Forex Analysis Agent (Dart)

هذا المشروع يحتوي الآن على وكيل ذكاء اصطناعي مخصص **فقط لتحليل سوق الفوركس**.

## ماذا يفعل الوكيل؟

- يستقبل بيانات الشموع السعرية (OHLCV).
- يحسب مؤشرات فنية أساسية:
  - SMA 20 / SMA 50
  - EMA 20
  - RSI 14
  - MACD (12, 26, 9)
  - ATR 14
- ينتج تقرير تحليل نهائي يتضمن:
  - إشارة: `BUY` أو `SELL` أو `NEUTRAL`
  - نسبة ثقة
  - أسباب الإشارة
  - مستويات دعم/مقاومة
  - ملاحظة إدارة مخاطر

> الوكيل للتحليل فقط وليس تنفيذ صفقات تلقائي.

## أماكن الملفات

- `lib/ai/forex/models/forex_candle.dart`
- `lib/ai/forex/models/forex_analysis_report.dart`
- `lib/ai/forex/services/technical_indicators.dart`
- `lib/ai/forex/agents/forex_analysis_agent.dart`
- `lib/ai/forex/forex_analysis.dart` (Barrel export)

## مثال استخدام سريع

```dart
import 'package:faz3a_app/ai/forex/forex_analysis.dart';

void main() {
  final agent = ForexAnalysisAgent();

  final candles = <ForexCandle>[
    ForexCandle(
      time: DateTime.parse('2026-02-15T10:00:00Z'),
      open: 1.0820,
      high: 1.0840,
      low: 1.0810,
      close: 1.0835,
      volume: 1200,
    ),
    // ... اضف ما لا يقل عن 60 شمعة
  ];

  final report = agent.analyze(
    symbol: 'EURUSD',
    timeframe: 'H1',
    candles: candles,
  );

  print(report.toJson());
}
```

## مثال إدخال JSON

```dart
final report = agent.analyzeFromJson(
  symbol: 'GBPUSD',
  timeframe: 'M15',
  candlesJson: [
    {
      'time': '2026-02-15T10:00:00Z',
      'open': 1.2701,
      'high': 1.2718,
      'low': 1.2694,
      'close': 1.2711,
      'volume': 900
    }
  ],
);
```

## شكل كل شمعة مطلوب

```json
{
  "time": "ISO_8601_datetime",
  "open": 1.2345,
  "high": 1.2400,
  "low": 1.2300,
  "close": 1.2380,
  "volume": 1000
}
```

## ملاحظة مهمة

هذه الخوارزمية تحليلية وتعتمد على المؤشرات الفنية، لذلك يفضل دمجها مع:

- قواعد إدارة رأس مال
- أخبار الاقتصاد الكلي
- إدارة مخاطر صارمة قبل أي قرار تداول
