class TaxiParkDetails {
  const TaxiParkDetails({
    required this.name,
    required this.commissionPercent,
    required this.weekdaySchedule,
    required this.weekendSchedule,
    required this.address,
    required this.phone,
  });

  final String name;
  final double commissionPercent;
  final String weekdaySchedule;
  final String weekendSchedule;
  final String address;
  final String phone;
}
