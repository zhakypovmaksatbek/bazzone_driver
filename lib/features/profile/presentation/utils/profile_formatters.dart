import 'package:intl/intl.dart';

abstract final class ProfileFormatters {
  static final NumberFormat _countFormatter = NumberFormat('#,###', 'ru');

  static String formatCount(int value) {
    return _countFormatter.format(value).replaceAll(',', ' ');
  }

  static String formatExperienceYears(int years) {
    return '$years лет';
  }

  static String formatRating(double rating) {
    return rating.toStringAsFixed(1);
  }

  static String formatTripDistance(double km) {
    return '${km.toStringAsFixed(0)} км';
  }

  static String formatTripEarned(double amount) {
    return '+${amount.toStringAsFixed(0)} с';
  }

  static String formatCommission(double percent) {
    return '${percent.toStringAsFixed(0)}%';
  }
}
