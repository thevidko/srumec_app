class SocketEvent {
  final String event;
  final Map<String, dynamic> data;

  SocketEvent({required this.event, required this.data});

  factory SocketEvent.fromJson(Map<String, dynamic> json) {
    return SocketEvent(
      event: json['event'] ?? 'unknown',
      data: json['data'] is Map<String, dynamic> ? json['data'] : {},
    );
  }
}
