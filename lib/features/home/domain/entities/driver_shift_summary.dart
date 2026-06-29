class DriverShiftSummary {
  const DriverShiftSummary({
    required this.dateLabel,
    required this.earnings,
    required this.ordersCount,
  });

  final String dateLabel;
  final String earnings;
  final int ordersCount;

  static const empty = DriverShiftSummary(
    dateLabel: '',
    earnings: '0 с',
    ordersCount: 0,
  );
}
