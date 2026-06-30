class DriverProfile {
  const DriverProfile({
    required this.fullName,
    required this.roleLabel,
    required this.ordersCount,
    required this.experienceYears,
    required this.rating,
    this.avatarUrl,
    required this.carsSummary,
    required this.taxiParkName,
  });

  final String fullName;
  final String roleLabel;
  final int ordersCount;
  final int experienceYears;
  final double rating;
  final String? avatarUrl;
  final String carsSummary;
  final String taxiParkName;
}
