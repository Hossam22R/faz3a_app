# Forex Analysis Agent (Dart)

هذا المشروع يحتوي الآن على وكيل ذكاء اصطناعي مخصص **فقط لتحليل سوق الفوركس**.

## المتطلبات

- Flutter/Dart بمستوى: `>=2.17.0 <3.0.0`
- تم إضافة اعتماد: `flutter_local_notifications`

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
- `lib/ai/forex/models/forex_monitor_settings.dart`
- `lib/ai/forex/models/forex_watchlist_item.dart`
- `lib/ai/forex/services/technical_indicators.dart`
- `lib/ai/forex/services/forex_market_data_source.dart`
- `lib/ai/forex/services/twelve_data_forex_data_source.dart`
- `lib/ai/forex/services/live_forex_analysis_service.dart`
- `lib/ai/forex/services/live_forex_signal_monitor.dart`
- `lib/ai/forex/services/forex_alert_history_store.dart`
- `lib/ai/forex/services/forex_monitor_settings_store.dart`
- `lib/ai/forex/services/forex_watchlist_store.dart`
- `lib/ai/forex/services/forex_local_notifications_service.dart`
- `lib/ai/forex/services/forex_alert_notification_bridge.dart`
- `lib/ai/forex/agents/forex_analysis_agent.dart`
- `lib/ai/forex/controllers/forex_monitor_settings_controller.dart`
- `lib/ai/forex/controllers/forex_watchlist_controller.dart`
- `lib/ai/forex/controllers/live_forex_monitor_controller.dart`
- `lib/ai/forex/ui/forex_live_monitor_route_page.dart`
- `lib/ai/forex/ui/forex_monitor_page.dart`
- `lib/ai/forex/ui/forex_monitor_settings_page.dart`
- `lib/ai/forex/ui/forex_watchlist_page.dart`
- `lib/ai/forex/ui/forex_monitor_workspace_page.dart`
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

## ربط الوكيل ببيانات السوق الحية (Twelve Data)

1) أنشئ API Key من:

- https://twelvedata.com/

2) اربط مزود البيانات مع الوكيل:

```dart
import 'package:faz3a_app/ai/forex/forex_analysis.dart';

Future<void> runLive() async {
  final dataSource = TwelveDataForexDataSource(
    apiKey: 'YOUR_TWELVE_DATA_API_KEY',
  );

  final liveService = LiveForexAnalysisService(
    marketDataSource: dataSource,
  );

  final report = await liveService.analyzeLive(
    symbol: 'EURUSD', // او EUR/USD
    timeframe: 'H1',
    candlesLimit: 180,
  );

  print(report.toJson());
  dataSource.dispose();
}
```

### استخدام المفتاح من dart-define (اختياري)

```dart
final dataSource = TwelveDataForexDataSource.fromEnvironment();
```

وشغّل التطبيق بهذا الشكل:

```bash
flutter run --dart-define=TWELVE_DATA_API_KEY=YOUR_TWELVE_DATA_API_KEY
```

### الفواصل الزمنية المدعومة (timeframe)

- `M1`, `M5`, `M15`, `M30`, `M45`
- `H1`, `H2`, `H4`, `H8`, `H12`
- `D1`, `W1`, `MN1`

> ملاحظة: الوكيل يحتاج 60 شمعة على الأقل للتحليل.

## جدولة التحليل تلقائيًا + تنبيهات الإشارة

يمكنك تشغيل مراقب حي يفحص السوق كل فترة زمنية ويطلق تنبيهًا عند:

- تغيّر الإشارة (`BUY`/`SELL`/`NEUTRAL`)
- أو ظهور إشارة قوية (Confidence أعلى من حد معين)

```dart
import 'package:faz3a_app/ai/forex/forex_analysis.dart';

Future<void> setupMonitor() async {
  final dataSource = TwelveDataForexDataSource(apiKey: 'YOUR_API_KEY');
  final liveService = LiveForexAnalysisService(marketDataSource: dataSource);

  final monitor = LiveForexSignalMonitor(
    analysisService: liveService,
    symbol: 'EURUSD',
    timeframe: 'M15',
    config: const LiveForexMonitorConfig(
      pollInterval: Duration(minutes: 5),
      candlesLimit: 180,
      strongSignalConfidence: 72,
    ),
  );

  monitor.reports.listen((report) {
    // تحديث واجهة المستخدم او حفظ التقرير
    print('Report: ${report.toJson()}');
  });

  monitor.alerts.listen((alert) {
    // هنا يمكنك ارسال Local Notification او عرض Snackbar
    print('ALERT: ${alert.toJson()}');
  });

  monitor.errors.listen((error) {
    print('Monitor Error: $error');
  });

  monitor.start(runImmediately: true);
}
```

## ربط أسرع داخل Flutter عبر Controller

يوجد Controller جاهز:

- `LiveForexMonitorController`

ويحتوي على:

- `latestReport`
- `latestAlert`
- `lastError`
- `start()` / `stop()` / `refreshNow()`

يمكن استخدامه مباشرة مع `provider` و `ChangeNotifierProvider`.

### حفظ سجل التنبيهات محليًا (SharedPreferences)

```dart
final monitor = LiveForexSignalMonitor(
  analysisService: liveService,
  symbol: 'EURUSD',
  timeframe: 'M15',
);

final controller = LiveForexMonitorController(
  monitor: monitor,
  alertHistoryStore: ForexAlertHistoryStore(),
  maxPersistedAlerts: 300,
);
```

بهذا الشكل، كل تنبيه جديد يتم حفظه تلقائيًا، ويعاد تحميله عند فتح التطبيق.

## صفحة Flutter جاهزة لعرض المراقبة + السجل

تمت إضافة صفحة جاهزة:

- `ForexMonitorPage`
- `ForexLiveMonitorRoutePage` (جاهزة للـ Route وتبني كل الـ dependencies تلقائيًا)

مثال استخدام داخل `MaterialApp`:

```dart
MaterialApp(
  home: ForexMonitorPage(
    controller: controller,
    title: 'EURUSD Monitor',
  ),
);
```

الصفحة تعرض:

- الإشارة الحالية ونسبة الثقة
- ملاحظة المخاطر
- آخر أخطاء الجلب (إن وجدت)
- سجل التنبيهات بالكامل

### Route + Provider wiring جاهز

يمكنك إضافتها مباشرة داخل `MaterialApp`:

```dart
import 'package:faz3a_app/ai/forex/forex_analysis.dart';

MaterialApp(
  routes: {
    '/forex-monitor': (_) => ForexLiveMonitorRoutePage(
          apiKey: const String.fromEnvironment('TWELVE_DATA_API_KEY'),
          symbol: 'EURUSD',
          timeframe: 'M15',
          title: 'EURUSD Live Monitor',
        ),
  },
);
```

والتنقل إليها:

```dart
Navigator.of(context).pushNamed('/forex-monitor');
```

هذه الصفحة تقوم تلقائيًا بـ:

- إنشاء `TwelveDataForexDataSource`
- إنشاء `LiveForexSignalMonitor`
- إنشاء `LiveForexMonitorController` مع حفظ التاريخ
- ربط Local Notifications (اختياري عبر `enableLocalNotifications`)

## واجهة إعدادات جاهزة داخل التطبيق

تمت إضافة صفحة إعدادات كاملة:

- `ForexMonitorSettingsPage`

وتدعم:

- حفظ الإعدادات في `SharedPreferences`
- تعديل API Key / Symbol / Timeframe
- تعديل poll interval / candles limit / confidence
- تشغيل شاشة المراقبة مباشرة من الإعدادات

### استخدام مباشر كـ Route

```dart
MaterialApp(
  routes: {
    '/forex-settings': (_) => const ForexMonitorSettingsPage(),
  },
);
```

### فتح شاشة المراقبة من إعدادات محفوظة

```dart
final settings = ForexMonitorSettings(
  apiKey: const String.fromEnvironment('TWELVE_DATA_API_KEY'),
  symbol: 'GBPUSD',
  timeframe: 'M15',
  pollIntervalMinutes: 5,
  candlesLimit: 180,
  strongSignalConfidence: 72,
  maxPersistedAlerts: 300,
  enableLocalNotifications: true,
  autoStart: true,
);

Navigator.of(context).push(
  MaterialPageRoute(
    builder: (_) => ForexLiveMonitorRoutePage.fromSettings(
      settings: settings,
      title: 'GBPUSD Monitor',
    ),
  ),
);
```

## صفحة موحدة (Dashboard) للمراقبة + الإعدادات

تمت إضافة صفحة:

- `ForexMonitorWorkspacePage`

وتوفر:

- تبويب Monitor
- تبويب Settings
- تبويب Watchlist (لإدارة عدة أزواج)
- إعادة بناء شاشة المراقبة تلقائيًا بعد حفظ الإعدادات
- استخدام `TWELVE_DATA_API_KEY` تلقائيًا كقيمة أولية إذا لم تكن الإعدادات محفوظة

### تشغيل سريع كـ Route

```dart
MaterialApp(
  routes: {
    '/forex-dashboard': (_) => const ForexMonitorWorkspacePage(
          monitorTitle: 'Forex Monitor',
          settingsTitle: 'Forex Settings',
        ),
  },
);
```

### فتح صفحة الـ Dashboard

```dart
Navigator.of(context).pushNamed('/forex-dashboard');
```

### إدارة عدة أزواج فوركس (Watchlist)

الـ Dashboard الآن يدعم:

- إضافة/تعديل/حذف أزواج متعددة
- تحديد زوج رئيسي (Primary)
- تعطيل/تفعيل أزواج بدون حذفها
- إعادة تحميل المونيتور تلقائيًا عند تغيير الزوج الرئيسي

الزوج المعروض في تبويب Monitor يتم اختياره بهذا الترتيب:

1. الزوج الرئيسي المفعّل (Primary + Enabled)
2. أول زوج مفعّل في الـ Watchlist
3. إعدادات الزوج الافتراضية من `ForexMonitorSettings`

## تنبيهات نظام حقيقية (Local Notifications)

تمت إضافة خدمة إشعارات محلية يمكن ربطها مباشرة مع تنبيهات الوكيل.

```dart
import 'package:flutter/widgets.dart';
import 'package:faz3a_app/ai/forex/forex_analysis.dart';

Future<void> setupLiveNotifications() async {
  WidgetsFlutterBinding.ensureInitialized();

  final dataSource = TwelveDataForexDataSource(apiKey: 'YOUR_API_KEY');
  final liveService = LiveForexAnalysisService(marketDataSource: dataSource);

  final monitor = LiveForexSignalMonitor(
    analysisService: liveService,
    symbol: 'EURUSD',
    timeframe: 'M15',
    config: const LiveForexMonitorConfig(
      pollInterval: Duration(minutes: 5),
      strongSignalConfidence: 72,
    ),
  );

  final notificationsService = ForexLocalNotificationsService();
  final bridge = ForexAlertNotificationBridge(
    monitor: monitor,
    notificationsService: notificationsService,
  );

  await bridge.start();
  monitor.start(runImmediately: true);
}
```

عند وصول `alert` من الوكيل، يتم إرسال إشعار نظام تلقائيًا.

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
