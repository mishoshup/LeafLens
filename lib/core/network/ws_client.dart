import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import 'package:leaflens/core/config/app_config.dart';

/// WebSocket client for FastAPI streaming endpoint.
///
/// Auth via first message (not query param) — same pattern as
/// ThingsBoard's own WS auth. No token leakage in server logs.
class WsClient {
  final String url;
  WebSocketChannel? _channel;
  StreamController<Map<String, dynamic>>? _controller;
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  bool _disposed = false;
  String? _token;
  bool _authenticated = false;
  static const _maxAttempts = 10;

  WsClient({String? url}) : url = url ?? AppConfig.wsUrl;

  Stream<Map<String, dynamic>> connect(String token) {
    _token = token;
    _authenticated = false;
    _controller = StreamController<Map<String, dynamic>>.broadcast();
    _doConnect();
    return _controller!.stream;
  }

  void _doConnect() {
    if (_disposed || _token == null) return;

    try {
      _channel = WebSocketChannel.connect(Uri.parse(url));
      _reconnectAttempts = 0;
      _authenticated = false;

      // Send auth as first message
      _channel!.sink.add(jsonEncode({
        'type': 'auth',
        'token': _token,
      }));

      _channel!.stream.listen(
        (raw) {
          try {
            final data = jsonDecode(raw as String) as Map<String, dynamic>;

            // First message should be auth acknowledgement
            if (!_authenticated) {
              if (data['type'] == 'auth_ok') {
                _authenticated = true;
              }
              return;
            }

            _controller?.add(data);
          } catch (_) {}
        },
        onError: (_) => _scheduleReconnect(),
        onDone: () => _scheduleReconnect(),
      );
    } catch (_) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_disposed || _reconnectAttempts >= _maxAttempts) return;
    _reconnectAttempts++;
    final delay = Duration(
      seconds: [1, 2, 4, 8, 15, 30][_reconnectAttempts.clamp(0, 5)],
    );
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () {
      _channel?.sink.close();
      _doConnect();
    });
  }

  void send(Map<String, dynamic> msg) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode(msg));
    }
  }

  void dispose() {
    _disposed = true;
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _controller?.close();
  }
}
