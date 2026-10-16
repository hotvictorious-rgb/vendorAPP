import 'package:intl/intl.dart';

class CurrencyFormatter {
  static final NumberFormat _formatter = NumberFormat.currency(
    symbol: '₦',
    decimalDigits: 2,
    customPattern: '¤#,##0.00',
  );

  static final NumberFormat _compactFormatter = NumberFormat.currency(
    symbol: '₦',
    decimalDigits: 0,
    customPattern: '¤#,##0',
  );

  static String format(dynamic amount) {
    if (amount == null) return '₦0.00';
    double value = 0.0;
    if (amount is num) {
      value = amount.toDouble();
    } else if (amount is String) {
      value = double.tryParse(amount) ?? 0.0;
    }
    return _formatter.format(value);
  }

  static String formatCompact(dynamic amount) {
    if (amount == null) return '₦0';
    double value = 0.0;
    if (amount is num) {
      value = amount.toDouble();
    } else if (amount is String) {
      value = double.tryParse(amount) ?? 0.0;
    }
    return _compactFormatter.format(value);
  }
}
