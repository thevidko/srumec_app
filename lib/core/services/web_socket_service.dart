import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:srumec_app/core/models/socket_events.dart';
import 'package:srumec_app/core/network/api_endpoints.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

class WebSocketService {
  WebSocketChannel? _channel;

  // Stream, který vysílá zpracované události do celé aplikace (Chat i Mapa)
  final _eventController = StreamController<SocketEvent>.broadcast();

  Stream<SocketEvent> get eventStream => _eventController.stream;

  // Připojení k WebSocketu
  void connect(String token) {
    if (_channel != null) {
      debugPrint("⚠️ WS: Už jsem připojen, ignoruji požadavek.");
      return;
    }

    // 1. VÝPIS: Vidím, že se volá funkce a s jakým tokenem (zkráceně)
    debugPrint(
      "🔌 WS: Zkouším připojit... Token: ${token.substring(0, 10)}...",
    );

    final wsBaseUrl = ApiEndpoints.baseUrl.replaceFirst('http', 'ws');
    final url = '$wsBaseUrl/ws?token=$token';

    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));

      // 2. VÝPIS: Kanál byl inicializován (neznamená 100% handshake, ale start)
      debugPrint("✅ WS: Kanál vytvořen, začínám naslouchat.");

      _channel!.stream.listen(
        (message) {
          // 3. VÝPIS: Pokud toto uvidíte, spojení funguje na 100%
          debugPrint("📩 WS DATA: $message");
          _handleIncomingMessage(message);
        },
        onDone: () {
          debugPrint("👋 WS: Spojení ukončeno serverem (onDone).");
          _channel = null;
        },
        onError: (error) {
          // 4. VÝPIS: Pokud je server nedostupný nebo token špatný
          debugPrint("❌ WS CHYBA: $error");
          _channel = null;
        },
      );
    } catch (e) {
      debugPrint("❌ WS CRITICAL ERROR: $e");
    }
  }

  void _handleIncomingMessage(dynamic message) {
    try {
      debugPrint("📩 WS Příchozí data: $message");
      final json = jsonDecode(message);
      final event = SocketEvent.fromJson(json);

      // Pošleme událost dál do aplikace (Providerům)
      _eventController.add(event);
    } catch (e) {
      debugPrint("⚠️ WS Parse Error: $e");
    }
  }

  void disconnect() {
    if (_channel != null) {
      debugPrint("🔌 WS: Odpojuji...");
      _channel!.sink.close(status.goingAway);
      _channel = null;
    }
  }
}
