class UserProfile {
  final String id;
  final String name;

  UserProfile({required this.id, required this.name});

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      // Záleží, co vrací tvůj endpoint /auth/users
      name: json['name'] ?? json['username'] ?? 'Neznámý',
    );
  }
}
