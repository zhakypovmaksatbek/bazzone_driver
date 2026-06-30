class TripHistoryItem {
  const TripHistoryItem({
    required this.id,
    required this.distanceKm,
    required this.time,
    required this.route,
    required this.earnedAmount,
    required this.date,
  });

  final String id;
  final double distanceKm;
  final String time;
  final String route;
  final double earnedAmount;
  final DateTime date;
}

class TripHistorySection {
  const TripHistorySection({
    required this.title,
    required this.trips,
  });

  final String title;
  final List<TripHistoryItem> trips;
}
