class ChatRoom {
  final String id;
  final String firstUser;
  final String secondUser;

  ChatRoom({
    required this.id,
    required this.firstUser,
    required this.secondUser,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'] ?? '',
      firstUser: json['user_1_ref'] ?? '',
      secondUser: json['user_2_ref'] ?? '',
    );
  }

  String getOtherUserId(String myUserId) {
    return firstUser == myUserId ? secondUser : firstUser;
  }
}
