class DriverProfile {
  const DriverProfile({
    required this.name,
    this.avatarUrl,
  });

  final String name;
  final String? avatarUrl;

  static const mock = DriverProfile(name: 'Tangsuluu');
}
