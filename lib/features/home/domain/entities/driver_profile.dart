class DriverProfile {
  const DriverProfile({
    required this.name,
    this.avatarUrl,
    required this.balance,
  });

  final String name;
  final String? avatarUrl;
  final double balance;

  DriverProfile copyWith({String? name, String? avatarUrl, double? balance}) {
    return DriverProfile(
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      balance: balance ?? this.balance,
    );
  }

  static const mock = DriverProfile(name: 'Tangsuluu', balance: 110.0);
}
