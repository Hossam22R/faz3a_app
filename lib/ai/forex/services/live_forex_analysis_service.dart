import '../agents/forex_analysis_agent.dart';
import '../models/forex_analysis_report.dart';
import 'forex_market_data_source.dart';

class LiveForexAnalysisService {
  final ForexMarketDataSource marketDataSource;
  final ForexAnalysisAgent analysisAgent;

  LiveForexAnalysisService({
    required this.marketDataSource,
    ForexAnalysisAgent? analysisAgent,
  }) : analysisAgent = analysisAgent ?? const ForexAnalysisAgent();

  Future<ForexAnalysisReport> analyzeLive({
    required String symbol,
    required String timeframe,
    int candlesLimit = 200,
  }) async {
    final candles = await marketDataSource.fetchCandles(
      symbol: symbol,
      timeframe: timeframe,
      limit: candlesLimit,
    );

    return analysisAgent.analyze(
      symbol: symbol,
      timeframe: timeframe,
      candles: candles,
    );
  }
}
