import 'package:intl/intl.dart';

abstract final class WalletFormatters {
  static final NumberFormat _amountFormatter = NumberFormat('#,##0.##', 'ru');
  static final NumberFormat _earnedFormatter = NumberFormat('#,##0.00', 'ru');
  static final DateFormat _monthFormatter = DateFormat('LLLL', 'ru');
  static final DateFormat _transactionDateFormatter =
      DateFormat('d MMMM / HH:mm', 'ru');

  static String formatBalance(double amount) {
    return _amountFormatter.format(amount);
  }

  static String formatEarned(double amount) {
    return _earnedFormatter.format(amount);
  }

  static String formatMonth(DateTime date) {
    final month = _monthFormatter.format(date);
    if (month.isEmpty) return month;
    return month[0].toUpperCase() + month.substring(1);
  }

  static String formatTransactionDate(DateTime date) {
    return _transactionDateFormatter.format(date);
  }

  static String formatTransactionAmount(double amount) {
    final formatted = _amountFormatter.format(amount.abs());
    final prefix = amount >= 0 ? '+' : '-';
    return '$prefix$formatted с';
  }
}
