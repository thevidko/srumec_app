class ApiEndpoints {
  //IP
  static String get _host {
    return 'http://127.0.0.1';
  }

  //URL maker pro services
  static String get eventsBaseUrl => '$_host:4000';
  static String get chatsBaseUrl => '$_host:4001';
}

// Events - ENDPOINTS
class Events {
  static const String getAll = '/v1/events/get-nearby';
  static const String getOne = '/v1/events/get-one';
  static const String create = '/v1/events/create-one';
  static const String delete = '/v1/events/delete-one';
  static const String update = '/v1/events/delete-one';
}
