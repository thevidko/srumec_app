class Event {
  final String id;
  final double lat;
  final double lng;
  final String title;
  final String description;
  final DateTime happenTime;
  final String status;
  //TODO přidat happened time, user_id
  Event({
    required this.id,
    required this.lat,
    required this.lng,
    required this.title,
    required this.description,
    required this.happenTime,
    required this.status,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      lat: json['latitude'],
      lng: json['longitude'],
      title: json['title'],
      description: json['description'],
      status: json['status'],
      happenTime:
          DateTime.tryParse(json['happen_time'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'title': title, 'description': description};
  }
}
