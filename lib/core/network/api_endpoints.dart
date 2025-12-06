class ApiEndpoints {
  //IP
  static String get _host {
    //return 'http://172.20.10.3';

    return 'http://10.0.2.2';
  }

  //URL maker pro services
  static String get eventsBaseUrl => '$_host:8000';
  static String get chatsBaseUrl => '$_host:8000';
  static String get baseUrl => '$_host:8000';
}

// Events - ENDPOINTS
class Events {
  static const String getAll = '/v1/events/get-nearby';
  static const String getOne = '/v1/events/get-one';
  static const String getMy = '/v1/events/get-my-events';
  static const String create = '/v1/events/create-one';
  static const String delete = '/v1/events/delete-one';
  static const String update = '/v1/events/delete-one';
}

class Auth {
  static const String login = '/auth/login';
}

class UserEndpoints {
  static const String base = '/auth/users/';
}

class CommentsEndpoints {
  static const String getByEvent = '/v1/comments/get-all';
  static const String create = '/v1/comments/create-one';
}

class ChatEndpoints {
  //Direct rooms
  static const String createDirectRoom = '/v1/chats/direct/create-one';
  //Výpis všech chatů, kde je uživatel podle JWT účastníkem.
  static const String getAllMyDirectRooms = '/v1/chats/direct/get-all';

  //Group roomy asi řešit nebudeme zatím.

  static const String getAllMessages = '/v1/chats/direct/messages/get-all';
  static const String createMessage = '/v1/chats/direct/messages/create-one';
}
