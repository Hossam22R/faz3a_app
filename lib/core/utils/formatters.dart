import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static String formatIqd(num amount) {
    final NumberFormat formatter = NumberFormat.currency(
      locale: 'ar_IQ',
      symbol: 'IQD',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }
}
