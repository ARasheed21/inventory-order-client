import 'dart:convert';

import 'package:meta/meta.dart';

import '../../domain/failures.dart';

/// Order status values delivered over the real-time channel
/// (contracts/ws/asyncapi-ws.md).
enum OrderStatus {
  paid,
  shipped,
  delivered,
  reservationExpired,
  paymentFailed,
  userUpdate,
}

OrderStatus? orderStatusFromWire(String value) => switch (value) {
  'PAID' => OrderStatus.paid,
  'SHIPPED' => OrderStatus.shipped,
  'DELIVERED' => OrderStatus.delivered,
  'RESERVATION_EXPIRED' => OrderStatus.reservationExpired,
  'PAYMENT_FAILED' => OrderStatus.paymentFailed,
  'USER_UPDATE' => OrderStatus.userUpdate,
  _ => null,
};

/// Decoded push payload treated as a hint only — consumers re-fetch the
/// authoritative resource over REST after each hint (FR-007).
@immutable
sealed class RealtimeHint {
  const RealtimeHint({required this.orderId});

  final String orderId;
}

final class OrderStatusHint extends RealtimeHint {
  const OrderStatusHint({
    required super.orderId,
    required this.status,
    this.reason,
  });

  final OrderStatus status;
  final String? reason;
}

/// Thrown/returned when a payload does not satisfy the AsyncAPI contract.
final class MalformedHintException implements Exception {
  const MalformedHintException(this.detail);

  final String detail;

  @override
  String toString() => 'MalformedHintException: $detail';
}

/// Decodes STOMP message bodies into [RealtimeHint]s.
RealtimeHint decodeHint(String body) {
  dynamic decoded;
  try {
    decoded = jsonDecode(body);
  } on FormatException catch (e) {
    throw MalformedHintException('payload is not valid JSON: ${e.message}');
  }
  if (decoded is! Map<String, dynamic>) {
    throw const MalformedHintException('payload is not a JSON object');
  }
  final Object? orderId = decoded['orderId'];
  if (orderId is! String || orderId.isEmpty) {
    throw const MalformedHintException('missing required field "orderId"');
  }
  final Object? status = decoded['status'];
  if (status is! String) {
    throw const MalformedHintException('missing required field "status"');
  }
  final OrderStatus? parsed = orderStatusFromWire(status);
  if (parsed == null) {
    throw MalformedHintException('unknown status "$status"');
  }
  final Object? reason = decoded['reason'];
  return OrderStatusHint(
    orderId: orderId,
    status: parsed,
    reason: reason is String ? reason : null,
  );
}

/// Failure taxonomy helper so realtime consumers surface friendly errors.
Failure describeMalformation(MalformedHintException e) =>
    UnknownFailure(message: 'Ignored malformed notification (${e.detail}).');
