import 'package:intl/intl.dart';

abstract final class SupportFormatters {
  static final DateFormat _shortDateFormatter = DateFormat('dd.MM');

  static String formatShortDate(DateTime date) {
    return _shortDateFormatter.format(date);
  }
}
