import 'package:test/test.dart';

import 'package:core/data/realtime/hint.dart';

/// FR-007 / contracts/ws/asyncapi-ws.md payload table.
void main() {
  group('decodeHint', () {
    test('decodes every documented status value', () {
      const Map<String, OrderStatus> statuses = {
        'PAID': OrderStatus.paid,
        'SHIPPED': OrderStatus.shipped,
        'DELIVERED': OrderStatus.delivered,
        'RESERVATION_EXPIRED': OrderStatus.reservationExpired,
        'PAYMENT_FAILED': OrderStatus.paymentFailed,
        'USER_UPDATE': OrderStatus.userUpdate,
      };
      statuses.forEach((String wire, OrderStatus expected) {
        final RealtimeHint hint = decodeHint(
          '{"orderId":"o1","status":"$wire"}',
        );
        expect(hint, isA<OrderStatusHint>());
        expect((hint as OrderStatusHint).status, expected);
        expect(hint.orderId, 'o1');
      });
    });

    test('extracts reason for PAYMENT_FAILED pushes', () {
      final RealtimeHint hint = decodeHint(
        '{"orderId":"3f2a","status":"PAYMENT_FAILED","reason":"Reservation expired"}',
      );
      expect((hint as OrderStatusHint).reason, 'Reservation expired');
    });

    test('rejects payloads missing orderId', () {
      expect(
        () => decodeHint('{"status":"PAID"}'),
        throwsA(isA<MalformedHintException>()),
      );
    });

    test('rejects unknown status values', () {
      expect(
        () => decodeHint('{"orderId":"1","status":"TELEPORTED"}'),
        throwsA(isA<MalformedHintException>()),
      );
    });

    test('rejects non-JSON bodies', () {
      expect(
        () => decodeHint('<xml/>'),
        throwsA(isA<MalformedHintException>()),
      );
    });
  });
}
