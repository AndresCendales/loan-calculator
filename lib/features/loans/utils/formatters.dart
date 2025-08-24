import 'package:intl/intl.dart';
import 'package:decimal/decimal.dart';

class LoanFormatters {
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_US',
    symbol: '\$',
    decimalDigits: 2,
  );

  static final NumberFormat _percentFormat = NumberFormat.decimalPercentPattern();

  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  /// Format a Decimal as currency
  static String formatCurrency(Decimal amount) {
    return _currencyFormat.format(amount.toDouble());
  }

  /// Format a Decimal as percentage (e.g., 0.12 -> 12.00%)
  static String formatPercentage(Decimal rate) {
    return _percentFormat.format(rate.toDouble());
  }

  /// Format a DateTime as date string
  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  /// Parse currency string to Decimal
  static Decimal? parseCurrency(String value) {
    try {
      // Remove currency symbols and formatting
      final cleanValue = value.replaceAll(RegExp(r'[^\d.-]'), '');
      return Decimal.parse(cleanValue);
    } catch (e) {
      return null;
    }
  }

  /// Parse percentage string to Decimal (e.g., "12%" -> 0.12)
  static Decimal? parsePercentage(String value) {
    try {
      final cleanValue = value.replaceAll('%', '').trim();
      final percentage = double.parse(cleanValue);
      return Decimal.parse((percentage / 100).toString());
    } catch (e) {
      return null;
    }
  }

  /// Format number with thousand separators
  static String formatNumber(Decimal number) {
    final format = NumberFormat('#,##0.00');
    return format.format(number.toDouble());
  }
}
