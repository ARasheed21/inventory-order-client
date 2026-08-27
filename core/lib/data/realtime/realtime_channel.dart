import 'dart:async';

import 'package:stomp_dart_client/stomp_dart_client.dart';

import '../../infrastructure/observability/reporter.dart';
import 'hint.dart';

/// Manages the STOMP real-time connection lifecycle (FR-007):
///
/// - connects only after authentication, carrying the access token in the
///   CONNECT frame (`Authorization: Bearer ...`);
/// - subscribes immediately after CONNECT to `/user/queue/orders` and
///   `/topic/orders/{orderId}` (the latter on demand);
/// - reconnects automatically with a fixed backoff; [updateToken] refreshes
///   credentials so the next CONNECT succeeds after token expiry;
/// - emits decoded [RealtimeHint]s. Pushes are hints: consumers MUST
///   re-fetch authoritative data over REST.
final class RealtimeChannel {
  RealtimeChannel({Reporter reporter = const ConsoleReporter()})
    : _reporter = reporter;

  final Reporter _reporter;
  StompClient? _client;
  String? _token;
  Uri? _url;
  final StreamController<RealtimeHint> _hints =
      StreamController<RealtimeHint>.broadcast();
  bool _started = false;

  /// Broadcast stream of decoded push hints.
  Stream<RealtimeHint> get hints => _hints.stream;

  bool get isConnected => _client != null && _started;

  /// Starts (or restarts) the channel with the given credentials.
  void start({required Uri url, required String token}) {
    _url = url;
    _token = token;
    _connect();
  }

  /// Supplies a renewed access token; takes effect on the next CONNECT.
  void updateToken(String token) {
    _token = token;
  }

  Future<void> stop() async {
    _started = false;
    _client?.deactivate();
    _client = null;
  }

  void _connect() {
    final Uri? url = _url;
    final String? token = _token;
    if (url == null || token == null) return;

    _client = StompClient(
      config: StompConfig(
        url: url.toString(),
        stompConnectHeaders: <String, String>{'Authorization': 'Bearer $token'},
        reconnectDelay: const Duration(seconds: 3),
        onConnect: _onConnected,
        onStompError: (StompFrame frame) {
          _reporter.log(
            AppLogLevel.warning,
            'realtime.stomp_error',
            context: {'headers': frame.headers},
          );
          // An unauthorized frame means the token expired; the caller is
          // expected to refresh and call updateToken + start again.
        },
        onWebSocketError: (dynamic error) {
          _reporter.log(
            AppLogLevel.warning,
            'realtime.socket_error',
            context: {'error': error.toString()},
          );
        },
        onDebugMessage: (_) {},
      ),
    )..activate();
    _started = true;
  }

  void _onConnected(StompFrame frame) {
    _reporter.log(AppLogLevel.info, 'realtime.connected');
    _client?.subscribe(
      destination: '/user/queue/orders',
      callback: (StompFrame msg) => _handleBody(msg.body),
    );
  }

  /// Subscribes to a public order timeline topic.
  void subscribeToOrder(String orderId) {
    _client?.subscribe(
      destination: '/topic/orders/$orderId',
      callback: (StompFrame msg) => _handleBody(msg.body),
    );
  }

  void _handleBody(String? body) {
    if (body == null || body.isEmpty) return;
    try {
      final RealtimeHint hint = decodeHint(body);
      if (!_hints.isClosed) _hints.add(hint);
    } on MalformedHintException catch (e) {
      // Malformed pushes never crash the app nor reach screens raw.
      _reporter.recordError(describeMalformation(e));
    }
  }
}
