class DriverCar {
  const DriverCar({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.colorLabel,
    required this.plateNumber,
    required this.registrationCertificate,
    required this.vinOrStateNumber,
    this.imageUrl,
  });

  final String id;
  final String title;
  final String subtitle;
  final String colorLabel;
  final String plateNumber;
  final String registrationCertificate;
  final String vinOrStateNumber;
  final String? imageUrl;
}
